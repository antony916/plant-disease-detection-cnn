import 'package:flutter_test/flutter_test.dart';

import 'package:plantcare_ai/core/models/family_member.dart';
import 'package:plantcare_ai/core/services/family_sharing_service.dart';

void main() {
  late DemoFamilySharingService service;

  setUp(() {
    service = DemoFamilySharingService();
  });

  test('new invitation is pending and discoverable', () async {
    final member = await service.invite(
      gardenId: 'garden-1',
      email: 'Gardener@example.com',
      role: FamilyMemberRole.viewer,
    );

    expect(member.status, FamilyMemberStatus.pending);
    expect(member.inviteEmail, 'gardener@example.com');

    final pending = await service.pendingInvites();
    expect(pending, hasLength(1));
    expect(pending.single.id, member.id);
  });

  test('accepting an invitation activates the same membership', () async {
    final member = await service.invite(
      gardenId: 'garden-1',
      email: 'gardener@example.com',
    );

    await service.acceptInvite(member.id);

    final pending = await service.pendingInvites();
    expect(pending, isEmpty);

    final members = await service.members('garden-1');
    expect(members, hasLength(1));
    expect(members.single.id, member.id);
    expect(members.single.status, FamilyMemberStatus.active);
    expect(members.single.userId, 'demo-user');
  });

  test('role changes preserve membership and garden identity', () async {
    final member = await service.invite(
      gardenId: 'garden-2',
      email: 'editor@example.com',
      role: FamilyMemberRole.viewer,
    );

    await service.acceptInvite(member.id);
    await service.changeRole(member.id, FamilyMemberRole.editor);

    final members = await service.members('garden-2');
    expect(members.single.id, member.id);
    expect(members.single.gardenId, 'garden-2');
    expect(members.single.userId, 'demo-user');
    expect(members.single.role, FamilyMemberRole.editor);
    expect(members.single.status, FamilyMemberStatus.active);
  });
}
