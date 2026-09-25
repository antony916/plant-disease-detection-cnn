import 'package:flutter/material.dart';

import '../../core/navigation/app_router.dart';
import '../../core/theme/app_theme.dart';

class DiagnosisScreen extends StatelessWidget {
  final String plantName;

  const DiagnosisScreen({super.key, required this.plantName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Diagnosis', style: TextStyle(fontWeight: FontWeight.w800))),
      body: ListView(
        padding: const EdgeInsets.all(PlantCareSpacing.lg),
        children: [
          Container(
            height: 210,
            decoration: BoxDecoration(color: PlantCareColors.surface, borderRadius: BorderRadius.circular(PlantCareRadius.featured)),
            child: const Center(child: Icon(Icons.local_florist, size: 72, color: PlantCareColors.primary)),
          ),
          const SizedBox(height: PlantCareSpacing.lg),
          const Row(
            children: [
              Expanded(child: Text('Possible condition', style: TextStyle(color: PlantCareColors.muted))),
              Text('94%', style: TextStyle(fontWeight: FontWeight.w800, color: PlantCareColors.primary)),
            ],
          ),
          const SizedBox(height: 6),
          const Text('Early blight', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
          const SizedBox(height: PlantCareSpacing.md),
          const LinearProgressIndicator(value: 0.94, minHeight: 8),
          const SizedBox(height: PlantCareSpacing.lg),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(PlantCareSpacing.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, color: PlantCareColors.primary),
                  const SizedBox(width: PlantCareSpacing.sm),
                  Expanded(child: Text('This screen is ready for the production model response. Low-confidence results should ask for another image or route the gardener to expert help.', style: Theme.of(context).textTheme.bodyMedium)),
                ],
              ),
            ),
          ),
          const SizedBox(height: PlantCareSpacing.lg),
          FilledButton(onPressed: () => Navigator.pushNamed(context, AppRouter.plant, arguments: plantName), child: const Text('View plant care')),
          const SizedBox(height: PlantCareSpacing.sm),
          OutlinedButton.icon(onPressed: () => Navigator.pushNamed(context, AppRouter.assistant), icon: const Icon(Icons.auto_awesome), label: const Text('Ask PlantCare AI')),
        ],
      ),
    );
  }
}
