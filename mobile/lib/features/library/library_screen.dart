import 'package:flutter/material.dart';

import '../../core/navigation/app_router.dart';
import '../../core/services/plant_knowledge_service.dart';
import '../../core/theme/app_theme.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final PlantKnowledgeService _knowledge = const PlantKnowledgeService();
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final results = _knowledge.search(_query);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Plant Library',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Learn before you grow.',
                        style: TextStyle(color: PlantCareColors.muted),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Health timeline',
                  onPressed: () => Navigator.pushNamed(
                    context,
                    AppRouter.diagnosisHistory,
                  ),
                  icon: const Icon(Icons.timeline_outlined),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              onChanged: (value) => setState(() => _query = value),
              decoration: InputDecoration(
                hintText: 'Search plants, diseases, care tips...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _query.isEmpty
                    ? const Icon(
                        Icons.auto_awesome,
                        color: PlantCareColors.primary,
                      )
                    : IconButton(
                        tooltip: 'Clear search',
                        onPressed: () => setState(() => _query = ''),
                        icon: const Icon(Icons.clear),
                      ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Explore',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: const [
                Expanded(
                  child: _CategoryCard(
                    icon: Icons.eco_outlined,
                    title: 'Plants',
                    color: PlantCareColors.softGreen,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: _CategoryCard(
                    icon: Icons.bug_report_outlined,
                    title: 'Pests',
                    color: PlantCareColors.softBlue,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: _CategoryCard(
                    icon: Icons.health_and_safety_outlined,
                    title: 'Diseases',
                    color: PlantCareColors.warm,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
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
                          'Health Timeline',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Review your previous AI scan results.',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pushNamed(
                      context,
                      AppRouter.diagnosisHistory,
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: PlantCareColors.accent,
                      foregroundColor: PlantCareColors.primaryDark,
                    ),
                    child: const Text('Open'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _query.isEmpty ? 'Starter knowledge' : 'Search results',
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            if (results.isEmpty)
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: PlantCareColors.border),
                ),
                child: const Text(
                  'No matching guidance found. Try a plant name, disease or symptom.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: PlantCareColors.muted),
                ),
              )
            else
              for (final entry in results) _KnowledgeCard(entry: entry),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pushNamed(
                  context,
                  AppRouter.support,
                ),
                icon: const Icon(Icons.support_agent_outlined),
                label: const Text('Community, experts & resources'),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNav(selectedIndex: 2),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const _CategoryCard({
    required this.icon,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 92,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: PlantCareColors.primary, size: 25),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _KnowledgeCard extends StatelessWidget {
  final PlantKnowledgeEntry entry;

  const _KnowledgeCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 12),
        childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        leading: const CircleAvatar(
          backgroundColor: PlantCareColors.softGreen,
          child: Icon(Icons.eco_outlined, color: PlantCareColors.primary),
        ),
        title: Text(
          entry.title,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: Text(entry.category),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(entry.summary),
          ),
          const SizedBox(height: 8),
          for (final tip in entry.careTips)
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('• ' + tip),
              ),
            ),
        ],
      ),
    );
  }
}
