import 'package:flutter/material.dart';

import '../../features/auth/login_screen.dart';
import '../../features/assistant/assistant_screen.dart';
import '../../features/diagnosis/diagnosis_screen.dart';
import '../../features/garden/dashboard_screen.dart';
import '../../features/garden/plant_detail_screen.dart';
import '../../features/library/library_screen.dart';
import '../../features/scanner/scanner_screen.dart';

abstract final class AppRouter {
  static const login = '/';
  static const dashboard = '/dashboard';
  static const scanner = '/scanner';
  static const diagnosis = '/diagnosis';
  static const plant = '/plant';
  static const assistant = '/assistant';
  static const library = '/library';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardScreen());
      case scanner:
        return MaterialPageRoute(builder: (_) => const ScannerScreen());
      case diagnosis:
        return MaterialPageRoute(
          builder: (_) => DiagnosisScreen(
            plantName: settings.arguments is String ? settings.arguments as String : 'Plant',
          ),
        );
      case plant:
        return MaterialPageRoute(
          builder: (_) => PlantDetailScreen(
            plantName: settings.arguments is String ? settings.arguments as String : 'Tomato',
          ),
        );
      case assistant:
        return MaterialPageRoute(builder: (_) => const AssistantScreen());
      case library:
        return MaterialPageRoute(builder: (_) => const LibraryScreen());
      default:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
    }
  }
}

class AppBottomNav extends StatelessWidget {
  final int selectedIndex;

  const AppBottomNav({super.key, required this.selectedIndex});

  void _go(BuildContext context, int index) {
    final routes = [
      AppRouter.dashboard,
      AppRouter.scanner,
      AppRouter.library,
      AppRouter.assistant,
    ];
    if (index == selectedIndex) return;
    Navigator.pushReplacementNamed(context, routes[index]);
  }

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) => _go(context, index),
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Garden'),
        NavigationDestination(icon: Icon(Icons.document_scanner_outlined), selectedIcon: Icon(Icons.document_scanner), label: 'Scan'),
        NavigationDestination(icon: Icon(Icons.local_florist_outlined), selectedIcon: Icon(Icons.local_florist), label: 'Library'),
        NavigationDestination(icon: Icon(Icons.auto_awesome_outlined), selectedIcon: Icon(Icons.auto_awesome), label: 'AI'),
      ],
    );
  }
}
