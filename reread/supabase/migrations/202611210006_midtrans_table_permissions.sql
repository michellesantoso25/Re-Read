-- Edge Functions use the service_role key to create and update checkout rows.
grant usage on schema public to service_role;
grant select on table public.books to service_role;
grant select, insert, update on table public.orders to service_role;
grant select, insert on table public.order_items to service_role;
grant select, insert on table public.seller_wallet_ledger to service_role;

notify pgrst, 'reload schema';
