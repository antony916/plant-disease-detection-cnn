import 'package:flutter/material.dart';

import '../../core/navigation/app_router.dart';
import '../../core/theme/app_theme.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Good morning 👋', style: TextStyle(fontSize: 14, color: PlantCareColors.muted)),
            Text('My Garden', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
          ],
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.account_circle_outlined)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(PlantCareSpacing.lg),
        children: [
          Container(
            padding: const EdgeInsets.all(PlantCareSpacing.lg),
            decoration: BoxDecoration(
              color: PlantCareColors.primary,
              borderRadius: BorderRadius.circular(PlantCareRadius.featured),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Garden health', style: TextStyle(color: Colors.white70)),
                SizedBox(height: 6),
                Text('Looking healthy 🌿', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                SizedBox(height: 8),
                Text('3 plants need attention today.', style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          const SizedBox(height: PlantCareSpacing.lg),
          Row(
            children: [
              Expanded(child: _QuickAction(icon: Icons.camera_alt_outlined, title: 'Scan plant', onTap: () => Navigator.pushNamed(context, AppRouter.scanner))),
              const SizedBox(width: PlantCareSpacing.sm),
              Expanded(child: _QuickAction(icon: Icons.add_circle_outline, title: 'Add plant', onTap: () {})),
            ],
          ),
          const SizedBox(height: PlantCareSpacing.lg),
          Text('Today', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: PlantCareSpacing.sm),
          _TaskCard(
            icon: Icons.water_drop_outlined,
            title: 'Water Tomato',
            subtitle: 'Due today • Balcony',
            action: 'Watered',
          ),
          const SizedBox(height: PlantCareSpacing.sm),
          _TaskCard(
            icon: Icons.wb_sunny_outlined,
            title: 'Move Mint to brighter light',
            subtitle: 'Care suggestion',
            action: 'Done',
          ),
          const SizedBox(height: PlantCareSpacing.lg),
          Text('My plants', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: PlantCareSpacing.sm),
          _PlantCard(name: 'Tomato', subtitle: 'Healthy • Water today', emoji: '🍅', onTap: () => Navigator.pushNamed(context, AppRouter.plant, arguments: 'Tomato')),
          const SizedBox(height: PlantCareSpacing.sm),
          _PlantCard(name: 'Mint', subtitle: 'Healthy • Next water tomorrow', emoji: '🌿', onTap: () => Navigator.pushNamed(context, AppRouter.plant, arguments: 'Mint')),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(selectedIndex: 0),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _QuickAction({required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(title),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String action;

  const _TaskCard({required this.icon, required this.title, required this.subtitle, required this.action});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(PlantCareSpacing.md),
        child: Row(
          children: [
            CircleAvatar(backgroundColor: PlantCareColors.surface, child: Icon(icon, color: PlantCareColors.primary)),
            const SizedBox(width: PlantCareSpacing.md),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w700)), const SizedBox(height: 3), Text(subtitle, style: const TextStyle(color: PlantCareColors.muted, fontSize: 13))])),
            TextButton(onPressed: () {}, child: Text(action)),
          ],
        ),
      ),
    );
  }
}

class _PlantCard extends StatelessWidget {
  final String name;
  final String subtitle;
  final String emoji;
  final VoidCallback onTap;

  const _PlantCard({required this.name, required this.subtitle, required this.emoji, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(PlantCareRadius.card),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(PlantCareSpacing.md),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: PlantCareColors.surface, borderRadius: BorderRadius.circular(14)),
                child: Text(emoji, style: const TextStyle(fontSize: 28)),
              ),
              const SizedBox(width: PlantCareSpacing.md),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: const TextStyle(fontWeight: FontWeight.w800)), const SizedBox(height: 3), Text(subtitle, style: const TextStyle(color: PlantCareColors.muted, fontSize: 13))])),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
