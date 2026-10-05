import 'package:flutter/material.dart';
import '../../core/app_services.dart';
import '../../core/navigation/app_router.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_mode_controller.dart';
import '../../core/theme/theme_scope.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<AppUser?> _user;
  @override
  void initState() {
    super.initState();
    _user = AppServices.auth.currentUser();
  }

  Future<void> _signOut() async {
    await AppServices.auth.signOut();
    if (mounted)
      Navigator.pushNamedAndRemoveUntil(context, AppRouter.login, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<AppUser?>(
          future: _user,
          builder: (context, snapshot) {
            final u = snapshot.data;
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
              children: [
                Row(children: [
                  const Expanded(
                      child: Text('Profile',
                          style: TextStyle(
                              fontSize: 25, fontWeight: FontWeight.w900))),
                  IconButton(
                      tooltip: 'Help',
                      onPressed: () =>
                          Navigator.pushNamed(context, AppRouter.support),
                      icon: const Icon(Icons.help_outline_rounded))
                ]),
                const SizedBox(height: 12),
                Card(
                    child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(children: [
                          const CircleAvatar(
                              radius: 28,
                              backgroundColor: PlantCareColors.softGreen,
                              child: Icon(Icons.person_rounded,
                                  color: PlantCareColors.primary, size: 30)),
                          const SizedBox(width: 12),
                          Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                Text(
                                    u?.displayName?.trim().isNotEmpty == true
                                        ? u!.displayName!
                                        : 'PlantCare Gardener',
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900)),
                                const SizedBox(height: 3),
                                Text(u?.email ?? 'Account details unavailable',
                                    style: const TextStyle(
                                        color: PlantCareColors.muted,
                                        fontSize: 12))
                              ]))
                        ]))),
                const SizedBox(height: 22),
                const _Label('MY ACCOUNT'),
                _Tile(Icons.eco_outlined, 'My plants', 'Manage your garden',
                    () => Navigator.pushNamed(context, AppRouter.dashboard)),
                _Tile(
                    Icons.history_rounded,
                    'Health history',
                    'Review AI diagnoses',
                    () => Navigator.pushNamed(
                        context, AppRouter.diagnosisHistory)),
                _Tile(
                    Icons.notifications_none_rounded,
                    'Notifications',
                    'Alerts and care reminders',
                    () =>
                        Navigator.pushNamed(context, AppRouter.notifications)),
                const SizedBox(height: 20),
                const _Label('GARDEN & SHARING'),
                _Tile(
                    Icons.people_outline_rounded,
                    'Family sharing',
                    'Manage garden access',
                    () =>
                        Navigator.pushNamed(context, AppRouter.familySharing)),
                _Tile(
                    Icons.mail_outline_rounded,
                    'Invitations',
                    'Shared garden invitations',
                    () =>
                        Navigator.pushNamed(context, AppRouter.familyInvites)),
                const SizedBox(height: 20),
                const _Label('APPEARANCE'),
                _ThemeModeSelector(controller: ThemeScope.of(context)),
                const SizedBox(height: 20),
                const _Label('PREFERENCES & SUPPORT'),
                _Tile(
                    Icons.tune_rounded,
                    'Notification settings',
                    'Reminders and quiet hours',
                    () => Navigator.pushNamed(
                        context, AppRouter.notificationSettings)),
                _Tile(
                    Icons.support_agent_outlined,
                    'Help centre',
                    'Support and resources',
                    () => Navigator.pushNamed(context, AppRouter.support)),
                _Tile(
                    Icons.privacy_tip_outlined,
                    'Privacy',
                    'Account and data controls',
                    () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text(
                            'Privacy controls are available for cloud accounts.')))),
                const SizedBox(height: 20),
                SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                        onPressed: u == null ? null : _signOut,
                        icon: const Icon(Icons.logout_rounded),
                        label: const Text('Sign out'))),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: const AppBottomNav(selectedIndex: 3),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext c) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text,
          style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: .7,
              color: PlantCareColors.primary)));
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final VoidCallback onTap;
  const _Tile(this.icon, this.title, this.subtitle, this.onTap);
  @override
  Widget build(BuildContext c) => Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
          onTap: onTap,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
          leading: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                  color: PlantCareColors.softGreen,
                  borderRadius: BorderRadius.circular(9)),
              child: Icon(icon, color: PlantCareColors.primary)),
          title:
              Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.chevron_right_rounded)));
}

class _ThemeModeSelector extends StatelessWidget {
  const _ThemeModeSelector({required this.controller});

  final ThemeModeController controller;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<ThemeMode>(
      segments: const [
        ButtonSegment(
          value: ThemeMode.system,
          icon: Icon(Icons.brightness_auto_outlined),
          label: Text('System'),
        ),
        ButtonSegment(
          value: ThemeMode.light,
          icon: Icon(Icons.light_mode_outlined),
          label: Text('Light'),
        ),
        ButtonSegment(
          value: ThemeMode.dark,
          icon: Icon(Icons.dark_mode_outlined),
          label: Text('Dark'),
        ),
      ],
      selected: {controller.mode},
      onSelectionChanged: (selection) {
        controller.setMode(selection.first);
      },
    );
  }
}
