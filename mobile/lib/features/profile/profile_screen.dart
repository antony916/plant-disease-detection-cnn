import 'package:flutter/material.dart';

import '../../core/app_services.dart';
import '../../core/navigation/app_router.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<AppUser?> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = AppServices.auth.currentUser();
  }

  Future<void> _signOut() async {
    await AppServices.auth.signOut();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRouter.login,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: FutureBuilder<AppUser?>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = snapshot.data;

          return ListView(
            padding: const EdgeInsets.all(PlantCareSpacing.lg),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(PlantCareSpacing.md),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: PlantCareColors.primary,
                        child: Text(
                          _initials(user),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: PlantCareSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.displayName?.trim().isNotEmpty == true
                                  ? user!.displayName!
                                  : 'PlantCare Gardener',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user?.email ?? 'No account session',
                              style: const TextStyle(
                                color: PlantCareColors.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: PlantCareSpacing.lg),
              const Text(
                'Garden',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: PlantCareColors.muted,
                ),
              ),
              const SizedBox(height: PlantCareSpacing.sm),
              Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.people_outline,
                    color: PlantCareColors.primary,
                  ),
                  title: const Text(
                    'Family Sharing',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: const Text(
                    'Manage people who can access your garden',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRouter.familySharing,
                  ),
                ),
              ),
              const SizedBox(height: PlantCareSpacing.sm),
              Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.notifications_outlined,
                    color: PlantCareColors.primary,
                  ),
                  title: const Text(
                    'Notification Settings',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: const Text(
                    'Reminders, care alerts and quiet hours',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRouter.notificationSettings,
                  ),
                ),
              ),
              const SizedBox(height: PlantCareSpacing.lg),
              OutlinedButton.icon(
                onPressed: user == null ? null : _signOut,
                icon: const Icon(Icons.logout),
                label: const Text('Sign out'),
              ),
              const SizedBox(height: PlantCareSpacing.md),
              const Text(
                'PlantCare AI keeps location optional. Cloud features use your signed-in account when Supabase is configured.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: PlantCareColors.muted,
                  fontSize: 12,
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: const AppBottomNav(selectedIndex: 3),
    );
  }

  String _initials(AppUser? user) {
    final name = user?.displayName?.trim();
    if (name != null && name.isNotEmpty) {
      final parts = name.split(RegExp(r'\s+'));
      return parts.take(2).map((part) => part[0].toUpperCase()).join();
    }

    final email = user?.email.trim() ?? '';
    return email.isNotEmpty ? email[0].toUpperCase() : 'P';
  }
}
