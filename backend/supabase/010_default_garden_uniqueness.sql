-- Keep exactly one default garden for each owner. Older duplicate gardens are
-- preserved as non-default gardens; the oldest row wins deterministically.
alter table public.gardens
  add column if not exists is_default boolean not null default true;

alter table public.gardens
  alter column is_default set default true;

with ranked_gardens as (
  select
    id,
    row_number() over (partition by owner_id order by created_at, id) as position
  from public.gardens
)
update public.gardens as garden
set is_default = (ranked_gardens.position = 1)
from ranked_gardens
where garden.id = ranked_gardens.id
  and garden.is_default is distinct from (ranked_gardens.position = 1);

create unique index if not exists gardens_single_default_per_owner_idx
  on public.gardens (owner_id)
  where is_default;
