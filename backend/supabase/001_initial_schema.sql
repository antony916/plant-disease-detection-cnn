-- PlantCare AI cloud data foundation.
-- This migration is prepared for Supabase/Postgres.
-- It is not applied to a live project until the project credentials are connected.

create extension if not exists pgcrypto;

create table if not exists public.gardens (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  name text not null default 'My Garden',
  location_enabled boolean not null default false,
  latitude double precision,
  longitude double precision,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.plants (
  id uuid primary key default gen_random_uuid(),
  garden_id uuid not null references public.gardens(id) on delete cascade,
  owner_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  species text,
  category text,
  health_status text not null default 'unknown',
  image_url text,
  sunlight_hours numeric,
  pot_size text,
  soil_type text,
  location text,
  notes text,
  watering_interval_days integer not null default 2,
  last_watered_at timestamptz,
  next_watering_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.diagnoses (
  id uuid primary key default gen_random_uuid(),
  plant_id uuid references public.plants(id) on delete set null,
  owner_id uuid not null references auth.users(id) on delete cascade,
  image_url text,
  plant_name text,
  condition text not null,
  confidence numeric not null check (confidence >= 0 and confidence <= 1),
  explanation text,
  needs_expert_review boolean not null default false,
  model_version text,
  created_at timestamptz not null default now()
);

create table if not exists public.garden_tasks (
  id uuid primary key default gen_random_uuid(),
  plant_id uuid not null references public.plants(id) on delete cascade,
  owner_id uuid not null references auth.users(id) on delete cascade,
  task_type text not null,
  title text not null,
  subtitle text,
  due_at timestamptz not null,
  completed_at timestamptz,
  created_at timestamptz not null default now()
);

create table if not exists public.family_members (
  id uuid primary key default gen_random_uuid(),
  garden_id uuid not null references public.gardens(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  role text not null default 'member',
  created_at timestamptz not null default now(),
  unique(garden_id, user_id)
);

create table if not exists public.device_tokens (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  token text not null,
  platform text not null,
  enabled boolean not null default true,
  updated_at timestamptz not null default now(),
  unique(user_id, token)
);

create index if not exists plants_garden_id_idx on public.plants(garden_id);
create index if not exists diagnoses_plant_id_idx on public.diagnoses(plant_id);
create index if not exists diagnoses_owner_id_idx on public.diagnoses(owner_id);
create index if not exists garden_tasks_due_at_idx on public.garden_tasks(owner_id, due_at);
create index if not exists device_tokens_user_id_idx on public.device_tokens(user_id);

alter table public.gardens enable row level security;
alter table public.plants enable row level security;
alter table public.diagnoses enable row level security;
alter table public.garden_tasks enable row level security;
alter table public.family_members enable row level security;
alter table public.device_tokens enable row level security;

-- Initial owner policies. Family-sharing policies will be expanded after the
-- membership/role workflow is implemented.
create policy "owners manage gardens"
on public.gardens for all
using (owner_id = auth.uid())
with check (owner_id = auth.uid());

create policy "owners manage plants"
on public.plants for all
using (owner_id = auth.uid())
with check (owner_id = auth.uid());

create policy "owners manage diagnoses"
on public.diagnoses for all
using (owner_id = auth.uid())
with check (owner_id = auth.uid());

create policy "owners manage tasks"
on public.garden_tasks for all
using (owner_id = auth.uid())
with check (owner_id = auth.uid());

create policy "users manage own family membership"
on public.family_members for all
using (user_id = auth.uid())
with check (user_id = auth.uid());

create policy "users manage own device tokens"
on public.device_tokens for all
using (user_id = auth.uid())
with check (user_id = auth.uid());
