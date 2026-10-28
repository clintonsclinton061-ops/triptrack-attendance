-- Run this entire script in Supabase Dashboard > SQL Editor > New query.
create extension if not exists pgcrypto;

create table if not exists public.trip_admins (
  user_id uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);

create table if not exists public.travellers (
  id uuid primary key default gen_random_uuid(),
  full_name text not null check (char_length(full_name) between 2 and 100),
  phone text not null check (char_length(phone) between 5 and 25),
  party_size integer not null default 1 check (party_size between 1 and 10),
  notes text check (notes is null or char_length(notes) <= 500),
  checked_in_at timestamptz,
  created_at timestamptz not null default now()
);

create unique index if not exists travellers_phone_unique on public.travellers (phone);
alter table public.trip_admins enable row level security;
alter table public.travellers enable row level security;

-- Visitors can submit registrations, but cannot read or edit the traveller list.
drop policy if exists "Public can register travellers" on public.travellers;
create policy "Public can register travellers" on public.travellers
  for insert to anon, authenticated with check (true);

-- Only user IDs explicitly added to trip_admins can see and manage registrations.
drop policy if exists "Admins can view travellers" on public.travellers;
create policy "Admins can view travellers" on public.travellers
  for select to authenticated using (
    exists (select 1 from public.trip_admins a where a.user_id = auth.uid())
  );
drop policy if exists "Admins can update checkin" on public.travellers;
create policy "Admins can update checkin" on public.travellers
  for update to authenticated using (
    exists (select 1 from public.trip_admins a where a.user_id = auth.uid())
  ) with check (
    exists (select 1 from public.trip_admins a where a.user_id = auth.uid())
  );

-- An admin can only read their own admin record. Admin membership must be added
-- from the SQL Editor by the project owner; there is no public self-registration for admins.
drop policy if exists "Admins can verify own membership" on public.trip_admins;
create policy "Admins can verify own membership" on public.trip_admins
  for select to authenticated using (user_id = auth.uid());

-- Enable realtime updates for the admin dashboard.
do $$ begin
  alter publication supabase_realtime add table public.travellers;
exception when duplicate_object then null;
when undefined_object then null;
end $$;
