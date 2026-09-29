import 'package:flutter/material.dart';

import '../../core/app_services.dart';
import '../../core/models/plant.dart';
import '../../core/models/garden.dart';
import '../../core/models/garden_task.dart';
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
    _gardenFuture = AppServices.garden.getGarden();
    _plantsFuture = AppServices.garden.getPlants();
    _tasksFuture = AppServices.garden.getTodayTasks();
    _syncNotifications();
  }

  void _refresh() {
    setState(() {
      _gardenFuture = AppServices.garden.getGarden();
      _plantsFuture = AppServices.garden.getPlants();
      _tasksFuture = AppServices.garden.getTodayTasks();
    });
    _syncNotifications();
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
                  SliverToBoxAdapter(child: _DashboardHeader(gardenFuture: _gardenFuture)),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _GardenHero(
                          hasPlants: plants.isNotEmpty,
                          onScan: () => Navigator.pushNamed(context, AppRouter.scanner),
                          onAdd: () => Navigator.pushNamed(context, AppRouter.addPlant),
                        ),
                        const SizedBox(height: 24),
                        if (plants.isNotEmpty) ...[
                          _SectionHeading(
                            title: 'Your garden',
                            action: 'See all',
                            onTap: () {},
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 228,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: plants.length,
                              separatorBuilder: (_, __) => const SizedBox(width: 10),
                              itemBuilder: (context, index) {
                                final plant = plants[index];
                                return _PremiumPlantCard(
                                  plant: plant,
                                  onTap: () => Navigator.pushNamed(
                                    context,
                                    AppRouter.plant,
                                    arguments: plant.name,
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                        _SectionHeading(
                          title: 'Today',
                          action: 'Care plan',
                          onTap: () => Navigator.pushNamed(context, AppRouter.library),
                        ),
                        const SizedBox(height: 10),
                        FutureBuilder<List<GardenTask>>(
                          future: _tasksFuture,
                          builder: (context, taskSnapshot) {
                            if (taskSnapshot.connectionState == ConnectionState.waiting) {
                              return const _DashboardLoading();
                            }
                            final tasks = taskSnapshot.data ?? const <GardenTask>[];
                            if (tasks.isEmpty) return const _NoTasksCard();
                            return Column(
                              children: [
                                for (var i = 0; i < tasks.length; i++) ...[
                                  if (i > 0) const SizedBox(height: 8),
                                  _TaskCard(
                                    task: tasks[i],
                                    onComplete: tasks[i].completed
                                        ? null
                                        : () async {
                                            await AppServices.garden.completeTask(tasks[i].id);
                                            await _refresh();
                                          },
                                  ),
                                ],
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                        const _ExploreCards(),
                        if (plants.isEmpty) ...[
                          const SizedBox(height: 24),
                          _EmptyGarden(
                            onAdd: () => Navigator.pushNamed(context, AppRouter.addPlant),
                            onScan: () => Navigator.pushNamed(context, AppRouter.scanner),
                          ),
                        ],
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

class _DashboardHeader extends StatelessWidget {
  final Future<Garden> gardenFuture;
  const _DashboardHeader({required this.gardenFuture});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: FutureBuilder<Garden>(
              future: gardenFuture,
              builder: (context, snapshot) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Good morning 👋',
                    style: TextStyle(color: PlantCareColors.muted, fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    snapshot.data?.name ?? 'My Garden',
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -0.7),
                  ),
                ],
              ),
            ),
          ),
          _CircleAction(
            icon: Icons.notifications_none_rounded,
            tooltip: 'Notifications',
            onTap: () => Navigator.pushNamed(context, AppRouter.notifications),
          ),
          const SizedBox(width: 8),
          _CircleAction(
            icon: Icons.person_outline_rounded,
            tooltip: 'Profile',
            onTap: () => Navigator.pushNamed(context, AppRouter.profile),
          ),
        ],
      ),
    );
  }
}

class _CircleAction extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  const _CircleAction({required this.icon, required this.tooltip, required this.onTap});

  @override
  Widget build(BuildContext context) => Tooltip(
        message: tooltip,
        child: Material(
          color: PlantCareColors.card,
          shape: const CircleBorder(side: BorderSide(color: PlantCareColors.border)),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: SizedBox(width: 46, height: 46, child: Icon(icon)),
          ),
        ),
      );
}

