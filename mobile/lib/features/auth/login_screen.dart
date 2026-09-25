import 'package:flutter/material.dart';

import '../../core/navigation/app_router.dart';
import '../../core/theme/app_theme.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(PlantCareSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: PlantCareColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.eco, color: Colors.white, size: 34),
              ),
              const SizedBox(height: PlantCareSpacing.lg),
              Text('PlantCare AI', style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: PlantCareSpacing.sm),
              Text(
                'Your intelligent garden companion.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: PlantCareColors.muted),
              ),
              const SizedBox(height: PlantCareSpacing.xl),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => Navigator.pushReplacementNamed(context, AppRouter.dashboard),
                  icon: const Icon(Icons.g_mobiledata, size: 28),
                  label: const Text('Continue with Google'),
                ),
              ),
              const SizedBox(height: PlantCareSpacing.sm),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pushReplacementNamed(context, AppRouter.dashboard),
                  child: const Text('Continue with email'),
                ),
              ),
              const SizedBox(height: PlantCareSpacing.md),
              Text(
                'Your garden data will be stored securely in your account. Location is optional.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: PlantCareColors.muted),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
