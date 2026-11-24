-- Keep paid seller earnings in the ledger, but expose them in the seller
-- wallet only after buyer confirmation or 14 days after the seller enters tracking.

alter table public.seller_wallet_ledger
  add column if not exists released_at timestamptz;

alter table public.order_shipments
  add column if not exists auto_release_at timestamptz;

update public.order_shipments
set auto_release_at = shipped_at + interval '14 days'
where auto_release_at is null;

-- Preserve balances for completed historical orders. Other paid earnings move
-- back to pending until the buyer confirms or the shipment timer expires.
update public.seller_wallet_ledger l
set released_at = coalesce(o.completed_at, now())
from public.orders o
where l.order_id = o.id
  and l.released_at is null
  and (o.status = 'delivered' or o.completed_at is not null);

update public.seller_wallet_ledger l
set released_at = coalesce(s.delivered_at, s.shipped_at, now())
from public.order_shipments s
where l.order_id = s.order_id
  and l.seller_id = s.seller_id
  and l.released_at is null
  and s.status = 'delivered';

create index if not exists seller_wallet_ledger_pending_release_idx
  on public.seller_wallet_ledger(order_id, seller_id)
  where released_at is null;

create or replace function public.register_seller_shipment(
  p_order_id uuid,
  p_courier text,
  p_tracking_number text
) returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_seller_id uuid := auth.uid();
begin
  if v_seller_id is null then raise exception 'Sign in as the seller first'; end if;
  if char_length(trim(p_courier)) not between 2 and 80 then
    raise exception 'Enter a valid courier name';
  end if;
  if char_length(trim(p_tracking_number)) not between 5 and 100 then
    raise exception 'Enter a valid tracking number';
  end if;
  if not exists (
    select 1 from public.orders o
    join public.order_items oi on oi.order_id = o.id
    where o.id = p_order_id
      and o.payment_status = 'paid'
      and o.status <> 'delivered'
      and oi.seller_id = v_seller_id
  ) then
    raise exception 'Paid, incomplete order not found for this seller';
  end if;

  if exists (
    select 1 from public.order_shipments s
    where s.order_id = p_order_id
      and s.seller_id = v_seller_id
      and s.status = 'delivered'
  ) then
    raise exception 'This shipment is already completed';
  end if;

  insert into public.order_shipments(
    order_id, seller_id, courier, tracking_number, status, shipped_at, auto_release_at
  ) values (
    p_order_id, v_seller_id, trim(p_courier), trim(p_tracking_number),
    'shipped', now(), now() + interval '14 days'
  )
  on conflict (order_id, seller_id) do update
    set courier = excluded.courier,
        tracking_number = excluded.tracking_number;
end;
$$;

revoke all on function public.register_seller_shipment(uuid, text, text)
  from public, anon;
grant execute on function public.register_seller_shipment(uuid, text, text)
  to authenticated;

create or replace function public.confirm_buyer_order_received(p_order_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_buyer_id uuid := auth.uid();
begin
  if v_buyer_id is null then raise exception 'Sign in as the buyer first'; end if;

  perform 1 from public.orders o
  where o.id = p_order_id and o.buyer_id = v_buyer_id and o.payment_status = 'paid'
  for update;
  if not found then raise exception 'Paid order not found for this buyer'; end if;

  if not exists (select 1 from public.order_items oi where oi.order_id = p_order_id) or exists (
    select 1 from public.order_items oi
    where oi.order_id = p_order_id
      and not exists (
        select 1 from public.order_shipments s
        where s.order_id = p_order_id and s.seller_id = oi.seller_id
      )
  ) then
    raise exception 'Wait until every seller has shipped this order';
  end if;

  update public.order_shipments
  set status = 'delivered', delivered_at = coalesce(delivered_at, now())
  where order_id = p_order_id and status <> 'delivered';

  update public.orders
  set status = 'delivered', completed_at = coalesce(completed_at, now())
  where id = p_order_id;

  -- Midtrans's paid ledger entries become available to each seller here.
  insert into public.seller_wallet_ledger as current_entry(order_id, seller_id, amount, released_at)
  select oi.order_id, oi.seller_id, sum(oi.unit_price)::bigint, now()
  from public.order_items oi
  where oi.order_id = p_order_id
  group by oi.order_id, oi.seller_id
  on conflict (order_id, seller_id) do update
    set released_at = coalesce(current_entry.released_at, now());
end;
$$;

revoke all on function public.confirm_buyer_order_received(uuid) from public, anon;
grant execute on function public.confirm_buyer_order_received(uuid) to authenticated;

create or replace function public.release_due_seller_wallets()
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare
  v_released integer;
begin
  -- Ensure a missing ledger row is repaired before releasing due earnings.
  insert into public.seller_wallet_ledger(order_id, seller_id, amount)
  select oi.order_id, oi.seller_id, sum(oi.unit_price)::bigint
  from public.orders o
  join public.order_shipments s on s.order_id = o.id
  join public.order_items oi on oi.order_id = o.id and oi.seller_id = s.seller_id
  where o.payment_status = 'paid'
    and s.status = 'shipped'
    and s.auto_release_at <= now()
  group by oi.order_id, oi.seller_id
  on conflict (order_id, seller_id) do nothing;

  update public.seller_wallet_ledger l
  set released_at = now()
  from public.order_shipments s
  join public.orders o on o.id = s.order_id
  where l.order_id = s.order_id
    and l.seller_id = s.seller_id
    and l.released_at is null
    and o.payment_status = 'paid'
    and s.status = 'shipped'
    and s.auto_release_at <= now();

  get diagnostics v_released = row_count;
  return v_released;
end;
$$;

revoke all on function public.release_due_seller_wallets() from public, anon, authenticated;

create extension if not exists pg_cron with schema pg_catalog;
select cron.schedule(
  'seller-wallet-auto-release',
  '* * * * *',
  'select public.release_due_seller_wallets();'
);

notify pgrst, 'reload schema';
