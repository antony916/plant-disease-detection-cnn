import 'package:flutter/material.dart';

import '../../core/app_services.dart';
import '../../core/models/plant.dart';
import '../../core/models/garden_task.dart';
import '../../core/navigation/app_router.dart';
import '../../core/theme/app_theme.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<List<Plant>> _plantsFuture;
  late Future<List<GardenTask>> _tasksFuture;

  @override
  void initState() {
    super.initState();
    _plantsFuture = AppServices.garden.getPlants();
    _tasksFuture = AppServices.garden.getTodayTasks();
  }

  void _refresh() {
    setState(() {
      _plantsFuture = AppServices.garden.getPlants();
      _tasksFuture = AppServices.garden.getTodayTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good morning 👋',
              style: TextStyle(
                fontSize: 14,
                color: PlantCareColors.muted,
              ),
            ),
            Text(
              'My Garden',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.account_circle_outlined),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _refresh(),
        child: ListView(
          padding: const EdgeInsets.all(PlantCareSpacing.lg),
          children: [
            Container(
              padding: const EdgeInsets.all(PlantCareSpacing.lg),
              decoration: BoxDecoration(
                color: PlantCareColors.primary,
                borderRadius: BorderRadius.circular(
                  PlantCareRadius.featured,
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Garden health',
                    style: TextStyle(color: Colors.white70),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Looking healthy 🌿',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Your garden status will become personalized as plants and diagnoses are saved.',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: PlantCareSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: _QuickAction(
                    icon: Icons.camera_alt_outlined,
                    title: 'Scan plant',
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRouter.scanner,
                    ),
                  ),
                ),
                const SizedBox(width: PlantCareSpacing.sm),
                Expanded(
                  child: _QuickAction(
                    icon: Icons.add_circle_outline,
                    title: 'Add plant',
                    onTap: () => Navigator.pushNamed(context, AppRouter.addPlant),
                  ),
                ),
              ],
            ),
            const SizedBox(height: PlantCareSpacing.lg),
            Text(
              'Today',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: PlantCareSpacing.sm),
            FutureBuilder<List<GardenTask>>(
              future: _tasksFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(PlantCareSpacing.md),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final tasks = snapshot.data ?? const <GardenTask>[];
                if (tasks.isEmpty) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(PlantCareSpacing.md),
                      child: Text(
                        'No care tasks due today.',
                        style: TextStyle(color: PlantCareColors.muted),
                      ),
                    ),
                  );
                }
                return Column(
                  children: [
                    for (int i = 0; i < tasks.length; i++) ...[
                      if (i > 0) const SizedBox(height: PlantCareSpacing.sm),
                      _TaskCard(
                        task: tasks[i],
                        onComplete: tasks[i].completed
                            ? null
                            : () async {
                                await AppServices.garden.completeTask(tasks[i].id);
                                _refresh();
                              },
                      ),
                    ],
                  ],
                );
              },
            ),
            const SizedBox(height: PlantCareSpacing.lg),
            Text(
              'My plants',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: PlantCareSpacing.sm),
            FutureBuilder<List<Plant>>(
              future: _plantsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(PlantCareSpacing.xl),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (snapshot.hasError) {
                  return _EmptyState(
                    message: 'We could not load your plants.',
                    action: 'Try again',
                    onPressed: _refresh,
                  );
                }

                final plants = snapshot.data ?? const <Plant>[];
                if (plants.isEmpty) {
                  return const _EmptyState(
                    message: 'Your garden is empty. Add your first plant to get started.',
                  );
                }

                return Column(
                  children: [
                    for (int i = 0; i < plants.length; i++) ...[
                      if (i > 0)
                        const SizedBox(height: PlantCareSpacing.sm),
                      _PlantCard(
                        plant: plants[i],
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRouter.plant,
                          arguments: plants[i].name,
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNav(selectedIndex: 0),
    );
  }
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
