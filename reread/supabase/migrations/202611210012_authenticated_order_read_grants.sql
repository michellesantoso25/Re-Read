-- RLS policies filter rows; these table grants let authenticated PostgREST
-- users issue the corresponding SELECT requests in seller/buyer dashboards.
grant select on table public.orders to authenticated;
grant select on table public.order_items to authenticated;
grant select on table public.seller_wallet_ledger to authenticated;
grant select on table public.order_shipments to authenticated;

notify pgrst, 'reload schema';
