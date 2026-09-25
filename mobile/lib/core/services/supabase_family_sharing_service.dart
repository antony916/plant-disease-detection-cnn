import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/family_member.dart';
import 'family_sharing_service.dart';

class SupabaseFamilySharingService implements FamilySharingService {
  final SupabaseClient client;

  const SupabaseFamilySharingService(this.client);

  @override
  Future<List<FamilyMember>> members(String gardenId) async {
    _requireUser();

    final rows = await client
        .from('family_members')
        .select()
        .eq('garden_id', gardenId)
        .neq('status', 'removed')
        .order('created_at');

    return rows.map(_fromRow).toList();
  }

  @override
  Future<FamilyMember> invite({
    required String gardenId,
    required String email,
    FamilyMemberRole role = FamilyMemberRole.viewer,
  }) async {
    final user = _requireUser();

    final row = await client
        .from('family_members')
        .insert({
          'garden_id': gardenId,
          'invite_email': email.trim().toLowerCase(),
          'invited_by': user.id,
          'role': _roleName(role),
          'status': 'pending',
        })
        .select()
        .single();

    return _fromRow(row);
  }

  @override
  Future<void> remove(String membershipId) async {
    _requireUser();
    await client
        .from('family_members')
        .update({'status': 'removed'})
        .eq('id', membershipId);
  }

  @override
  Future<void> changeRole(
    String membershipId,
    FamilyMemberRole role,
  ) async {
    _requireUser();
    await client
        .from('family_members')
        .update({'role': _roleName(role)})
        .eq('id', membershipId);
  }

  User _requireUser() {
    final user = client.auth.currentUser;
    if (user == null) throw const AuthException('Sign in required.');
    return user;
  }

  FamilyMember _fromRow(Map<String, dynamic> row) {
    return FamilyMember(
      id: row['id'].toString(),
      gardenId: row['garden_id'].toString(),
      userId: row['user_id']?.toString(),
      inviteEmail: row['invite_email'] as String?,
      role: _roleFromName(row['role'] as String?),
      status: _statusFromName(row['status'] as String?),
      invitedBy: row['invited_by']?.toString(),
      createdAt:
          DateTime.tryParse(row['created_at'].toString()) ?? DateTime.now(),
    );
  }

  FamilyMemberRole _roleFromName(String? value) {
    switch (value) {
      case 'owner':
        return FamilyMemberRole.owner;
      case 'editor':
        return FamilyMemberRole.editor;
      default:
        return FamilyMemberRole.viewer;
    }
  }

  String _roleName(FamilyMemberRole role) {
    switch (role) {
      case FamilyMemberRole.owner:
        return 'owner';
      case FamilyMemberRole.editor:
        return 'editor';
      case FamilyMemberRole.viewer:
        return 'viewer';
    }
  }

  FamilyMemberStatus _statusFromName(String? value) {
    switch (value) {
      case 'pending':
        return FamilyMemberStatus.pending;
      case 'removed':
        return FamilyMemberStatus.removed;
      default:
        return FamilyMemberStatus.active;
    }
  }
}
