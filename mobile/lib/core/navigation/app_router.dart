import 'package:flutter/material.dart';

import '../services/diagnosis_service.dart';
import '../models/plant.dart';
import '../../features/auth/login_screen.dart';
import '../../features/assistant/assistant_screen.dart';
import '../../features/diagnosis/diagnosis_screen.dart';
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
  static const login = '/';
  static const dashboard = '/dashboard';
  static const scanner = '/scanner';
  static const diagnosis = '/diagnosis';
  static const plant = '/plant';
  static const assistant = '/assistant';
  static const library = '/library';
  static const addPlant = '/add-plant';
  static const editPlant = '/edit-plant';
  static const notifications = '/notifications';
  static const notificationSettings = '/notification-settings';
  static const familySharing = '/family-sharing';
  static const familyInvites = '/family-invites';
  static const profile = '/profile';
  static const support = '/support';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardScreen());
      case scanner:
        return MaterialPageRoute(builder: (_) => const ScannerScreen());
      case diagnosis:
        final result = settings.arguments;
        if (result is DiagnosisResult) {
          return MaterialPageRoute(
            builder: (_) => DiagnosisScreen(result: result),
          );
        }
        return MaterialPageRoute(builder: (_) => const ScannerScreen());
      case plant:
        return MaterialPageRoute(
          builder: (_) => PlantDetailScreen(
            plantName: settings.arguments is String
                ? settings.arguments as String
                : 'Tomato',
          ),
        );
      case assistant:
        return MaterialPageRoute(builder: (_) => const AssistantScreen());
      case library:
        return MaterialPageRoute(builder: (_) => const LibraryScreen());
      case addPlant:
        return MaterialPageRoute(builder: (_) => const AddPlantScreen());
      case editPlant:
        final plant = settings.arguments;
        if (plant is Plant) {
          return MaterialPageRoute(
              builder: (_) => EditPlantScreen(plant: plant));
        }
        return MaterialPageRoute(builder: (_) => const DashboardScreen());
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
  final int selectedIndex;

  const AppBottomNav({super.key, required this.selectedIndex});

  void _go(BuildContext context, int index) {
    if (index == selectedIndex) return;

    const routes = [
      AppRouter.dashboard,
      AppRouter.scanner,
      AppRouter.library,
      AppRouter.profile,
    ];

    Navigator.pushReplacementNamed(context, routes[index]);
  }

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) => _go(context, index),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Garden',
        ),
        NavigationDestination(
          icon: Icon(Icons.camera_alt_outlined),
          selectedIcon: Icon(Icons.camera_alt),
          label: 'Scan',
        ),
        NavigationDestination(
          icon: Icon(Icons.grid_view_outlined),
          selectedIcon: Icon(Icons.grid_view),
          label: 'Library',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}
