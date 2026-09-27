import 'package:flutter/material.dart';

import '../../core/app_services.dart';
import '../../core/models/family_member.dart';
import '../../core/theme/app_theme.dart';

class FamilyInvitesScreen extends StatefulWidget {
  const FamilyInvitesScreen({super.key});

  @override
  State<FamilyInvitesScreen> createState() => _FamilyInvitesScreenState();
}

class _FamilyInvitesScreenState extends State<FamilyInvitesScreen> {
  late Future<List<FamilyMember>> _future;

  @override
  void initState() {
    super.initState();
    _future = AppServices.family.pendingInvites();
  }

  void _refresh() {
    setState(() => _future = AppServices.family.pendingInvites());
  }

  Future<void> _accept(FamilyMember invite) async {
    try {
      await AppServices.family.acceptInvite(invite.id);
      if (!mounted) return;
      _refresh();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You joined the shared garden.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not accept invitation: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Garden invitations',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: FutureBuilder<List<FamilyMember>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(PlantCareSpacing.lg),
                child: Text(
                  'We could not load your invitations. ${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final invites = snapshot.data ?? const <FamilyMember>[];
          if (invites.isEmpty) {
            return RefreshIndicator(
              onRefresh: () async => _refresh(),
              child: ListView(
                children: const [
                  SizedBox(height: 140),
                  Icon(Icons.mail_outline, size: 56, color: PlantCareColors.muted),
                  SizedBox(height: PlantCareSpacing.md),
                  Center(
                    child: Text(
                      'No pending garden invitations.',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _refresh(),
            child: ListView.separated(
              padding: const EdgeInsets.all(PlantCareSpacing.lg),
              itemCount: invites.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: PlantCareSpacing.sm),
              itemBuilder: (context, index) {
                final invite = invites[index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(PlantCareSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.groups_outlined,
                          color: PlantCareColors.primary,
                          size: 32,
                        ),
                        const SizedBox(height: PlantCareSpacing.sm),
                        const Text(
                          'Shared garden invitation',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Access: ${invite.role.name}',
                          style: const TextStyle(color: PlantCareColors.muted),
                        ),
                        const SizedBox(height: PlantCareSpacing.md),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: () => _accept(invite),
                            icon: const Icon(Icons.check),
                            label: const Text('Accept invitation'),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
