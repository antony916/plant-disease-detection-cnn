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
