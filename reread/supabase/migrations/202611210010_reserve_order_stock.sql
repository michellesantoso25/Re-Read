-- Reserve unique book copies while a Midtrans payment is pending. A paid
-- reservation is consumed; a cancelled/expired/denied payment releases it.
alter table public.orders
  add column if not exists stock_reserved boolean not null default false;

create or replace function public.reserve_order_stock(p_order_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_order public.orders%rowtype;
  v_item record;
  v_stock integer;
begin
  select * into v_order
  from public.orders
  where id = p_order_id
  for update;

  if not found then raise exception 'Order not found'; end if;
  if v_order.payment_status <> 'pending' or v_order.stock_reserved then
    raise exception 'Order cannot reserve stock in its current state';
  end if;

  if not exists (select 1 from public.order_items where order_id = p_order_id) then
    raise exception 'Order has no items';
  end if;

  for v_item in
    select book_id, seller_id
    from public.order_items
    where order_id = p_order_id
    order by book_id
  loop
    select b.stock into v_stock
    from public.books b
    where b.id::text = v_item.book_id
      and b.seller_id = v_item.seller_id
      and b.qc_status = 'approved'
    for update;

    if not found or v_stock is null or v_stock < 1 then
      raise exception 'A listing is no longer available';
    end if;

    update public.books
    set stock = v_stock - 1
    where id::text = v_item.book_id;
  end loop;

  update public.orders set stock_reserved = true where id = p_order_id;
end;
$$;

create or replace function public.release_order_stock(p_order_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_reserved boolean;
  v_item record;
begin
  select stock_reserved into v_reserved
  from public.orders
  where id = p_order_id
  for update;

  if not found or not v_reserved then return; end if;

  for v_item in
    select book_id, seller_id
    from public.order_items
    where order_id = p_order_id
    order by book_id
  loop
    update public.books
    set stock = coalesce(stock, 0) + 1
    where id::text = v_item.book_id
      and seller_id = v_item.seller_id;
  end loop;

  update public.orders set stock_reserved = false where id = p_order_id;
end;
$$;

revoke all on function public.reserve_order_stock(uuid)
  from public, anon, authenticated;
revoke all on function public.release_order_stock(uuid)
  from public, anon, authenticated;
grant execute on function public.reserve_order_stock(uuid) to service_role;
grant execute on function public.release_order_stock(uuid) to service_role;

create or replace function public.record_midtrans_notification(
  p_midtrans_order_id text,
  p_gross_amount bigint,
  p_transaction_status text,
  p_paid boolean
) returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_order public.orders%rowtype;
begin
  select * into v_order
  from public.orders
  where midtrans_order_id = p_midtrans_order_id
  for update;

  if not found then raise exception 'Order not found'; end if;
  if p_gross_amount <> v_order.gross_amount then
    raise exception 'Notification amount does not match order';
  end if;

  if p_paid then
    if v_order.payment_status <> 'paid' then
      if not v_order.stock_reserved then
        raise exception 'Paid order does not have a stock reservation';
      end if;

      insert into public.seller_wallet_ledger(order_id, seller_id, amount)
      select oi.order_id, oi.seller_id, sum(oi.unit_price)
      from public.order_items oi
      where oi.order_id = v_order.id
      group by oi.order_id, oi.seller_id
      on conflict (order_id, seller_id) do nothing;

      update public.orders
      set status = 'paid', payment_status = 'paid', paid_at = now(),
          stock_reserved = false
      where id = v_order.id;
    end if;
  elsif p_transaction_status in ('expire', 'cancel', 'deny')
    and v_order.payment_status <> 'paid' then
    perform public.release_order_stock(v_order.id);
    update public.orders
    set status = p_transaction_status, payment_status = p_transaction_status
    where id = v_order.id;
  end if;
end;
$$;

revoke all on function public.record_midtrans_notification(text, bigint, text, boolean)
  from public, anon, authenticated;
grant execute on function public.record_midtrans_notification(text, bigint, text, boolean)
  to service_role;

notify pgrst, 'reload schema';
