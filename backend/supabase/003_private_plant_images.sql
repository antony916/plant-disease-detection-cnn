-- Private PlantCare image storage.
-- Apply after the initial schema when a real Supabase project is activated.

insert into storage.buckets (id, name, public)
values ('plant-images', 'plant-images', false)
on conflict (id) do update set public = false;

create policy "users upload own plant images"
on storage.objects
for insert
to authenticated
with check (
  bucket_id = 'plant-images'
  and (storage.foldername(name))[1] = auth.uid()::text
);

create policy "users read own plant images"
on storage.objects
for select
to authenticated
using (
  bucket_id = 'plant-images'
  and (storage.foldername(name))[1] = auth.uid()::text
);

create policy "users update own plant images"
on storage.objects
for update
to authenticated
using (
  bucket_id = 'plant-images'
  and (storage.foldername(name))[1] = auth.uid()::text
)
with check (
  bucket_id = 'plant-images'
  and (storage.foldername(name))[1] = auth.uid()::text
);

create policy "users delete own plant images"
on storage.objects
for delete
to authenticated
using (
  bucket_id = 'plant-images'
  and (storage.foldername(name))[1] = auth.uid()::text
);
