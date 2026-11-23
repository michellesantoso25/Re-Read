-- Give marketplace listings a public shop identity without exposing private
-- profile fields through the profiles table's row policies.
alter table public.profiles
  add column if not exists shop_name text;

create or replace function public.get_public_seller_profiles(p_seller_ids uuid[])
returns table(id uuid, shop_name text, avatar_url text, city text)
language sql
stable
security definer
set search_path = public
as $$
  select
    p.id,
    coalesce(nullif(btrim(p.shop_name), ''), nullif(btrim(p.full_name), ''), 'Independent seller'),
    p.avatar_url,
    p.city
  from public.profiles p
  where p.id = any(p_seller_ids);
$$;

revoke all on function public.get_public_seller_profiles(uuid[])
  from public, anon;
grant execute on function public.get_public_seller_profiles(uuid[])
  to anon, authenticated;

notify pgrst, 'reload schema';
