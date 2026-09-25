import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class PlantDetailScreen extends StatelessWidget {
  final String plantName;

  const PlantDetailScreen({super.key, required this.plantName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(plantName, style: const TextStyle(fontWeight: FontWeight.w800))),
      body: ListView(
        padding: const EdgeInsets.all(PlantCareSpacing.lg),
        children: [
          Container(
            height: 220,
            decoration: BoxDecoration(
              color: PlantCareColors.surface,
              borderRadius: BorderRadius.circular(PlantCareRadius.featured),
            ),
            child: Center(child: Text(plantName == 'Tomato' ? '🍅' : '🌿', style: const TextStyle(fontSize: 86))),
          ),
          const SizedBox(height: PlantCareSpacing.lg),
          const Row(
            children: [
              _Metric(title: 'Health', value: 'Good'),
              _Metric(title: 'Sunlight', value: '6h'),
              _Metric(title: 'Water', value: 'Today'),
            ],
          ),
          const SizedBox(height: PlantCareSpacing.lg),
          const Text('Care plan', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800)),
          const SizedBox(height: PlantCareSpacing.sm),
          const Card(child: ListTile(leading: Icon(Icons.water_drop_outlined), title: Text('Water today'), subtitle: Text('Adjust after checking soil and local weather.'))),
          const SizedBox(height: PlantCareSpacing.sm),
          const Card(child: ListTile(leading: Icon(Icons.wb_sunny_outlined), title: Text('Sunlight'), subtitle: Text('Keep in a bright location suitable for the plant.'))),
          const SizedBox(height: PlantCareSpacing.lg),
          const Text('Health timeline', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800)),
          const SizedBox(height: PlantCareSpacing.sm),
          const Card(child: ListTile(leading: Icon(Icons.history), title: Text('No diagnosis history yet'), subtitle: Text('Future scans will appear here.'))),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String title;
  final String value;

  const _Metric({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: PlantCareColors.muted, fontSize: 12)),
          const SizedBox(height: 3),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
