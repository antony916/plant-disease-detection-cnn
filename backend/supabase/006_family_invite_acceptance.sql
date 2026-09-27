-- Secure family invitation acceptance.
--
-- The client must not be able to update arbitrary invitation columns while
-- claiming an invitation. Acceptance is performed by a narrowly scoped RPC.

drop policy if exists "invitees accept own pending invitations" on public.family_members;

create or replace function public.accept_family_invitation(p_membership_id uuid)
returns public.family_members
language plpgsql
security definer
set search_path = public
as $$
declare
  target public.family_members;
  caller_email text;
begin
  caller_email := lower(trim(auth.jwt() ->> 'email'));

  if auth.uid() is null or caller_email is null or caller_email = '' then
    raise exception 'Authenticated email is required';
  end if;

  select *
  into target
  from public.family_members
  where id = p_membership_id
    and status = 'pending'
    and lower(trim(invite_email)) = caller_email
  for update;

  if not found then
    raise exception 'Invitation not found or not addressed to this account';
  end if;

  update public.family_members
  set user_id = auth.uid(),
      status = 'active'
  where id = target.id;

  return (
    select fm
    from public.family_members fm
    where fm.id = target.id
  );
end;
$$;

revoke all on function public.accept_family_invitation(uuid) from public;
grant execute on function public.accept_family_invitation(uuid) to authenticated;
