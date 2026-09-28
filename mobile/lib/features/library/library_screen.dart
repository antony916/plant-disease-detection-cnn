import 'package:flutter/material.dart';

import '../../core/navigation/app_router.dart';
import '../../core/services/plant_knowledge_service.dart';
import '../../core/theme/app_theme.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Plant Library',
              style: TextStyle(fontWeight: FontWeight.w800))),
      body: ListView(
        padding: const EdgeInsets.all(PlantCareSpacing.lg),
        children: [
          Text('Learn before you grow',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
          SizedBox(height: 6),
          Text('Plants, diseases, pests and practical care guidance.',
              style: TextStyle(color: PlantCareColors.muted)),
          SizedBox(height: PlantCareSpacing.lg),
          _LibraryTile(
              icon: Icons.eco_outlined,
              title: 'Plants',
              subtitle: 'Vegetables, fruits, flowers, herbs and ornamentals'),
          _LibraryTile(
              icon: Icons.bug_report_outlined,
              title: 'Pests',
              subtitle: 'Recognize common pest damage and warning signs'),
          _LibraryTile(
              icon: Icons.health_and_safety_outlined,
              title: 'Diseases',
              subtitle: 'Symptoms, causes and validated care guidance'),
          _LibraryTile(
              icon: Icons.healing_outlined,
              title: 'Treatment',
              subtitle: 'Practical management and prevention'),
          const SizedBox(height: PlantCareSpacing.md),
          FilledButton.icon(
            onPressed: () => Navigator.pushNamed(
              context,
              AppRouter.diagnosisHistory,
            ),
            icon: const Icon(Icons.timeline_outlined),
            label: const Text('Health Timeline'),
          ),
          const SizedBox(height: PlantCareSpacing.lg),
          const Text('Starter knowledge',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: PlantCareSpacing.sm),
          for (final entry in const PlantKnowledgeService().entries)
            _KnowledgeCard(entry: entry),
          const SizedBox(height: PlantCareSpacing.lg),
          FilledButton.icon(
              onPressed: () => Navigator.pushNamed(context, AppRouter.support),
              icon: const Icon(Icons.support_agent_outlined),
              label: const Text('Community, experts & resources')),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(selectedIndex: 2),
    );
  }
}

class _KnowledgeCard extends StatelessWidget {
  final PlantKnowledgeEntry entry;
  const _KnowledgeCard({required this.entry});
  @override
  Widget build(BuildContext context) {
    return Card(
        margin: const EdgeInsets.only(bottom: PlantCareSpacing.sm),
        child: ExpansionTile(
            title: Text(entry.title,
                style: const TextStyle(fontWeight: FontWeight.w800)),
            subtitle: Text(entry.category),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            children: [
              Align(
                  alignment: Alignment.centerLeft, child: Text(entry.summary)),
              const SizedBox(height: 8),
              for (final tip in entry.careTips)
                Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text('• $tip')))
            ]));
  }
}

class _LibraryTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _LibraryTile(
      {required this.icon, required this.title, required this.subtitle});

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
