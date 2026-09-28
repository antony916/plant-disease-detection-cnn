revoke execute on function public.can_edit_garden(uuid) from anon, authenticated;
revoke execute on function public.is_garden_member(uuid) from anon, authenticated;
revoke execute on function public.is_garden_owner(uuid) from anon, authenticated;
revoke execute on function public.accept_family_invitation(uuid) from anon;
grant execute on function public.accept_family_invitation(uuid) to authenticated;