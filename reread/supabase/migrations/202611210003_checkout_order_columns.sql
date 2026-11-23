-- The existing orders table predates the checkout fields. CREATE TABLE IF NOT
-- EXISTS does not alter an existing table, so add these columns explicitly.
alter table public.orders
  add column if not exists buyer_id uuid references auth.users(id) on delete restrict,
  add column if not exists midtrans_order_id text,
  add column if not exists status text not null default 'pending',
  add column if not exists payment_status text not null default 'pending',
  add column if not exists subtotal bigint not null default 0,
  add column if not exists shipping_total bigint not null default 0,
  add column if not exists discount bigint not null default 0,
  add column if not exists platform_subsidy bigint not null default 0,
  add column if not exists gross_amount bigint not null default 1,
  add column if not exists voucher_code text,
  add column if not exists delivery_address jsonb not null default '{}'::jsonb,
  add column if not exists snap_token text,
  add column if not exists redirect_url text,
  add column if not exists created_at timestamptz not null default now(),
  add column if not exists paid_at timestamptz;

create unique index if not exists orders_midtrans_order_id_uidx
  on public.orders(midtrans_order_id)
  where midtrans_order_id is not null;

notify pgrst, 'reload schema';
