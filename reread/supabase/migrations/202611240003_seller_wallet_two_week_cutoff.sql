-- Extend automatic seller wallet release from 72 hours to 14 days.
-- Existing, still-held shipment earnings receive the same 14-day window.
update public.order_shipments s
set auto_release_at = s.shipped_at + interval '14 days'
where s.status = 'shipped'
  and exists (
    select 1
    from public.seller_wallet_ledger l
    where l.order_id = s.order_id
      and l.seller_id = s.seller_id
      and l.released_at is null
  );

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

notify pgrst, 'reload schema';
