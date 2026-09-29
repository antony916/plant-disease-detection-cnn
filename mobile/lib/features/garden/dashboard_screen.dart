import 'package:flutter/material.dart';

import '../../core/app_services.dart';
import '../../core/models/garden.dart';
import '../../core/models/garden_task.dart';
import '../../core/models/plant.dart';
import '../../core/navigation/app_router.dart';
import '../../core/theme/app_theme.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<Garden> _gardenFuture;
  late Future<List<Plant>> _plantsFuture;
  late Future<List<GardenTask>> _tasksFuture;

  @override
  void initState() {
    super.initState();
    _load();
    _syncNotifications();
  }

  void _load() {
    _gardenFuture = AppServices.garden.getGarden();
    _plantsFuture = AppServices.garden.getPlants();
    _tasksFuture = AppServices.garden.getTodayTasks();
  }

  Future<void> _refresh() async {
    setState(_load);
    await _syncNotifications();
  }

  Future<void> _syncNotifications() async {
    final plants = await AppServices.garden.getPlants();
    final tasks = await AppServices.garden.getTodayTasks();
    await AppServices.notificationCoordinator.syncGardenTasks(
      plants: plants,
      tasks: tasks,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: FutureBuilder<List<Plant>>(
            future: _plantsFuture,
            builder: (context, snapshot) {
              final plants = snapshot.data ?? const <Plant>[];

              return CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                      child: _Header(gardenFuture: _gardenFuture)),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _SearchBar(
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRouter.library,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _ScanBanner(
                          onScan: () => Navigator.pushNamed(
                            context,
                            AppRouter.scanner,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const _SectionTitle(title: 'Quick actions'),
                        const SizedBox(height: 10),
                        _QuickActions(
                          onScan: () => Navigator.pushNamed(
                            context,
                            AppRouter.scanner,
                          ),
                          onGarden: () {},
                          onHealth: () => Navigator.pushNamed(
                            context,
                            AppRouter.diagnosisHistory,
                          ),
                          onLibrary: () => Navigator.pushNamed(
                            context,
                            AppRouter.library,
                          ),
                        ),
                        const SizedBox(height: 20),
                        FutureBuilder<List<GardenTask>>(
                          future: _tasksFuture,
                          builder: (context, taskSnapshot) {
                            if (taskSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const _SectionSkeleton();
                            }

                            final tasks =
                                taskSnapshot.data ?? const <GardenTask>[];
                            return _NeedsAttention(
                              tasks: tasks,
                              onComplete: (task) async {
                                await AppServices.garden.completeTask(task.id);
                                await _refresh();
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        _SectionTitle(
                          title: 'Recommended for you',
                          action: 'See all',
                          onAction: () => Navigator.pushNamed(
                            context,
                            AppRouter.library,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _Recommendations(
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRouter.library,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _SectionTitle(
                          title: 'Your garden',
                          action: plants.isEmpty ? null : 'See all',
                          onAction: () {},
                        ),
                        const SizedBox(height: 10),
                        if (plants.isEmpty)
                          _EmptyGarden(
                            onAdd: () => Navigator.pushNamed(
                              context,
                              AppRouter.addPlant,
                            ),
                            onScan: () => Navigator.pushNamed(
                              context,
                              AppRouter.scanner,
                            ),
                          )
                        else
                          _GardenList(
                            plants: plants,
                            onPlant: (plant) => Navigator.pushNamed(
                              context,
                              AppRouter.plant,
                              arguments: plant.name,
                            ),
                          ),
                        const SizedBox(height: 12),
                      ]),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNav(selectedIndex: 0),
    );
  }
}

class _Header extends StatelessWidget {
  final Future<Garden> gardenFuture;

  const _Header({required this.gardenFuture});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: FutureBuilder<Garden>(
              future: gardenFuture,
              builder: (context, snapshot) {
                final name = snapshot.data?.name ?? 'My Garden';
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'PlantCare AI',
                      style: TextStyle(
                        color: PlantCareColors.primary,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      name,
                      style: const TextStyle(
                        color: PlantCareColors.muted,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          _HeaderAction(
            icon: Icons.notifications_none_rounded,
            tooltip: 'Notifications',
            onTap: () => Navigator.pushNamed(
              context,
              AppRouter.notifications,
            ),
          ),
          const SizedBox(width: 8),
          _HeaderAction(
            icon: Icons.person_outline_rounded,
            tooltip: 'Profile',
            onTap: () => Navigator.pushNamed(
              context,
              AppRouter.profile,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderAction extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _HeaderAction({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(
        side: BorderSide(color: PlantCareColors.border),
      ),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Tooltip(
          message: tooltip,
          child: const SizedBox(
            width: 44,
            height: 44,
            child: Icon(Icons.notifications_none_rounded),
          ),
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final VoidCallback onTap;

  const _SearchBar({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: PlantCareColors.border),
          ),
          child: const Row(
            children: [
              Icon(Icons.search_rounded, color: PlantCareColors.text),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Search plants, diseases, care tips...',
                  style: TextStyle(color: PlantCareColors.muted),
                ),
              ),
              Icon(
                Icons.auto_awesome,
                size: 18,
                color: PlantCareColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScanBanner extends StatelessWidget {
  final VoidCallback onScan;

  const _ScanBanner({required this.onScan});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
      decoration: BoxDecoration(
        color: PlantCareColors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SMART PLANT CARE',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .8,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Scan. Diagnose.\nCare with confidence.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    height: 1.08,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'AI-powered plant health in seconds.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: onScan,
            style: FilledButton.styleFrom(
              backgroundColor: PlantCareColors.accent,
              foregroundColor: PlantCareColors.primaryDark,
              minimumSize: const Size(96, 44),
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            child: const Text('Scan plant'),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  final VoidCallback onScan;
  final VoidCallback onGarden;
  final VoidCallback onHealth;
  final VoidCallback onLibrary;

  const _QuickActions({
    required this.onScan,
    required this.onGarden,
    required this.onHealth,
    required this.onLibrary,
  });

  @override
  Widget build(BuildContext context) {
    final actions = [
      (Icons.center_focus_strong_rounded, 'Scan', onScan),
      (Icons.eco_rounded, 'My Garden', onGarden),
      (Icons.health_and_safety_outlined, 'Health', onHealth),
      (Icons.auto_awesome_mosaic_outlined, 'Library', onLibrary),
    ];

    return Row(
      children: [
        for (var i = 0; i < actions.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: _ActionTile(
              icon: actions[i].$1,
              label: actions[i].$2,
              onTap: actions[i].$3,
            ),
          ),
        ],
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 72,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: PlantCareColors.border),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 22, color: PlantCareColors.primary),
              const SizedBox(height: 6),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NeedsAttention extends StatelessWidget {
  final List<GardenTask> tasks;
  final Future<void> Function(GardenTask) onComplete;

  const _NeedsAttention({
    required this.tasks,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return Container(
        padding: const EdgeInsets.fromLTRB(14, 13, 12, 13),
        decoration: BoxDecoration(
          color: PlantCareColors.warm,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Row(
          children: [
            Icon(Icons.check_circle_outline, color: PlantCareColors.success),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'All caught up. Your garden is on track today.',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      );
    }

    final task = tasks.first;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
      decoration: BoxDecoration(
        color: PlantCareColors.warm,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.notifications_active_outlined,
              color: PlantCareColors.warning),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'NEEDS ATTENTION',
                  style: TextStyle(
                    color: PlantCareColors.warning,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  task.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 2),
                Text(
                  task.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: PlantCareColors.muted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: () => onComplete(task),
            style: FilledButton.styleFrom(
              minimumSize: const Size(58, 38),
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}

class _Recommendations extends StatelessWidget {
  final VoidCallback onTap;

  const _Recommendations({required this.onTap});

  @override
  Widget build(BuildContext context) {
    const cards = [
      (
        '🌿',
        'Leaf health guide',
        'Spot common warning signs',
        PlantCareColors.softGreen
      ),
      (
        '🐛',
        'Pest warning signs',
        'Know what to check early',
        PlantCareColors.softBlue
      ),
    ];

    return SizedBox(
      height: 126,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: cards.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final card = cards[index];
          return InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 190,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: PlantCareColors.border),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 66,
                      width: double.infinity,
                      color: card.$3,
                      alignment: Alignment.center,
                      child:
                          Text(card.$1, style: const TextStyle(fontSize: 30)),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            card.$2,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            card.$3 == PlantCareColors.softGreen
                                ? 'Spot common warning signs'
                                : 'Know what to check early',
                            style: const TextStyle(
                              color: PlantCareColors.muted,
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _GardenList extends StatelessWidget {
  final List<Plant> plants;
  final ValueChanged<Plant> onPlant;

  const _GardenList({
    required this.plants,
    required this.onPlant,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < plants.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              onTap: () => onPlant(plants[i]),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: PlantCareColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: PlantCareColors.softGreen,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _plantEmoji(plants[i].name),
                        style: const TextStyle(fontSize: 25),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            plants[i].name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            plants[i].health,
                            style: const TextStyle(
                              color: PlantCareColors.muted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _EmptyGarden extends StatelessWidget {
  final VoidCallback onAdd;
  final VoidCallback onScan;

  const _EmptyGarden({
    required this.onAdd,
    required this.onScan,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PlantCareColors.border),
      ),
      child: Column(
        children: [
          const Text('🌱', style: TextStyle(fontSize: 42)),
          const SizedBox(height: 6),
          const Text(
            'Start your garden',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          const Text(
            'Add a plant or scan one with AI.',
            textAlign: TextAlign.center,
            style: TextStyle(color: PlantCareColors.muted),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: onAdd,
                  child: const Text('Add plant'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: onScan,
                  child: const Text('Scan'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;

  const _SectionTitle({
    required this.title,
    this.action,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w900,
              letterSpacing: -.2,
            ),
          ),
        ),
        if (action != null)
          TextButton(
            onPressed: onAction,
            child: Text(action!),
          ),
      ],
    );
  }
}

class _SectionSkeleton extends StatelessWidget {
  const _SectionSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: PlantCareColors.border),
      ),
      alignment: Alignment.center,
      child: const SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
}

String _plantEmoji(String name) {
  final value = name.toLowerCase();
  if (value.contains('tomato')) return '🍅';
  if (value.contains('rose')) return '🌹';
  if (value.contains('apple')) return '🍎';
  if (value.contains('grape')) return '🍇';
  if (value.contains('corn') || value.contains('maize')) return '🌽';
  if (value.contains('potato')) return '🥔';
  if (value.contains('pepper')) return '🌶️';
  return '🌿';
}