class _GardenHero extends StatelessWidget {
  final bool hasPlants;
  final VoidCallback onScan;
  final VoidCallback onAdd;
  const _GardenHero({required this.hasPlants, required this.onScan, required this.onAdd});

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween(begin: .96, end: 1),
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
        builder: (_, scale, child) => Transform.scale(scale: scale, child: child),
        child: Container(
          constraints: const BoxConstraints(minHeight: 238),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [PlantCareColors.primaryDark, PlantCareColors.primary, Color(0xFF3D805A)],
            ),
            boxShadow: [
              BoxShadow(
                color: PlantCareColors.primary.withValues(alpha: .18),
                blurRadius: 28,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Stack(
            children: [
              const Positioned(right: -20, top: -28, child: Text('🌿', style: TextStyle(fontSize: 145))),
              const Positioned(right: 30, bottom: -35, child: Text('🍃', style: TextStyle(fontSize: 90))),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: .12), borderRadius: BorderRadius.circular(999)),
                    child: const Text('PLANTCARE AI', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    hasPlants ? 'Keep your garden\none step ahead.' : 'Your garden\nstarts here.',
                    style: const TextStyle(color: Colors.white, fontSize: 30, height: 1.04, fontWeight: FontWeight.w900, letterSpacing: -.8),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    hasPlants ? 'Scan a leaf, understand its health, and take action.' : 'Add a plant or scan one to start your AI garden.',
                    style: const TextStyle(color: Colors.white70, height: 1.35, fontSize: 14),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      FilledButton.icon(
                        onPressed: onScan,
                        icon: const Icon(Icons.center_focus_strong_rounded),
                        label: const Text('Scan plant'),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: PlantCareColors.primaryDark,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        tooltip: 'Add plant',
                        onPressed: onAdd,
                        style: IconButton.styleFrom(backgroundColor: Colors.white.withValues(alpha: .14), foregroundColor: Colors.white),
                        icon: const Icon(Icons.add_rounded),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      );
}

class _SectionHeading extends StatelessWidget {
  final String title;
  final String action;
  final VoidCallback onTap;
  const _SectionHeading({required this.title, required this.action, required this.onTap});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(child: Text(title, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900, letterSpacing: -.3))),
          TextButton(onPressed: onTap, child: Text(action)),
        ],
      );
}

class _PremiumPlantCard extends StatefulWidget {
  final Plant plant;
  final VoidCallback onTap;
  const _PremiumPlantCard({required this.plant, required this.onTap});

  @override
  State<_PremiumPlantCard> createState() => _PremiumPlantCardState();
}

class _PremiumPlantCardState extends State<_PremiumPlantCard> {
  bool pressed = false;

  @override
  Widget build(BuildContext context) {
    final healthy = widget.plant.health.toLowerCase().contains('healthy');
    final status = healthy ? PlantCareColors.success : PlantCareColors.warning;
    return GestureDetector(
      onTapDown: (_) => setState(() => pressed = true),
      onTapCancel: () => setState(() => pressed = false),
      onTapUp: (_) { setState(() => pressed = false); widget.onTap(); },
      child: AnimatedScale(
        scale: pressed ? .97 : 1,
        duration: const Duration(milliseconds: 120),
        child: SizedBox(
          width: 190,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: PlantCareColors.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: PlantCareColors.border),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .04), blurRadius: 18, offset: const Offset(0, 8))],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFE3F0E5), Color(0xFFBFDCC5)],
                        ),
                      ),
                      child: Center(child: Text(_plantEmoji(widget.plant.name), style: const TextStyle(fontSize: 76))),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.plant.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Container(width: 7, height: 7, decoration: BoxDecoration(color: status, shape: BoxShape.circle)),
                            const SizedBox(width: 6),
                            Expanded(child: Text(widget.plant.health, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: PlantCareColors.muted, fontSize: 12, fontWeight: FontWeight.w600))),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DashboardLoading extends StatelessWidget {
  const _DashboardLoading();
  @override
  Widget build(BuildContext context) => const Card(child: Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator())));
}

