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
  bool busy = false;
  Future<void> google() async {
    setState(() => busy = true);
    try {
      final u = await AppServices.auth.signInWithGoogle();
      await AppServices.syncPushRegistration();
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRouter.dashboard);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Welcome ' + (u.displayName ?? u.email))));
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
                Text('Google sign-in is not configured: ' + e.toString())));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> email() async {
    final e = TextEditingController(), p = TextEditingController();
    final v = await showDialog<({String email, String password})>(
        context: context,
        builder: (c) => AlertDialog(
                title: const Text('Sign in'),
                content: Column(mainAxisSize: MainAxisSize.min, children: [
                  TextField(
                      controller: e,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined))),
                  const SizedBox(height: 12),
                  TextField(
                      controller: p,
                      obscureText: true,
                      decoration: const InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock_outline)))
                ]),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(c),
                      child: const Text('Cancel')),
                  FilledButton(
                      onPressed: () => Navigator.pop(
                          c, (email: e.text.trim(), password: p.text)),
                      child: const Text('Sign in'))
                ]));
    e.dispose();
    p.dispose();
    if (v == null || v.email.isEmpty) return;
    setState(() => busy = true);
    try {
      await AppServices.auth
          .signInWithEmail(email: v.email, password: v.password);
      await AppServices.syncPushRegistration();
      if (mounted) Navigator.pushReplacementNamed(context, AppRouter.dashboard);
    } catch (err) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Sign-in failed: ' + err.toString())));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext c) => Scaffold(
          body: SafeArea(
              child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
                  children: [
            Row(children: [
              Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                      color: PlantCareColors.primary,
                      borderRadius: BorderRadius.circular(9)),
                  child: const Icon(Icons.eco_outlined,
                      color: Colors.white, size: 25)),
              const SizedBox(width: 10),
              const Text('PlantCare AI',
                  style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
              const Spacer(),
              IconButton(
                  onPressed: () => ScaffoldMessenger.of(c).showSnackBar(
                      const SnackBar(
                          content: Text('Use demo mode to explore the app.'))),
                  icon: const Icon(Icons.help_outline_rounded))
            ]),
            const SizedBox(height: 52),
            const Text('Welcome back',
                style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -.7)),
            const SizedBox(height: 7),
            const Text(
                'Manage your plants, AI scans and care reminders in one place.',
                style: TextStyle(color: PlantCareColors.muted, fontSize: 15)),
            const SizedBox(height: 28),
            Card(
                child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('GET STARTED',
                              style: TextStyle(
                                  color: PlantCareColors.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: .8)),
                          const SizedBox(height: 8),
                          const Text('Your garden, organized.',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 18),
                          SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                  onPressed: busy ? null : google,
                                  icon:
                                      const Icon(Icons.account_circle_outlined),
                                  label: Text(busy
                                      ? 'Signing in…'
                                      : 'Continue with Google'))),
                          const SizedBox(height: 9),
                          SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                  onPressed: busy ? null : email,
                                  icon: const Icon(Icons.email_outlined),
                                  label: const Text('Continue with email')))
                        ]))),
            const SizedBox(height: 20),
            Row(children: [
              const Expanded(child: Divider()),
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text('OR',
                      style: TextStyle(
                          color: PlantCareColors.muted,
                          fontSize: 11,
                          fontWeight: FontWeight.w800))),
              const Expanded(child: Divider())
            ]),
            const SizedBox(height: 16),
            SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                    onPressed: busy
                        ? null
                        : () => Navigator.pushReplacementNamed(
                            c, AppRouter.dashboard),
                    icon: const Icon(Icons.person_outline),
                    label: const Text('Continue in demo mode'))),
            const SizedBox(height: 26),
            const Text(
                'By continuing, you agree to the app terms and privacy policy.',
                textAlign: TextAlign.center,
                style: TextStyle(color: PlantCareColors.muted, fontSize: 11))
          ])));
}
