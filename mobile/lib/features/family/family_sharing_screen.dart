import 'package:flutter/material.dart';

import '../../core/app_services.dart';
import '../../core/models/family_member.dart';
import '../../core/models/garden.dart';
import '../../core/theme/app_theme.dart';

class FamilySharingScreen extends StatefulWidget {
  const FamilySharingScreen({super.key});
  @override State<FamilySharingScreen> createState() => _FamilySharingScreenState();
}

class _FamilySharingScreenState extends State<FamilySharingScreen> {
  late Future<Garden> _gardenFuture;
  late Future<List<FamilyMember>> _membersFuture;

  @override
  void initState() {
    super.initState();
    _gardenFuture = AppServices.garden.getGarden();
    _membersFuture = _loadMembers();
  }

  Future<List<FamilyMember>> _loadMembers() async {
    final garden = await _gardenFuture;
    return AppServices.family.members(garden.id);
  }

  void _refresh() {
    setState(() {
      _gardenFuture = AppServices.garden.getGarden();
      _membersFuture = _loadMembers();
    });
  }

  Future<void> _invite() async {
    final controller = TextEditingController();
    var role = FamilyMemberRole.viewer;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Invite to your garden'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: controller, keyboardType: TextInputType.emailAddress, autofocus: true, decoration: const InputDecoration(labelText: 'Email address', hintText: 'family@example.com')),
            const SizedBox(height: PlantCareSpacing.md),
            DropdownButtonFormField<FamilyMemberRole>(
              initialValue: role,
              decoration: const InputDecoration(labelText: 'Access'),
              items: const [
                DropdownMenuItem(value: FamilyMemberRole.viewer, child: Text('Viewer — can view the garden')),
                DropdownMenuItem(value: FamilyMemberRole.editor, child: Text('Editor — can update garden data')),
              ],
              onChanged: (value) { if (value != null) setDialogState(() => role = value); },
            ),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
            FilledButton(onPressed: () { if (controller.text.trim().isNotEmpty) Navigator.pop(context, true); }, child: const Text('Send invite')),
          ],
        ),
      ),
    );
    final email = controller.text.trim();
    controller.dispose();
    if (result != true || email.isEmpty) return;
    try {
      final garden = await _gardenFuture;
      await AppServices.family.invite(gardenId: garden.id, email: email, role: role);
      if (!mounted) return;
      _refresh();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invitation created for ' + email + '.')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not create invitation: ' + error.toString())));
    }
  }

  Future<void> _changeRole(FamilyMember member) async {
    if (member.role == FamilyMemberRole.owner) return;
    final role = await showDialog<FamilyMemberRole>(
      context: context,
      builder: (context) => SimpleDialog(title: const Text('Change access'), children: [
        SimpleDialogOption(onPressed: () => Navigator.pop(context, FamilyMemberRole.viewer), child: const Text('Viewer')),
        SimpleDialogOption(onPressed: () => Navigator.pop(context, FamilyMemberRole.editor), child: const Text('Editor')),
      ]),
    );
    if (role == null || role == member.role) return;
    try {
      await AppServices.family.changeRole(member.id, role);
      if (!mounted) return;
      _refresh();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not change access: ' + error.toString())));
    }
  }

  Future<void> _remove(FamilyMember member) async {
    if (member.role == FamilyMemberRole.owner) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove member?'),
        content: Text('Remove ' + (member.inviteEmail ?? 'this member') + ' from your garden?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Remove')),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await AppServices.family.remove(member.id);
      if (!mounted) return;
      _refresh();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not remove member: ' + error.toString())));
    }
  }

  String _roleLabel(FamilyMemberRole role) => switch (role) {
    FamilyMemberRole.owner => 'Owner',
    FamilyMemberRole.editor => 'Editor',
    FamilyMemberRole.viewer => 'Viewer',
  };

  String _statusLabel(FamilyMemberStatus status) => switch (status) {
    FamilyMemberStatus.pending => 'Invitation pending',
    FamilyMemberStatus.active => 'Active',
    FamilyMemberStatus.removed => 'Removed',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Family sharing', style: TextStyle(fontWeight: FontWeight.w800)), actions: [IconButton(tooltip: 'Refresh', onPressed: _refresh, icon: const Icon(Icons.refresh))]),
      body: FutureBuilder<Garden>(
        future: _gardenFuture,
        builder: (context, gardenSnapshot) {
          if (gardenSnapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (gardenSnapshot.hasError) return Center(child: Padding(padding: const EdgeInsets.all(PlantCareSpacing.lg), child: Text('We could not load your garden. ' + gardenSnapshot.error.toString(), textAlign: TextAlign.center)));
          final garden = gardenSnapshot.data;
          if (garden == null) return const Center(child: Text('Garden unavailable.'));
          return RefreshIndicator(
            onRefresh: () async => _refresh(),
            child: ListView(
              padding: const EdgeInsets.all(PlantCareSpacing.lg),
              children: [
                Card(child: ListTile(leading: const CircleAvatar(backgroundColor: PlantCareColors.surface, child: Icon(Icons.groups_outlined, color: PlantCareColors.primary)), title: Text(garden.name, style: const TextStyle(fontWeight: FontWeight.w800)), subtitle: const Text('Share your garden with trusted family members.'))),
                const SizedBox(height: PlantCareSpacing.md),
                FilledButton.icon(onPressed: _invite, icon: const Icon(Icons.person_add_outlined), label: const Text('Invite family member')),
                const SizedBox(height: PlantCareSpacing.lg),
                const Text('Members', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800)),
                const SizedBox(height: PlantCareSpacing.sm),
                FutureBuilder<List<FamilyMember>>(
                  future: _membersFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) return const Padding(padding: EdgeInsets.all(PlantCareSpacing.lg), child: Center(child: CircularProgressIndicator()));
                    if (snapshot.hasError) return Card(child: ListTile(leading: const Icon(Icons.error_outline), title: const Text('Members unavailable'), subtitle: Text(snapshot.error.toString())));
                    final members = snapshot.data ?? const <FamilyMember>[];
                    if (members.isEmpty) return const Card(child: Padding(padding: EdgeInsets.all(PlantCareSpacing.lg), child: Text('No family members have been added yet.', textAlign: TextAlign.center, style: TextStyle(color: PlantCareColors.muted))));
                    return Column(children: [
                      for (int i = 0; i < members.length; i++) ...[
                        if (i > 0) const SizedBox(height: PlantCareSpacing.sm),
                        Card(child: ListTile(
                          leading: CircleAvatar(backgroundColor: PlantCareColors.surface, child: Icon(members[i].status == FamilyMemberStatus.pending ? Icons.mail_outline : Icons.person_outline, color: PlantCareColors.primary)),
                          title: Text(members[i].inviteEmail ?? members[i].userId ?? 'Garden member', style: const TextStyle(fontWeight: FontWeight.w700)),
                          subtitle: Text(_roleLabel(members[i].role) + ' • ' + _statusLabel(members[i].status)),
                          trailing: members[i].role == FamilyMemberRole.owner
                              ? const Chip(label: Text('Owner'))
                              : PopupMenuButton<String>(onSelected: (value) { if (value == 'role') _changeRole(members[i]); if (value == 'remove') _remove(members[i]); }, itemBuilder: (context) => const [PopupMenuItem(value: 'role', child: Text('Change access')), PopupMenuItem(value: 'remove', child: Text('Remove'))]),
                        )),
                      ],
                    ]);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}