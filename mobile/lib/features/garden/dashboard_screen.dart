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
  late Future<Garden> _garden;
  late Future<List<Plant>> _plants;
  late Future<List<GardenTask>> _tasks;
  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _garden = AppServices.garden.getGarden();
    _plants = AppServices.garden.getPlants();
    _tasks = AppServices.garden.getTodayTasks();
  }

  Future<void> _refresh() async {
    setState(_load);
    await Future.wait([_plants, _tasks]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: FutureBuilder<List<Plant>>(
            future: _plants,
            builder: (context, snapshot) {
              final plants = snapshot.data ?? const <Plant>[];
              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
                children: [
                  Row(children: [
                    Expanded(
                        child: FutureBuilder<Garden>(
                            future: _garden,
                            builder: (context, g) => Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text('PlantCare AI',
                                          style: TextStyle(
                                              color: PlantCareColors.primary,
                                              fontSize: 20,
                                              fontWeight: FontWeight.w900)),
                                      Text(g.data?.name ?? 'My Garden',
                                          style: const TextStyle(
                                              color: PlantCareColors.muted,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600)),
                                    ]))),
                    IconButton(
                        tooltip: 'Notifications',
                        onPressed: () => Navigator.pushNamed(
                            context, AppRouter.notifications),
                        icon: const Icon(Icons.notifications_none_rounded)),
                    IconButton(
                        tooltip: 'Profile',
                        onPressed: () =>
                            Navigator.pushNamed(context, AppRouter.profile),
                        icon: const Icon(Icons.person_outline_rounded)),
                  ]),
                  const SizedBox(height: 10),
                  TextField(
                      readOnly: true,
                      onTap: () =>
                          Navigator.pushNamed(context, AppRouter.library),
                      decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.search_rounded),
                          hintText: 'Search plants, diseases or care',
                          suffixIcon: Icon(Icons.tune_rounded))),
                  const SizedBox(height: 14),
                  Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                          color: PlantCareColors.primary,
                          borderRadius: BorderRadius.circular(12)),
                      child: const Row(children: [
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Text('CHECK YOUR PLANT',
                                  style: TextStyle(
                                      color: PlantCareColors.accent,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: .8)),
                              SizedBox(height: 7),
                              Text('AI plant health check',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900)),
                              SizedBox(height: 4),
                              Text('Upload a photo and get a quick diagnosis.',
                                  style: TextStyle(
                                      color: Colors.white70, fontSize: 12)),
                            ])),
                        Icon(Icons.camera_alt_rounded,
                            color: Colors.white, size: 42),
                      ])),
                  const SizedBox(height: 8),
                  SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                              backgroundColor: PlantCareColors.accent,
                              foregroundColor: PlantCareColors.primaryDark),
                          onPressed: () =>
                              Navigator.pushNamed(context, AppRouter.scanner),
                          icon: const Icon(Icons.center_focus_strong),
                          label: const Text('SCAN NOW'))),
                  const SizedBox(height: 22),
                  const Text('Quick actions',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 10),
                  Row(children: [
                    _Action(Icons.camera_alt_outlined, 'Scan',
                        () => Navigator.pushNamed(context, AppRouter.scanner)),
                    _Action(Icons.eco_outlined, 'Plants',
                        () => Navigator.pushNamed(context, AppRouter.addPlant)),
                    _Action(
                        Icons.health_and_safety_outlined,
                        'Health',
                        () => Navigator.pushNamed(
                            context, AppRouter.diagnosisHistory)),
                    _Action(Icons.menu_book_outlined, 'Guides',
                        () => Navigator.pushNamed(context, AppRouter.library)),
                  ]),
                  const SizedBox(height: 22),
                  _Section(
                      'NEEDS ATTENTION',
                      'View all',
                      () => Navigator.pushNamed(
                          context, AppRouter.diagnosisHistory)),
                  FutureBuilder<List<GardenTask>>(
                      future: _tasks,
                      builder: (context, snapshot) {
                        final list = snapshot.data ?? const <GardenTask>[];
                        if (list.isEmpty)
                          return const _Info(
                              icon: Icons.check_circle_outline,
                              title: 'Everything is up to date',
                              sub:
                                  'No care tasks need your attention right now.');
                        final task = list.first;
                        return _Task(
                            task: task,
                            done: () async {
                              await AppServices.garden.completeTask(task.id);
                              await _refresh();
                            });
                      }),
                  const SizedBox(height: 22),
                  _Section(
                      'HEALTH TIMELINE',
                      'View all',
                      () => Navigator.pushNamed(
                          context, AppRouter.diagnosisHistory)),
                  Card(
                      child: ListTile(
                          leading: const CircleAvatar(
                              backgroundColor: PlantCareColors.softGreen,
                              child: Icon(Icons.history_rounded,
                                  color: PlantCareColors.primary)),
                          title: const Text('Previous AI diagnoses',
                              style: TextStyle(fontWeight: FontWeight.w800)),
                          subtitle: const Text(
                              'Review results and confidence over time.'),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () => Navigator.pushNamed(
                              context, AppRouter.diagnosisHistory))),
                  const SizedBox(height: 22),
                  _Section('RECOMMENDED FOR YOU', 'See all',
                      () => Navigator.pushNamed(context, AppRouter.library)),
                  Row(children: [
                    _Guide(
                        Icons.water_drop_outlined,
                        'Watering',
                        'Know when to water',
                        () => Navigator.pushNamed(context, AppRouter.library)),
                    _Guide(
                        Icons.bug_report_outlined,
                        'Pests',
                        'Spot warning signs',
                        () => Navigator.pushNamed(context, AppRouter.library)),
                  ]),
                  const SizedBox(height: 22),
                  _Section(
                      'YOUR PLANTS',
                      plants.isEmpty ? 'Add plant' : 'See all',
                      () => Navigator.pushNamed(context, AppRouter.addPlant)),
                  if (plants.isEmpty)
                    const _Info(
                        icon: Icons.add_circle_outline,
                        title: 'Start your garden',
                        sub:
                            'Add your first plant and keep its care history in one place.')
                  else
                    ...plants.take(4).map((p) => _Plant(
                        p,
                        () => Navigator.pushNamed(context, AppRouter.plant,
                            arguments: p.name))),
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

