-- Family-sharing schema and RLS hardening.
-- Apply after 001_initial_schema.sql and before activating cloud sharing.

alter table public.family_members
  alter column user_id drop not null;

alter table public.family_members
  add column if not exists invite_email text,
  add column if not exists invited_by uuid references auth.users(id) on delete set null,
  add column if not exists status text not null default 'active';

update public.family_members
set role = 'viewer'
where role is null or role = 'member';

alter table public.family_members
  alter column role set default 'viewer';

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

create index if not exists family_members_garden_status_idx
  on public.family_members(garden_id, status);

create index if not exists family_members_invite_email_idx
  on public.family_members(invite_email);

create or replace function public.is_garden_member(target_garden_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
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
stable
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

create or replace function public.is_garden_owner(target_garden_id uuid)
returns boolean
language sql
stable
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

drop policy if exists "users manage own family membership" on public.family_members;

create policy "family members can view own membership"
on public.family_members for select
to authenticated
using (
  user_id = auth.uid()
  or public.is_garden_owner(garden_id)
);

create policy "garden owners create family membership"
on public.family_members for insert
to authenticated
with check (
  public.is_garden_owner(garden_id)
  and invited_by = auth.uid()
);

create policy "garden owners update family membership"
on public.family_members for update
to authenticated
using (public.is_garden_owner(garden_id))
with check (public.is_garden_owner(garden_id));

create policy "garden owners remove family membership"
on public.family_members for delete
to authenticated
using (public.is_garden_owner(garden_id));

drop policy if exists "owners manage gardens" on public.gardens;
create policy "owners manage gardens"
on public.gardens for all
to authenticated
using (owner_id = auth.uid())
with check (owner_id = auth.uid());

create policy "shared members view gardens"
on public.gardens for select
to authenticated
using (public.is_garden_member(id));

drop policy if exists "owners manage plants" on public.plants;
create policy "owners manage plants"
on public.plants for all
to authenticated
using (owner_id = auth.uid())
with check (owner_id = auth.uid());

create policy "shared members view plants"
on public.plants for select
to authenticated
using (public.is_garden_member(garden_id));

create policy "shared editors insert plants"
on public.plants for insert
to authenticated
with check (
  public.can_edit_garden(garden_id)
  and owner_id = (select g.owner_id from public.gardens g where g.id = garden_id)
);

create policy "shared editors update plants"
on public.plants for update
to authenticated
using (public.can_edit_garden(garden_id))
with check (
  public.can_edit_garden(garden_id)
  and owner_id = (select g.owner_id from public.gardens g where g.id = garden_id)
);

create policy "shared editors delete plants"
on public.plants for delete
to authenticated
using (public.can_edit_garden(garden_id));

drop policy if exists "owners manage tasks" on public.garden_tasks;
create policy "owners manage tasks"
on public.garden_tasks for all
to authenticated
using (owner_id = auth.uid())
with check (owner_id = auth.uid());

create policy "shared members view tasks"
on public.garden_tasks for select
to authenticated
using (public.is_garden_member((select p.garden_id from public.plants p where p.id = plant_id)));

create policy "shared editors insert tasks"
on public.garden_tasks for insert
to authenticated
with check (
  public.can_edit_garden((select p.garden_id from public.plants p where p.id = plant_id))
  and owner_id = (
    select g.owner_id
    from public.gardens g
    join public.plants p on p.garden_id = g.id
    where p.id = plant_id
  )
);

create policy "shared editors update tasks"
on public.garden_tasks for update
to authenticated
using (
  public.can_edit_garden((select p.garden_id from public.plants p where p.id = plant_id))
)
with check (
  public.can_edit_garden((select p.garden_id from public.plants p where p.id = plant_id))
  and owner_id = (
    select g.owner_id
    from public.gardens g
    join public.plants p on p.garden_id = g.id
    where p.id = plant_id
  )
);

create policy "shared editors delete tasks"
on public.garden_tasks for delete
to authenticated
using (
  public.can_edit_garden((select p.garden_id from public.plants p where p.id = plant_id))
);

drop policy if exists "owners manage diagnoses" on public.diagnoses;
create policy "owners manage diagnoses"
on public.diagnoses for all
to authenticated
using (owner_id = auth.uid())
with check (owner_id = auth.uid());

create policy "shared members view diagnoses"
on public.diagnoses for select
to authenticated
using (
  public.is_garden_member(
    (select p.garden_id from public.plants p where p.id = plant_id)
  )
);

create policy "shared editors create diagnoses"
on public.diagnoses for insert
to authenticated
with check (
  public.can_edit_garden(
    (select p.garden_id from public.plants p where p.id = plant_id)
  )
  and owner_id = (
    select g.owner_id
    from public.gardens g
    join public.plants p on p.garden_id = g.id
    where p.id = plant_id
  )
);
