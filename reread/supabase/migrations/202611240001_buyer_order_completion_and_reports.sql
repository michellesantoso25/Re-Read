alter table public.orders
  add column if not exists completed_at timestamptz;

alter table public.order_shipments
  add column if not exists delivered_at timestamptz;

create table if not exists public.order_issue_reports (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders(id) on delete cascade,
  buyer_id uuid not null references auth.users(id) on delete cascade,
  description text not null check (char_length(btrim(description)) between 10 and 2000),
  status text not null default 'open' check (status in ('open', 'reviewing', 'resolved', 'closed')),
  created_at timestamptz not null default now()
);

alter table public.order_issue_reports enable row level security;
drop policy if exists "Buyers can read their order issue reports" on public.order_issue_reports;
create policy "Buyers can read their order issue reports" on public.order_issue_reports
  for select to authenticated using (buyer_id = auth.uid());
grant select on public.order_issue_reports to authenticated;

create or replace function public.confirm_buyer_order_received(p_order_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_buyer_id uuid := auth.uid();
begin
  if v_buyer_id is null then raise exception 'Sign in as the buyer first'; end if;

  perform 1 from public.orders o
  where o.id = p_order_id and o.buyer_id = v_buyer_id and o.payment_status = 'paid'
  for update;
  if not found then raise exception 'Paid order not found for this buyer'; end if;

  if not exists (select 1 from public.order_items oi where oi.order_id = p_order_id) or exists (
    select 1
    from public.order_items oi
    where oi.order_id = p_order_id
      and not exists (
        select 1 from public.order_shipments s
        where s.order_id = p_order_id and s.seller_id = oi.seller_id
      )
  ) then
    raise exception 'Wait until every seller has shipped this order';
  end if;

  update public.order_shipments
  set status = 'delivered', delivered_at = coalesce(delivered_at, now())
  where order_id = p_order_id and status <> 'delivered';

  update public.orders
  set status = 'delivered', completed_at = coalesce(completed_at, now())
  where id = p_order_id;
end;
$$;

revoke all on function public.confirm_buyer_order_received(uuid) from public, anon;
grant execute on function public.confirm_buyer_order_received(uuid) to authenticated;

create or replace function public.report_buyer_order_issue(
  p_order_id uuid,
  p_description text
) returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_buyer_id uuid := auth.uid();
  v_report_id uuid;
begin
  if v_buyer_id is null then raise exception 'Sign in as the buyer first'; end if;
  if char_length(btrim(coalesce(p_description, ''))) not between 10 and 2000 then
    raise exception 'Describe the issue in 10 to 2000 characters';
  end if;
  if not exists (
    select 1 from public.orders o
    where o.id = p_order_id and o.buyer_id = v_buyer_id and o.payment_status = 'paid'
  ) then
    raise exception 'Paid order not found for this buyer';
  end if;

  insert into public.order_issue_reports(order_id, buyer_id, description)
  values (p_order_id, v_buyer_id, btrim(p_description))
  returning id into v_report_id;
  return v_report_id;
end;
$$;

revoke all on function public.report_buyer_order_issue(uuid, text) from public, anon;
grant execute on function public.report_buyer_order_issue(uuid, text) to authenticated;

notify pgrst, 'reload schema';
