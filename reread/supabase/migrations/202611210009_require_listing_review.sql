-- Authenticated sellers cannot approve their own listings. Trusted server-side
-- moderation (using the service role) can set qc_status to approved/rejected.
create or replace function public.require_marketplace_book_review()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if auth.role() = 'authenticated' then
    new.qc_status := 'pending_review';
  end if;
  return new;
end;
$$;

revoke all on function public.require_marketplace_book_review() from public, anon, authenticated;

drop trigger if exists require_marketplace_book_review on public.books;
create trigger require_marketplace_book_review
before insert or update
on public.books
for each row execute function public.require_marketplace_book_review();
