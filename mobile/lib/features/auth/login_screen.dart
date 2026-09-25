import 'package:flutter/material.dart';

import '../../core/app_services.dart';
import '../../core/navigation/app_router.dart';
import '../../core/theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _busy = false;

  Future<void> _continueWithGoogle() async {
    setState(() => _busy = true);
    try {
      final user = await AppServices.auth.signInWithGoogle();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRouter.dashboard);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Welcome ' + (user.displayName ?? user.email))),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google sign-in is not configured yet: ' + error.toString())),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _continueWithEmail() async {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    final credentials = await showDialog<({String email, String password})>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign in with email'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(
              context,
              (
                email: emailController.text.trim(),
                password: passwordController.text,
              ),
            ),
            child: const Text('Sign in'),
          ),
        ],
      ),
    );

    emailController.dispose();
    passwordController.dispose();

    if (credentials == null || credentials.email.isEmpty) return;

    setState(() => _busy = true);
    try {
      final user = await AppServices.auth.signInWithEmail(
        email: credentials.email,
        password: credentials.password,
      );
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRouter.dashboard);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Welcome ' + (user.displayName ?? user.email))),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign-in failed: ' + error.toString())),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

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
              Text(
                'PlantCare AI',
                style: Theme.of(context)
                    .textTheme
                    .headlineLarge
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: PlantCareSpacing.sm),
              Text(
                'Your intelligent garden companion.',
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: PlantCareColors.muted),
              ),
              const SizedBox(height: PlantCareSpacing.xl),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _busy ? null : _continueWithGoogle,
                  icon: const Icon(Icons.g_mobiledata, size: 28),
                  label: Text(_busy ? 'Signing in…' : 'Continue with Google'),
                ),
              ),
              const SizedBox(height: PlantCareSpacing.sm),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _busy ? null : _continueWithEmail,
                  child: const Text('Continue with email'),
                ),
              ),
              const SizedBox(height: PlantCareSpacing.md),
              Text(
                'Your garden data will be stored securely in your account. Location is optional.',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: PlantCareColors.muted),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
