-- Ensure the complete Midtrans checkout schema exists even when these tables
-- were created before the checkout migrations. This is intentionally additive.

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

alter table public.order_items
  add column if not exists order_id uuid references public.orders(id) on delete cascade,
  add column if not exists book_id text,
  add column if not exists seller_id uuid references auth.users(id) on delete restrict,
  add column if not exists title text,
  add column if not exists unit_price bigint,
  add column if not exists created_at timestamptz not null default now();

alter table public.seller_wallet_ledger
  add column if not exists order_id uuid references public.orders(id) on delete restrict,
  add column if not exists seller_id uuid references auth.users(id) on delete restrict,
  add column if not exists amount bigint,
  add column if not exists created_at timestamptz not null default now();

create unique index if not exists orders_midtrans_order_id_uidx
  on public.orders(midtrans_order_id)
  where midtrans_order_id is not null;

create unique index if not exists seller_wallet_ledger_order_seller_uidx
  on public.seller_wallet_ledger(order_id, seller_id)
  where order_id is not null and seller_id is not null;

grant select on table public.books to service_role;
grant usage on schema public to service_role;
grant select, insert, update on table public.orders to service_role;
grant select, insert on table public.order_items to service_role;
grant select, insert on table public.seller_wallet_ledger to service_role;
notify pgrst, 'reload schema';
