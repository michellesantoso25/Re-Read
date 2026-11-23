-- Let sellers read only the orders and items attached to their own listings.
drop policy if exists "Sellers can read their order items" on public.order_items;
create policy "Sellers can read their order items" on public.order_items
  for select to authenticated using (seller_id = auth.uid());

drop policy if exists "Sellers can read their orders" on public.orders;
create policy "Sellers can read their orders" on public.orders
  for select to authenticated using (
    exists (
      select 1 from public.order_items oi
      where oi.order_id = orders.id and oi.seller_id = auth.uid()
    )
  );
