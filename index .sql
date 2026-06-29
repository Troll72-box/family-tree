-- ════════════════════════════════════════════════════════════════
--  FAMILY TREE — Supabase schema
--  Safe to re-run: drops existing policies before recreating them.
-- ════════════════════════════════════════════════════════════════

create extension if not exists pgcrypto;

-- ── Tables ───────────────────────────────────────────────────────

create table if not exists people (
  id               uuid primary key default gen_random_uuid(),
  created_at       timestamptz default now(),
  full_name        text not null,
  nicknames        text[] default '{}',
  birth_year       int,
  birth_place      text,
  current_location text,
  occupation       text,
  is_deceased      boolean default false,
  gender           text default 'unknown',
  notes            text,
  source           text,
  added_by         text,
  confidence       real default 1
);

create table if not exists relationships (
  id          uuid primary key default gen_random_uuid(),
  created_at  timestamptz default now(),
  from_id     uuid references people(id) on delete cascade,
  to_id       uuid references people(id) on delete cascade,
  type        text,
  label       text,
  confidence  real default 1
);

create table if not exists invites (
  id          uuid primary key default gen_random_uuid(),
  created_at  timestamptz default now(),
  token       text unique default encode(gen_random_bytes(8), 'hex'),
  label       text,
  used        boolean default false,
  used_at     timestamptz
);

create table if not exists interviews (
  id                uuid primary key default gen_random_uuid(),
  created_at        timestamptz default now(),
  respondent_name   text,
  relation_to_owner text,
  raw_answers       jsonb,
  parsed_data       jsonb,
  status            text default 'pending'
);

-- ── Row Level Security ───────────────────────────────────────────

alter table people        enable row level security;
alter table relationships enable row level security;
alter table invites        enable row level security;
alter table interviews     enable row level security;

-- Drop old policies if they exist, then recreate with unique names

drop policy if exists "read"   on people;
drop policy if exists "insert" on people;
drop policy if exists "update" on people;
drop policy if exists "delete" on people;
drop policy if exists "people_read"   on people;
drop policy if exists "people_insert" on people;
drop policy if exists "people_update" on people;
drop policy if exists "people_delete" on people;

create policy "people_read"   on people for select using (true);
create policy "people_insert" on people for insert with check (true);
create policy "people_update" on people for update using (true);
create policy "people_delete" on people for delete using (true);

drop policy if exists "read"   on relationships;
drop policy if exists "insert" on relationships;
drop policy if exists "delete" on relationships;
drop policy if exists "rels_read"   on relationships;
drop policy if exists "rels_insert" on relationships;
drop policy if exists "rels_delete" on relationships;

create policy "rels_read"   on relationships for select using (true);
create policy "rels_insert" on relationships for insert with check (true);
create policy "rels_delete" on relationships for delete using (true);

drop policy if exists "read"   on invites;
drop policy if exists "insert" on invites;
drop policy if exists "update" on invites;
drop policy if exists "inv_read"   on invites;
drop policy if exists "inv_insert" on invites;
drop policy if exists "inv_update" on invites;

create policy "inv_read"   on invites for select using (true);
create policy "inv_insert" on invites for insert with check (true);
create policy "inv_update" on invites for update using (true);

drop policy if exists "read"   on interviews;
drop policy if exists "insert" on interviews;
drop policy if exists "update" on interviews;
drop policy if exists "int_read"   on interviews;
drop policy if exists "int_insert" on interviews;
drop policy if exists "int_update" on interviews;

create policy "int_read"   on interviews for select using (true);
create policy "int_insert" on interviews for insert with check (true);
create policy "int_update" on interviews for update using (true);
