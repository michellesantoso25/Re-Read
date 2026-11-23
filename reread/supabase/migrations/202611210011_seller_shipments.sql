create table if not exists public.order_shipments (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders(id) on delete cascade,
  seller_id uuid not null references auth.users(id) on delete restrict,
  courier text not null,
  tracking_number text not null,
  status text not null default 'shipped',
  created_at timestamptz not null default now(),
  shipped_at timestamptz not null default now(),
  unique (order_id, seller_id),
  check (char_length(courier) between 2 and 80),
  check (char_length(tracking_number) between 5 and 100),
  check (status in ('shipped', 'delivered'))
);

alter table public.order_shipments enable row level security;

drop policy if exists "Sellers can read their shipments" on public.order_shipments;
create policy "Sellers can read their shipments" on public.order_shipments
  for select to authenticated using (seller_id = auth.uid());

drop policy if exists "Buyers can read shipments for their orders" on public.order_shipments;
create policy "Buyers can read shipments for their orders" on public.order_shipments
  for select to authenticated using (
    exists (
      select 1 from public.orders o
      where o.id = order_id and o.buyer_id = auth.uid()
    )
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
      and oi.seller_id = v_seller_id
  ) then
    raise exception 'Paid order not found for this seller';
  end if;

  insert into public.order_shipments(order_id, seller_id, courier, tracking_number)
  values (p_order_id, v_seller_id, trim(p_courier), trim(p_tracking_number))
  on conflict (order_id, seller_id) do update
    set courier = excluded.courier,
        tracking_number = excluded.tracking_number,
        status = 'shipped',
        shipped_at = now();
end;
$$;

revoke all on function public.register_seller_shipment(uuid, text, text)
  from public, anon;
grant execute on function public.register_seller_shipment(uuid, text, text)
  to authenticated;

grant select on table public.order_shipments to authenticated;

notify pgrst, 'reload schema';