class _Action extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _Action(this.icon, this.label, this.onTap);
  @override
  Widget build(BuildContext c) => Expanded(
      child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Column(children: [
            Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                    color: PlantCareColors.softGreen,
                    borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: PlantCareColors.primary)),
            const SizedBox(height: 6),
            Text(label,
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w700))
          ])));
}

class _Section extends StatelessWidget {
  final String title, action;
  final VoidCallback onTap;
  const _Section(this.title, this.action, this.onTap);
  @override
  Widget build(BuildContext c) => Row(children: [
        Expanded(
            child: Text(title,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .5))),
        TextButton(onPressed: onTap, child: Text(action))
      ]);
}

class _Task extends StatelessWidget {
  final GardenTask task;
  final VoidCallback done;
  const _Task({required this.task, required this.done});
  @override
  Widget build(BuildContext c) => Card(
      child: ListTile(
          contentPadding: const EdgeInsets.all(12),
          leading: const CircleAvatar(
              backgroundColor: PlantCareColors.warm,
              child: Icon(Icons.notifications_active_outlined,
                  color: PlantCareColors.warning)),
          title: Text(task.title,
              style: const TextStyle(fontWeight: FontWeight.w800)),
          subtitle:
              Text(task.subtitle, maxLines: 2, overflow: TextOverflow.ellipsis),
          trailing:
              OutlinedButton(onPressed: done, child: const Text('Done'))));
}

class _Info extends StatelessWidget {
  final IconData icon;
  final String title, sub;
  const _Info({required this.icon, required this.title, required this.sub});
  @override
  Widget build(BuildContext c) => Card(
      child: ListTile(
          contentPadding: const EdgeInsets.all(14),
          leading: Icon(icon, color: PlantCareColors.primary),
          title:
              Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
          subtitle: Text(sub),
          trailing: title == 'Start your garden'
              ? FilledButton(
                  onPressed: () => Navigator.pushNamed(c, AppRouter.addPlant),
                  child: const Text('ADD'))
              : null));
}

class _Guide extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final VoidCallback onTap;
  const _Guide(this.icon, this.title, this.subtitle, this.onTap);
  @override
  Widget build(BuildContext c) => Expanded(
      child: Card(
          child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(icon, color: PlantCareColors.primary),
                        const SizedBox(height: 9),
                        Text(title,
                            style:
                                const TextStyle(fontWeight: FontWeight.w800)),
                        Text(subtitle,
                            style: const TextStyle(
                                color: PlantCareColors.muted, fontSize: 11))
                      ])))));
}

class _Plant extends StatelessWidget {
  final Plant plant;
  final VoidCallback onTap;
  const _Plant(this.plant, this.onTap);
  @override
  Widget build(BuildContext c) {
    final attention = plant.health.toLowerCase().contains('attention');
    return Card(
        child: ListTile(
            onTap: onTap,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
            leading: CircleAvatar(
                backgroundColor: attention
                    ? PlantCareColors.warm
                    : PlantCareColors.softGreen,
                child: Icon(
                    attention
                        ? Icons.warning_amber_rounded
                        : Icons.eco_outlined,
                    color: attention
                        ? PlantCareColors.warning
                        : PlantCareColors.primary)),
            title: Text(plant.name,
                style: const TextStyle(fontWeight: FontWeight.w800)),
            subtitle: Text('${plant.location} • ${plant.health}',
                maxLines: 1, overflow: TextOverflow.ellipsis),
            trailing: const Icon(Icons.chevron_right_rounded)));
  }
}
