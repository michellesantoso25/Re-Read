-- Persist pending and terminal Midtrans notifications, and release reserved
-- copies for failed transactions. The paid path remains idempotent per seller.
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
  v_status text := lower(coalesce(p_transaction_status, ''));
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
      set status = 'paid', payment_status = 'paid', paid_at = coalesce(paid_at, now()),
          stock_reserved = false
      where id = v_order.id;
    end if;
  elsif v_order.payment_status <> 'paid' and v_status in ('expire', 'cancel', 'deny', 'failure') then
    perform public.release_order_stock(v_order.id);
    update public.orders
    set status = v_status, payment_status = v_status
    where id = v_order.id;
  elsif v_order.payment_status = 'pending' and v_status = 'pending' then
    update public.orders
    set status = 'pending', payment_status = 'pending'
    where id = v_order.id;
  end if;
end;
$$;

revoke all on function public.record_midtrans_notification(text, bigint, text, boolean)
  from public, anon, authenticated;
grant execute on function public.record_midtrans_notification(text, bigint, text, boolean)
  to service_role;

notify pgrst, 'reload schema';
