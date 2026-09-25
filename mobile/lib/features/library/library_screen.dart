import 'package:flutter/material.dart';

import '../../core/navigation/app_router.dart';
import '../../core/theme/app_theme.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Plant Library', style: TextStyle(fontWeight: FontWeight.w800))),
      body: ListView(
        padding: const EdgeInsets.all(PlantCareSpacing.lg),
        children: const [
          Text('Learn before you grow', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
          SizedBox(height: 6),
          Text('Plants, diseases, pests and practical care guidance.', style: TextStyle(color: PlantCareColors.muted)),
          SizedBox(height: PlantCareSpacing.lg),
          _LibraryTile(icon: Icons.eco_outlined, title: 'Plants', subtitle: 'Vegetables, fruits, flowers, herbs and ornamentals'),
          _LibraryTile(icon: Icons.bug_report_outlined, title: 'Pests', subtitle: 'Recognize common pest damage and warning signs'),
          _LibraryTile(icon: Icons.health_and_safety_outlined, title: 'Diseases', subtitle: 'Symptoms, causes and validated care guidance'),
          _LibraryTile(icon: Icons.healing_outlined, title: 'Treatment', subtitle: 'Practical management and prevention'),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(selectedIndex: 2),
    );
  }
}

class _LibraryTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _LibraryTile({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: PlantCareSpacing.sm),
      child: ListTile(
        contentPadding: const EdgeInsets.all(PlantCareSpacing.sm),
        leading: CircleAvatar(
          backgroundColor: PlantCareColors.surface,
          child: Icon(icon, color: PlantCareColors.primary),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
