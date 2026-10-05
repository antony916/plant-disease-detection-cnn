import 'dart:io';

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
          'Diagnosis result',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            tooltip: 'Scan another photo',
            onPressed: () => Navigator.pushReplacementNamed(
              context,
              AppRouter.scanner,
            ),
            icon: const Icon(Icons.camera_alt_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: lowConfidence
                  ? PlantCareColors.warm
                  : PlantCareColors.softGreen,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    lowConfidence
                        ? Icons.warning_amber_rounded
                        : Icons.eco_rounded,
                    color: lowConfidence
                        ? PlantCareColors.warning
                        : PlantCareColors.primary,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'AI RESULT',
                        style: TextStyle(
                          color: PlantCareColors.muted,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: .8,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        result.condition,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  percent.toString() + '%',
                  style: TextStyle(
                    color: lowConfidence
                        ? PlantCareColors.warning
                        : PlantCareColors.primary,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Scanned plant: ' + result.plantName,
            style: const TextStyle(
              color: PlantCareColors.muted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: result.confidence.clamp(0, 1),
              minHeight: 8,
              backgroundColor: PlantCareColors.border,
              color: lowConfidence
                  ? PlantCareColors.warning
                  : PlantCareColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          if (lowConfidence)
            _NoticeCard(
              color: PlantCareColors.warm,
              icon: Icons.warning_amber_rounded,
              title: 'Review recommended',
              message:
                  'PlantCare is not confident enough to rely on this result. Try another clear image or ask an agricultural expert.',
            )
          else
            _NoticeCard(
              color: PlantCareColors.softGreen,
              icon: Icons.check_circle_outline,
              title: 'Confidence is high',
              message: result.explanation,
            ),
          const SizedBox(height: 16),
          const _SectionLabel('What to do now'),
          const SizedBox(height: 8),
          _GuidanceCard(
            icon: Icons.health_and_safety_outlined,
            items: guidance.actions,
          ),
          const SizedBox(height: 12),
          const _SectionLabel('What this may mean'),
          const SizedBox(height: 8),
          _GuidanceCard(
            icon: Icons.info_outline,
            items: [guidance.summary],
          ),
          const SizedBox(height: 12),
          const _SectionLabel('Prevention & monitoring'),
          const SizedBox(height: 8),
          _GuidanceCard(
            icon: Icons.shield_outlined,
            items: guidance.prevention,
          ),
          if (result.topPredictions.length > 1) ...[
            const SizedBox(height: 12),
            const _SectionLabel('Other possibilities'),
            const SizedBox(height: 8),
            _AlternativesCard(
              predictions: result.topPredictions.skip(1).take(3).toList(),
            ),
          ],
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: PlantCareColors.border),
            ),
            child: Text(
              'AI model: ' + result.modelId + ' • ' + result.modelVersion,
              style: const TextStyle(
                color: PlantCareColors.muted,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (!lowConfidence)
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pushNamed(
                  context,
                  AppRouter.plant,
                  arguments: result.plantName,
                ),
                child: const Text('View plant care'),
              ),
            ),
          if (!lowConfidence) const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.pushReplacementNamed(
                context,
                AppRouter.scanner,
              ),
              icon: const Icon(Icons.camera_alt_outlined),
              label: const Text('Scan another photo'),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
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
          ),
        ],
      ),
    );
  }
}

class _NoticeCard extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final String message;

  const _NoticeCard({
    required this.color,
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: PlantCareColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(message),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _GuidanceCard extends StatelessWidget {
  final IconData icon;
  final List<String> items;

  const _GuidanceCard({
    required this.icon,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: PlantCareColors.border),
      ),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const Divider(height: 18, color: PlantCareColors.border),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 20, color: PlantCareColors.primary),
                const SizedBox(width: 10),
                Expanded(child: Text(items[i])),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _AlternativesCard extends StatelessWidget {
  final List<DiagnosisPrediction> predictions;

  const _AlternativesCard({required this.predictions});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: PlantCareColors.border),
      ),
      child: Column(
        children: [
          for (final prediction in predictions)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: PlantCareColors.muted,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      prediction.className,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  Text(
                    (prediction.confidence * 100).round().toString() + '%',
                    style: const TextStyle(
                      color: PlantCareColors.muted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
