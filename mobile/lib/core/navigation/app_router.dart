import 'package:flutter/material.dart';
import '../services/diagnosis_service.dart';
import '../models/plant.dart';
import '../theme/app_theme.dart';
import '../ui/glass_components.dart';
import '../../features/auth/login_screen.dart';
import '../../features/assistant/assistant_screen.dart';
import '../../features/diagnosis/diagnosis_screen.dart';
import '../../features/diagnosis/diagnosis_history_screen.dart';
import '../../features/garden/add_plant_screen.dart';
import '../../features/garden/edit_plant_screen.dart';
import '../../features/garden/dashboard_screen.dart';
import '../../features/garden/plant_detail_screen.dart';
import '../../features/library/library_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/notifications/notification_center_screen.dart';
import '../../features/notifications/notification_settings_screen.dart';
import '../../features/family/family_sharing_screen.dart';
import '../../features/family/family_invites_screen.dart';
import '../../features/scanner/scanner_screen.dart';
import '../../features/library/support_hub_screen.dart';

abstract final class AppRouter {
  static const login = '/',
      dashboard = '/dashboard',
      scanner = '/scanner',
      diagnosis = '/diagnosis',
      diagnosisHistory = '/diagnosis-history',
      plant = '/plant',
      assistant = '/assistant',
      library = '/library',
      addPlant = '/add-plant',
      editPlant = '/edit-plant',
      notifications = '/notifications',
      notificationSettings = '/notification-settings',
      familySharing = '/family-sharing',
      familyInvites = '/family-invites',
      profile = '/profile',
      support = '/support';

  static Route<dynamic> onGenerateRoute(RouteSettings s) {
    switch (s.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardScreen());
      case scanner:
        return MaterialPageRoute(builder: (_) => const ScannerScreen());
      case diagnosisHistory:
        return MaterialPageRoute(
            builder: (_) => const DiagnosisHistoryScreen());
      case diagnosis:
        final r = s.arguments;
        return MaterialPageRoute(
            builder: (_) => r is DiagnosisResult
                ? DiagnosisScreen(result: r)
                : const ScannerScreen());
      case plant:
        return MaterialPageRoute(
            builder: (_) => PlantDetailScreen(
                plantName:
                    s.arguments is String ? s.arguments as String : 'Tomato'));
      case assistant:
        return MaterialPageRoute(builder: (_) => const AssistantScreen());
      case library:
        return MaterialPageRoute(builder: (_) => const LibraryScreen());
      case addPlant:
        return MaterialPageRoute(builder: (_) => const AddPlantScreen());
      case editPlant:
        final p = s.arguments;
        return MaterialPageRoute(
            builder: (_) => p is Plant
                ? EditPlantScreen(plant: p)
                : const DashboardScreen());
      case notifications:
        return MaterialPageRoute(
            builder: (_) => const NotificationCenterScreen());
      case notificationSettings:
        return MaterialPageRoute(
            builder: (_) => const NotificationSettingsScreen());
      case familySharing:
        return MaterialPageRoute(builder: (_) => const FamilySharingScreen());
      case familyInvites:
        return MaterialPageRoute(builder: (_) => const FamilyInvitesScreen());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case support:
        return MaterialPageRoute(builder: (_) => const SupportHubScreen());
      default:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
    }
  }
}

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.selectedIndex,
  });

  final int selectedIndex;

  static const _destinations = <_NavDestination>[
    _NavDestination(Icons.eco_outlined, Icons.eco_rounded, 'Garden',
        AppRouter.dashboard),
    _NavDestination(Icons.center_focus_strong_outlined,
        Icons.center_focus_strong_rounded, 'Scan', AppRouter.scanner),
    _NavDestination(Icons.menu_book_outlined, Icons.menu_book_rounded,
        'Library', AppRouter.library),
    _NavDestination(Icons.person_outline_rounded, Icons.person_rounded,
        'Profile', AppRouter.profile),
  ];

  void go(BuildContext context, int index) {
    if (index == selectedIndex) return;
    Navigator.pushReplacementNamed(context, _destinations[index].route);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: RepaintBoundary(
        child: GlassPill(
          padding: const EdgeInsets.all(6),
          semanticLabel: 'Main navigation',
          child: Row(
            children: [
              for (var index = 0; index < _destinations.length; index++)
                Expanded(
                  child: _NavItem(
                    destination: _destinations[index],
                    selected: index == selectedIndex,
                    onTap: () => go(context, index),
                    foreground: colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.destination,
    required this.selected,
    required this.onTap,
    required this.foreground,
  });

  final _NavDestination destination;
  final bool selected;
  final VoidCallback onTap;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    final selectedForeground = Theme.of(context).colorScheme.onPrimary;

    return Semantics(
      button: true,
      selected: selected,
      label: destination.label + ' tab',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          height: 44,
          decoration: selected
              ? BoxDecoration(
                  gradient: PlantCareGradients.lime,
                  borderRadius:
                      BorderRadius.circular(PlantCareRadius.pill),
                )
              : null,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                selected ? destination.selectedIcon : destination.icon,
                size: 20,
                color: selected ? selectedForeground : foreground,
              ),
              const SizedBox(width: 6),
              Text(
                destination.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: selected ? selectedForeground : foreground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavDestination {
  const _NavDestination(this.icon, this.selectedIcon, this.label, this.route);

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String route;
}
