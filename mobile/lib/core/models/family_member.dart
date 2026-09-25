enum FamilyMemberRole { owner, editor, viewer }

enum FamilyMemberStatus { pending, active, removed }

class FamilyMember {
  final String id;
  final String gardenId;
  final String? userId;
  final String? inviteEmail;
  final FamilyMemberRole role;
  final FamilyMemberStatus status;
  final String? invitedBy;
  final DateTime createdAt;

  const FamilyMember({
    required this.id,
    required this.gardenId,
    this.userId,
    this.inviteEmail,
    required this.role,
    required this.status,
    this.invitedBy,
    required this.createdAt,
  });
}
