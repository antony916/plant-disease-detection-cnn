import '../models/family_member.dart';

abstract interface class FamilySharingService {
  Future<List<FamilyMember>> members(String gardenId);
  Future<FamilyMember> invite({
    required String gardenId,
    required String email,
    FamilyMemberRole role = FamilyMemberRole.viewer,
  });
  Future<void> remove(String membershipId);
  Future<void> changeRole(
    String membershipId,
    FamilyMemberRole role,
  );
}

class DemoFamilySharingService implements FamilySharingService {
  final List<FamilyMember> _members = [];

  @override
  Future<List<FamilyMember>> members(String gardenId) async =>
      List.unmodifiable(
        _members.where((member) => member.gardenId == gardenId),
      );

  @override
  Future<FamilyMember> invite({
    required String gardenId,
    required String email,
    FamilyMemberRole role = FamilyMemberRole.viewer,
  }) async {
    final member = FamilyMember(
      id: 'demo-family-' + DateTime.now().microsecondsSinceEpoch.toString(),
      gardenId: gardenId,
      inviteEmail: email.trim().toLowerCase(),
      role: role,
      status: FamilyMemberStatus.pending,
      createdAt: DateTime.now(),
    );
    _members.add(member);
    return member;
  }

  @override
  Future<void> remove(String membershipId) async {
    _members.removeWhere((member) => member.id == membershipId);
  }

  @override
  Future<void> changeRole(
    String membershipId,
    FamilyMemberRole role,
  ) async {
    final index = _members.indexWhere((member) => member.id == membershipId);
    if (index < 0) return;
    final member = _members[index];
    _members[index] = FamilyMember(
      id: member.id,
      gardenId: member.gardenId,
      userId: member.userId,
      inviteEmail: member.inviteEmail,
      role: role,
      status: member.status,
      invitedBy: member.invitedBy,
      createdAt: member.createdAt,
    );
  }
}
