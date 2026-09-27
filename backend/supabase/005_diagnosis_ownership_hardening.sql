-- PlantCare AI diagnosis ownership hardening.
-- Apply after 004_family_sharing_hardening.sql.
--
-- Prevents a signed-in user from attaching a diagnosis to another user's
-- plant while preserving shared-garden editor access.

drop policy if exists "owners manage diagnoses" on public.diagnoses;
drop policy if exists "owners view own diagnoses" on public.diagnoses;
drop policy if exists "shared members view diagnoses" on public.diagnoses;
drop policy if exists "shared editors create diagnoses" on public.diagnoses;
drop policy if exists "owners create diagnoses for own plants" on public.diagnoses;
drop policy if exists "owners update own diagnoses" on public.diagnoses;
drop policy if exists "owners delete own diagnoses" on public.diagnoses;
drop policy if exists "shared editors update diagnoses" on public.diagnoses;
drop policy if exists "shared editors delete diagnoses" on public.diagnoses;

create policy "owners view own diagnoses"
on public.diagnoses for select
to authenticated
using (owner_id = auth.uid());

create policy "shared members view diagnoses"
on public.diagnoses for select
to authenticated
using (
  public.is_garden_member(
    (select p.garden_id from public.plants p where p.id = plant_id)
  )
);

create policy "owners create diagnoses for own plants"
on public.diagnoses for insert
to authenticated
with check (
  owner_id = auth.uid()
  and (
    plant_id is null
    or exists (
      select 1
      from public.plants p
      where p.id = plant_id
        and p.owner_id = auth.uid()
    )
  )
);

create policy "shared editors create diagnoses"
on public.diagnoses for insert
to authenticated
with check (
  plant_id is not null
  and public.can_edit_garden(
    (select p.garden_id from public.plants p where p.id = plant_id)
  )
  and owner_id = (
    select g.owner_id
    from public.gardens g
    join public.plants p on p.garden_id = g.id
    where p.id = plant_id
  )
);

create policy "owners update own diagnoses"
on public.diagnoses for update
to authenticated
using (owner_id = auth.uid())
with check (
  owner_id = auth.uid()
  and (
    plant_id is null
    or exists (
      select 1
      from public.plants p
      where p.id = plant_id
        and p.owner_id = auth.uid()
    )
  )
);

create policy "owners delete own diagnoses"
on public.diagnoses for delete
to authenticated
using (owner_id = auth.uid());

create policy "shared editors update diagnoses"
on public.diagnoses for update
to authenticated
using (
  public.can_edit_garden(
    (select p.garden_id from public.plants p where p.id = plant_id)
  )
  and owner_id = (
    select g.owner_id
    from public.gardens g
    join public.plants p on p.garden_id = g.id
    where p.id = plant_id
  )
)
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

create policy "shared editors delete diagnoses"
on public.diagnoses for delete
to authenticated
using (
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