class _NoTasksCard extends StatelessWidget {
  const _NoTasksCard();
  @override
  Widget build(BuildContext context) => const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.check_circle_outline, color: PlantCareColors.success),
              SizedBox(width: 8),
              Expanded(child: Text('Nothing urgent today. Your garden is on track.', style: TextStyle(fontWeight: FontWeight.w600))),
            ],
          ),
        ),
      );
}

class _ExploreCards extends StatelessWidget {
  const _ExploreCards();
  @override
  Widget build(BuildContext context) {
    const items = [
      ('🩺', 'Plant diseases', 'Spot symptoms early'),
      ('🐛', 'Pest guide', 'Know what to look for'),
      ('💧', 'Smart watering', 'Build better routines'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Explore', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900, letterSpacing: -.3)),
        const SizedBox(height: 10),
        SizedBox(
          height: 124,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) => Container(
              width: 190,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: PlantCareColors.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: PlantCareColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(items[i].$1, style: const TextStyle(fontSize: 26)),
                  const Spacer(),
                  Text(items[i].$2, style: const TextStyle(fontWeight: FontWeight.w800)),
                  Text(items[i].$3, style: const TextStyle(color: PlantCareColors.muted, fontSize: 11)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyGarden extends StatelessWidget {
  final VoidCallback onAdd;
  final VoidCallback onScan;
  const _EmptyGarden({required this.onAdd, required this.onScan});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: PlantCareColors.card,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: PlantCareColors.border),
        ),
        child: Column(
          children: [
            const Text('🌱', style: TextStyle(fontSize: 54)),
            const SizedBox(height: 8),
            const Text('Build your garden', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            const Text('Add your first plant or scan one with AI.', textAlign: TextAlign.center, style: TextStyle(color: PlantCareColors.muted)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: FilledButton(onPressed: onAdd, child: const Text('Add plant'))),
                const SizedBox(width: 8),
                Expanded(child: OutlinedButton(onPressed: onScan, child: const Text('Scan'))),
              ],
            ),
          ],
        ),
      );
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

class _TaskCard extends StatelessWidget {
  final GardenTask task;
  final VoidCallback? onComplete;

  const _TaskCard({required this.task, required this.onComplete});

  @override
  Widget build(BuildContext context) {
    final icon = switch (task.type) {
      GardenTaskType.watering => Icons.water_drop_outlined,
      GardenTaskType.sunlight => Icons.wb_sunny_outlined,
      GardenTaskType.care => Icons.eco_outlined,
      GardenTaskType.diagnosis => Icons.health_and_safety_outlined,
    };

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: PlantCareColors.surface,
          child: Icon(icon, color: PlantCareColors.primary),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            decoration: task.completed ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Text(task.subtitle),
        trailing: task.completed
            ? const Icon(Icons.check_circle, color: PlantCareColors.success)
            : TextButton(
                onPressed: onComplete,
                child: Text(
                  task.type == GardenTaskType.watering ? 'Watered' : 'Done',
                ),
              ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(title),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}

class _PlantCard extends StatelessWidget {
  final Plant plant;
  final VoidCallback onTap;

  const _PlantCard({required this.plant, required this.onTap});

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
                decoration: BoxDecoration(
                  color: PlantCareColors.surface,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  plant.name.toLowerCase().contains('tomato') ? '🍅' : '🌿',
                  style: const TextStyle(fontSize: 28),
                ),
              ),
              const SizedBox(width: PlantCareSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plant.name,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      plant.health,
                      style: const TextStyle(
                        color: PlantCareColors.muted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  final String? action;
  final VoidCallback? onPressed;

  const _EmptyState({
    required this.message,
    this.action,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(PlantCareSpacing.lg),
        child: Column(
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: PlantCareColors.muted),
            ),
            if (action != null) ...[
              const SizedBox(height: PlantCareSpacing.sm),
              TextButton(
                onPressed: onPressed,
                child: Text(action!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
