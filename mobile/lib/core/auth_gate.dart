import 'package:flutter/material.dart';

import 'app_services.dart';
import '../features/auth/login_screen.dart';
import '../features/garden/dashboard_screen.dart';
import 'services/auth_service.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late Future<AppUser?> _session;

  @override
  void initState() {
    super.initState();
    _session = AppServices.auth.currentUser();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppUser?>(
      future: _session,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.data != null) {
          return const DashboardScreen();
        }

        return const LoginScreen();
      },
    );
  }
}
