-- Allow an invited authenticated user to claim only a pending invitation
-- addressed to the email on their authenticated account.

drop policy if exists "invitees accept own pending invitations" on public.family_members;

create policy "invitees accept own pending invitations"
on public.family_members for update
to authenticated
using (
  status = 'pending'
  and lower(invite_email) = lower(auth.jwt() ->> 'email')
)
with check (
  user_id = auth.uid()
  and status = 'active'
  and lower(invite_email) = lower(auth.jwt() ->> 'email')
);

