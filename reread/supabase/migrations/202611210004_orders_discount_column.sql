-- Compatibility migration for databases where the pre-existing orders table
-- caused the original CREATE TABLE IF NOT EXISTS to skip checkout columns.
alter table public.orders
  add column if not exists discount bigint not null default 0,
  add column if not exists shipping_total bigint not null default 0,
  add column if not exists platform_subsidy bigint not null default 0,
  add column if not exists gross_amount bigint not null default 1,
  add column if not exists voucher_code text,
  add column if not exists delivery_address jsonb not null default '{}'::jsonb;

notify pgrst, 'reload schema';
