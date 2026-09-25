-- PlantCare AI family-sharing foundation.
-- Adds role-aware membership state and expands garden-data RLS for active family members.

alter table public.family_members
  alter column user_id drop not null;

alter table public.family_members
  add column if not exists invite_email text,
  add column if not exists invited_by uuid references auth.users(id) on delete set null,
  add column if not exists status text not null default 'active';

alter table public.family_members
  drop constraint if exists family_members_role_check;

alter table public.family_members
  add constraint family_members_role_check
  check (role in ('owner', 'editor', 'viewer'));

alter table public.family_members
  drop constraint if exists family_members_status_check;

alter table public.family_members
  add constraint family_members_status_check
  check (status in ('pending', 'active', 'removed'));

create index if not exists family_members_user_status_idx
  on public.family_members(user_id, status);

create index if not exists family_members_email_status_idx
  on public.family_members(lower(invite_email), status);

create or replace function public.is_garden_member(target_garden_id uuid)
returns boolean
language sql
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.gardens g
    where g.id = target_garden_id
      and g.owner_id = auth.uid()
  )
  or exists (
    select 1
    from public.family_members fm
    where fm.garden_id = target_garden_id
      and fm.user_id = auth.uid()
      and fm.status = 'active'
  );
$$;

create or replace function public.can_edit_garden(target_garden_id uuid)
returns boolean
language sql
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.gardens g
    where g.id = target_garden_id
      and g.owner_id = auth.uid()
  )
  or exists (
    select 1
    from public.family_members fm
    where fm.garden_id = target_garden_id
      and fm.user_id = auth.uid()
      and fm.status = 'active'
      and fm.role = 'editor'
  );
$$;

create or replace function public.can_manage_family(target_garden_id uuid)
returns boolean
language sql
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.gardens g
    where g.id = target_garden_id
      and g.owner_id = auth.uid()
  );
$$;

drop policy if exists "owners manage gardens" on public.gardens;
drop policy if exists "owners manage plants" on public.plants;
drop policy if exists "owners manage diagnoses" on public.diagnoses;
drop policy if exists "owners manage tasks" on public.garden_tasks;
drop policy if exists "users manage own family membership" on public.family_members;

create policy "members can view gardens"
on public.gardens for select
using (public.is_garden_member(id));

create policy "owners manage gardens"
on public.gardens for insert
with check (owner_id = auth.uid());

create policy "owners manage garden settings"
on public.gardens for update
using (owner_id = auth.uid())
with check (owner_id = auth.uid());

create policy "owners delete gardens"
on public.gardens for delete
using (owner_id = auth.uid());

create policy "members can view plants"
on public.plants for select
using (public.is_garden_member(garden_id));

create policy "owners and editors add plants"
on public.plants for insert
with check (
  public.can_edit_garden(garden_id)
  and owner_id = (select g.owner_id from public.gardens g where g.id = garden_id)
);

create policy "owners and editors update plants"
on public.plants for update
using (public.can_edit_garden(garden_id))
with check (
  public.can_edit_garden(garden_id)
  and owner_id = (select g.owner_id from public.gardens g where g.id = garden_id)
);

create policy "owners and editors delete plants"
on public.plants for delete
using (public.can_edit_garden(garden_id));

create policy "members can view diagnoses"
on public.diagnoses for select
using (
  plant_id is not null
  and public.is_garden_member(
    (select p.garden_id from public.plants p where p.id = plant_id)
  )
);

create policy "owners and editors add diagnoses"
on public.diagnoses for insert
with check (
  public.can_edit_garden(
    (select p.garden_id from public.plants p where p.id = plant_id)
  )
  and owner_id = (select g.owner_id from public.gardens g
                  join public.plants p on p.garden_id = g.id
                  where p.id = plant_id)
);

create policy "members can view tasks"
on public.garden_tasks for select
using (public.is_garden_member(
  (select p.garden_id from public.plants p where p.id = plant_id)
));

create policy "owners and editors manage tasks"
on public.garden_tasks for all
using (public.can_edit_garden(
  (select p.garden_id from public.plants p where p.id = plant_id)
))
with check (
  public.can_edit_garden(
    (select p.garden_id from public.plants p where p.id = plant_id)
  )
  and owner_id = (select g.owner_id from public.gardens g
                  join public.plants p on p.garden_id = g.id
                  where p.id = plant_id)
);

create policy "members can view active family membership"
on public.family_members for select
using (
  public.is_garden_member(garden_id)
  and status = 'active'
);

create policy "owners can view family membership"
on public.family_members for select
using (public.can_manage_family(garden_id));

create policy "owners manage family membership"
on public.family_members for insert
with check (public.can_manage_family(garden_id));

create policy "owners update family membership"
on public.family_members for update
using (public.can_manage_family(garden_id))
with check (public.can_manage_family(garden_id));

create policy "owners delete family membership"
on public.family_members for delete
using (public.can_manage_family(garden_id));

-- Pending invites do not grant access. They become active only after a user is
-- associated with the membership row and status is set to active.
