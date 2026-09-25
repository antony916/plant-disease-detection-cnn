import 'package:flutter/material.dart';

import '../../core/navigation/app_router.dart';
import '../../core/services/diagnosis_service.dart';
import '../../core/theme/app_theme.dart';

class DiagnosisScreen extends StatelessWidget {
  final DiagnosisResult result;

  const DiagnosisScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final percent = (result.confidence * 100).round();
    final lowConfidence = result.needsExpertReview || result.confidence < 0.70;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Diagnosis',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(PlantCareSpacing.lg),
        children: [
          Container(
            height: 210,
            decoration: BoxDecoration(
              color: PlantCareColors.surface,
              borderRadius: BorderRadius.circular(
                PlantCareRadius.featured,
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.local_florist,
                size: 72,
                color: PlantCareColors.primary,
              ),
            ),
          ),
          const SizedBox(height: PlantCareSpacing.lg),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Possible condition',
                  style: TextStyle(color: PlantCareColors.muted),
                ),
              ),
              Text(
                '$percent%',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: PlantCareColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            result.condition,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: PlantCareSpacing.md),
          LinearProgressIndicator(
            value: result.confidence.clamp(0, 1),
            minHeight: 8,
          ),
          const SizedBox(height: PlantCareSpacing.lg),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(PlantCareSpacing.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    lowConfidence
                        ? Icons.warning_amber_rounded
                        : Icons.info_outline,
                    color: lowConfidence
                        ? PlantCareColors.warning
                        : PlantCareColors.primary,
                  ),
                  const SizedBox(width: PlantCareSpacing.sm),
                  Expanded(
                    child: Text(
                      lowConfidence
                          ? 'PlantCare is not confident enough to rely on this result. Try another clear image or ask an agricultural expert.'
                          : result.explanation,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: PlantCareSpacing.lg),
          if (!lowConfidence)
            FilledButton(
              onPressed: () => Navigator.pushNamed(
                context,
                AppRouter.plant,
                arguments: result.plantName,
              ),
              child: const Text('View plant care'),
            ),
          if (!lowConfidence)
            const SizedBox(height: PlantCareSpacing.sm),
          OutlinedButton.icon(
            onPressed: () => Navigator.pushNamed(
              context,
              AppRouter.assistant,
            ),
            icon: const Icon(Icons.auto_awesome),
            label: Text(
              lowConfidence ? 'Ask an expert / PlantCare AI' : 'Ask PlantCare AI',
            ),
          ),
        ],
      ),
    );
  }
}
