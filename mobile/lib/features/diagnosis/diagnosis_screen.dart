import 'package:flutter/material.dart';

import '../../core/navigation/app_router.dart';
import '../../core/services/diagnosis_service.dart';
import '../../core/services/plant_care_guidance_service.dart';
import '../../core/theme/app_theme.dart';

class DiagnosisScreen extends StatelessWidget {
  final DiagnosisResult result;

  const DiagnosisScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final percent = (result.confidence * 100).round();
    final lowConfidence = result.needsExpertReview || result.confidence < 0.70;
    final guidance =
        const PlantCareGuidanceService().forCondition(result.condition);

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
          _GuidanceSection(
            title: 'What this may mean',
            icon: Icons.info_outline,
            items: [guidance.summary],
          ),
          const SizedBox(height: PlantCareSpacing.md),
          _GuidanceSection(
            title: 'What to do now',
            icon: Icons.health_and_safety_outlined,
            items: guidance.actions,
          ),
          const SizedBox(height: PlantCareSpacing.md),
          _GuidanceSection(
            title: 'Prevention & monitoring',
            icon: Icons.shield_outlined,
            items: guidance.prevention,
          ),
          if (result.topPredictions.length > 1) ...[
            const SizedBox(height: PlantCareSpacing.md),
            _GuidanceSection(
              title: 'Other possibilities',
              icon: Icons.alt_route_outlined,
              items: [
                for (final prediction in result.topPredictions.skip(1).take(3))
                  '${prediction.className} — ${(prediction.confidence * 100).round()}%',
              ],
            ),
          ],
          const SizedBox(height: PlantCareSpacing.md),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(PlantCareSpacing.md),
              child: Text(
                'AI model: \${result.modelId} • \${result.modelVersion}',
                style: const TextStyle(
                  color: PlantCareColors.muted,
                  fontSize: 12,
                ),
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
          if (!lowConfidence) const SizedBox(height: PlantCareSpacing.sm),
          OutlinedButton.icon(
            onPressed: () => Navigator.pushNamed(
              context,
              AppRouter.assistant,
            ),
            icon: const Icon(Icons.auto_awesome),
            label: Text(
              lowConfidence
                  ? 'Ask an expert / PlantCare AI'
                  : 'Ask PlantCare AI',
            ),
          ),
        ],
      ),
    );
  }
}

class _GuidanceSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<String> items;

  const _GuidanceSection({
    required this.title,
    required this.icon,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(PlantCareSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: PlantCareColors.primary),
                const SizedBox(width: PlantCareSpacing.sm),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
            const SizedBox(height: PlantCareSpacing.sm),
            for (final item in items)
              Padding(
                padding: const EdgeInsets.only(bottom: PlantCareSpacing.sm),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Icon(
                        Icons.circle,
                        size: 6,
                        color: PlantCareColors.muted,
                      ),
                    ),
                    const SizedBox(width: PlantCareSpacing.sm),
                    Expanded(child: Text(item)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
