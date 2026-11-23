-- Avoid recursive RLS evaluation between orders and order_items policies.
-- This helper can only answer whether the current user owns the given order.
create or replace function public.is_current_user_order_buyer(p_order_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.orders o
    where o.id = p_order_id
      and o.buyer_id = auth.uid()
  );
$$;

revoke all on function public.is_current_user_order_buyer(uuid)
  from public, anon;
grant execute on function public.is_current_user_order_buyer(uuid)
  to authenticated;

drop policy if exists "Buyers can read their order items" on public.order_items;
create policy "Buyers can read their order items" on public.order_items
  for select to authenticated
  using (public.is_current_user_order_buyer(order_id));

notify pgrst, 'reload schema';
