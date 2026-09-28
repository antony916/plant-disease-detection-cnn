alter table public.diagnoses
  add column if not exists capability text not null default 'disease',
  add column if not exists model_id text not null default 'unknown',
  add column if not exists top_predictions jsonb not null default '[]'::jsonb;

create index if not exists diagnoses_capability_idx
  on public.diagnoses(capability);