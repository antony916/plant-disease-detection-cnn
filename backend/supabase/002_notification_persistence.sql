-- PlantCare AI notification persistence.
-- Apply after 001_initial_schema.sql when a real Supabase project is activated.

create table if not exists public.notification_preferences (
  user_id uuid primary key references auth.users(id) on delete cascade,
  watering_reminders boolean not null default true,
  care_alerts boolean not null default false,
  diagnosis_alerts boolean not null default false,
  quiet_hours_enabled boolean not null default true,
  quiet_start_hour integer not null default 22 check (quiet_start_hour between 0 and 23),
  quiet_end_hour integer not null default 7 check (quiet_end_hour between 0 and 23),
  updated_at timestamptz not null default now()
);

create table if not exists public.notifications (
  id text primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  plant_id uuid references public.plants(id) on delete set null,
  notification_type text not null,
  title text not null,
  body text not null,
  read boolean not null default false,
  created_at timestamptz not null default now()
);

create index if not exists notifications_user_created_idx
  on public.notifications(user_id, created_at desc);

create index if not exists notifications_plant_id_idx
  on public.notifications(plant_id);

alter table public.notification_preferences enable row level security;
alter table public.notifications enable row level security;

create policy "users manage own notification preferences"
on public.notification_preferences for all
using (user_id = auth.uid())
with check (user_id = auth.uid());

create policy "users manage own notifications"
on public.notifications for all
using (user_id = auth.uid())
with check (user_id = auth.uid());
