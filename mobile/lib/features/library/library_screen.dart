import 'package:flutter/material.dart';
import '../../core/navigation/app_router.dart';
import '../../core/theme/app_theme.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});
  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final q = TextEditingController();
  String query = '';
  @override
  void dispose() {
    q.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext c) {
    final cats = [
      ('Plant diseases', Icons.coronavirus_outlined),
      ('Watering', Icons.water_drop_outlined),
      ('Pests', Icons.bug_report_outlined),
      ('Soil & light', Icons.wb_sunny_outlined),
      ('Nutrition', Icons.grass_outlined),
      ('Prevention', Icons.health_and_safety_outlined)
    ];
    final guides = [
      (
        'Yellow leaves',
        'Common causes and first checks.',
        Icons.warning_amber_outlined
      ),
      (
        'Overwatering',
        'Signs, checks and recovery steps.',
        Icons.water_damage_outlined
      ),
      (
        'Leaf spots',
        'Prepare a clearer AI scan.',
        Icons.center_focus_strong_outlined
      )
    ];
    return Scaffold(
        body: SafeArea(
            child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
                children: [
              Row(children: [
                const Expanded(
                    child: Text('Library',
                        style: TextStyle(
                            fontSize: 25, fontWeight: FontWeight.w900))),
                IconButton(
                    tooltip: 'Notifications',
                    onPressed: () =>
                        Navigator.pushNamed(c, AppRouter.notifications),
                    icon: const Icon(Icons.notifications_none_rounded))
              ]),
              const SizedBox(height: 10),
              TextField(
                  controller: q,
                  onChanged: (v) => setState(() => query = v.toLowerCase()),
                  decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search_rounded),
                      hintText: 'Search plants, diseases and care',
                      suffixIcon: Icon(Icons.tune_rounded))),
              const SizedBox(height: 20),
              const Text('CATEGORIES',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: .7,
                      color: PlantCareColors.primary)),
              const SizedBox(height: 10),
              GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: cats.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisExtent: 70,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10),
                  itemBuilder: (c, i) => Card(
                      child: InkWell(
                          onTap: () => ScaffoldMessenger.of(c).showSnackBar(
                              SnackBar(
                                  content: Text(cats[i].$1 + ' selected'))),
                          child: Padding(
                              padding: const EdgeInsets.all(11),
                              child: Row(children: [
                                Icon(cats[i].$2,
                                    color: PlantCareColors.primary),
                                const SizedBox(width: 9),
                                Expanded(
                                    child: Text(cats[i].$1,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w800)))
                              ]))))),
              const SizedBox(height: 22),
              const Text('POPULAR GUIDES',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: .7,
                      color: PlantCareColors.primary)),
              const SizedBox(height: 10),
              for (final g in guides)
                if (query.isEmpty || g.$1.toLowerCase().contains(query))
                  Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                          leading: Icon(g.$3, color: PlantCareColors.primary),
                          title: Text(g.$1,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w800)),
                          subtitle: Text(g.$2),
                          trailing: const Icon(Icons.chevron_right_rounded))),
              const SizedBox(height: 12),
              Card(
                  color: PlantCareColors.primary,
                  child: ListTile(
                      contentPadding: const EdgeInsets.all(14),
                      leading: const Icon(Icons.support_agent_outlined,
                          color: Colors.white, size: 30),
                      title: const Text('Need help?',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900)),
                      subtitle: const Text('Support and expert resources.',
                          style: TextStyle(color: Colors.white70)),
                      trailing: const Icon(Icons.arrow_forward_rounded,
                          color: Colors.white),
                      onTap: () => Navigator.pushNamed(c, AppRouter.support)))
            ])),
        bottomNavigationBar: const AppBottomNav(selectedIndex: 2));
  }
}
