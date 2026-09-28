import 'package:flutter/material.dart';

import '../../core/app_services.dart';
import '../../core/navigation/app_router.dart';
import '../../core/models/care_recommendation.dart';
import '../../core/models/diagnosis_record.dart';
import '../../core/models/plant.dart';
import '../../core/theme/app_theme.dart';

class PlantDetailScreen extends StatefulWidget {
  final String plantName;

  const PlantDetailScreen({super.key, required this.plantName});

  @override
  State<PlantDetailScreen> createState() => _PlantDetailScreenState();
}

class _PlantDetailScreenState extends State<PlantDetailScreen> {
  late Future<Plant?> _plantFuture;
  late Future<CareRecommendation?> _careFuture;

  @override
  void initState() {
    super.initState();
    _plantFuture = _findPlant();
    _careFuture = _loadCareRecommendation();
  }

  Future<CareRecommendation?> _loadCareRecommendation() async {
    final plant = await _findPlant();
    if (plant == null) return null;
    return AppServices.care.wateringRecommendation(plant);
  }

  Future<Plant?> _findPlant() async {
    final plants = await AppServices.garden.getPlants();
    for (final plant in plants) {
      if (plant.name == widget.plantName) return plant;
    }
    return null;
  }

  Future<void> _confirmDelete(Plant plant) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete plant?'),
        content: Text(
          'Remove ${plant.name} from your garden? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await AppServices.garden.deletePlant(plant.id);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${plant.name} removed from your garden.')),
    );
    Navigator.pushReplacementNamed(context, AppRouter.dashboard);
  }

  Future<void> _markWatered(Plant plant) async {
    final now = DateTime.now();
    final updated = plant.copyWith(
      lastWateredAt: now,
      nextWatering: now.add(Duration(days: plant.wateringIntervalDays)),
      health: plant.health == 'Not assessed' ? 'Healthy' : plant.health,
    );

    await AppServices.garden.updatePlant(updated);
    if (!mounted) return;

    setState(() {
      _plantFuture = Future.value(updated);
      _careFuture = AppServices.care.wateringRecommendation(updated);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${plant.name} marked as watered.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.plantName,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          FutureBuilder<Plant?>(
            future: _plantFuture,
            builder: (context, snapshot) {
              final plant = snapshot.data;
              if (plant == null) return const SizedBox.shrink();
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Edit plant',
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => Navigator.pushNamed(
                      context,
                      AppRouter.editPlant,
                      arguments: plant,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Delete plant',
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _confirmDelete(plant),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<Plant?>(
        future: _plantFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final plant = snapshot.data;
          if (plant == null) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'This plant could not be found in your garden.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(PlantCareSpacing.lg),
            children: [
              Container(
                height: 220,
                decoration: BoxDecoration(
                  color: PlantCareColors.surface,
                  borderRadius: BorderRadius.circular(PlantCareRadius.featured),
                ),
                child: Center(
                  child: Text(
                    plant.name.toLowerCase().contains('tomato') ? '🍅' : '🌿',
                    style: const TextStyle(fontSize: 86),
                  ),
                ),
              ),
              const SizedBox(height: PlantCareSpacing.lg),
              Row(
                children: [
                  _Metric(title: 'Health', value: plant.health),
                  _Metric(title: 'Sunlight', value: plant.sunlight),
                  _Metric(
                    title: 'Water',
                    value: _wateringLabel(plant.nextWatering),
                  ),
                ],
              ),
              const SizedBox(height: PlantCareSpacing.lg),
              Text(
                plant.species,
                style: const TextStyle(
                  color: PlantCareColors.muted,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                plant.location,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: PlantCareSpacing.lg),
              const Text(
                'Care plan',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: PlantCareSpacing.sm),
              Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.water_drop_outlined,
                    color: PlantCareColors.primary,
                  ),
                  title: Text(_wateringTitle(plant.nextWatering)),
                  subtitle: Text(
                    'Every ${plant.wateringIntervalDays} days • ${plant.soilType}',
                  ),
                  trailing: FilledButton(
                    onPressed: () => _markWatered(plant),
                    child: const Text('Watered'),
                  ),
                ),
              ),
              const SizedBox(height: PlantCareSpacing.sm),
              Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.wb_sunny_outlined,
                    color: PlantCareColors.primary,
                  ),
                  title: const Text('Sunlight'),
                  subtitle: Text(plant.sunlight),
                ),
              ),
              const SizedBox(height: PlantCareSpacing.lg),
              const Text(
                'Health timeline',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: PlantCareSpacing.sm),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.history),
                  title: const Text('Garden profile created'),
                  subtitle: Text(_formatDate(plant.createdAt)),
                ),
              ),
              if (plant.lastWateredAt != null) ...[
                const SizedBox(height: PlantCareSpacing.sm),
                Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.water_drop,
                      color: PlantCareColors.primary,
                    ),
                    title: const Text('Last watered'),
                    subtitle: Text(_formatDate(plant.lastWateredAt!)),
                  ),
                ),
              ],
              const SizedBox(height: PlantCareSpacing.md),
              FutureBuilder<CareRecommendation?>(
                future: _careFuture,
                builder: (context, careSnapshot) {
                  final recommendation = careSnapshot.data;
                  if (recommendation == null) return const SizedBox.shrink();

                  final isWater =
                      recommendation.action == CareRecommendationAction.water;
                  final isWait =
                      recommendation.action == CareRecommendationAction.wait;

                  final icon = isWater
                      ? Icons.water_drop_outlined
                      : isWait
                          ? Icons.check_circle_outline
                          : Icons.info_outline;

                  final iconColor = isWater
                      ? PlantCareColors.warning
                      : isWait
                          ? PlantCareColors.success
                          : PlantCareColors.primary;

                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(PlantCareSpacing.md),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(icon, color: iconColor),
                          const SizedBox(width: PlantCareSpacing.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  recommendation.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(recommendation.message),
                                const SizedBox(height: 6),
                                Text(
                                  'Why: ${recommendation.reason}',
                                  style: const TextStyle(
                                    color: PlantCareColors.muted,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: PlantCareSpacing.md),
              FutureBuilder<List<DiagnosisRecord>>(
                future: AppServices.diagnosis.history(plantId: plant.id),
                builder: (context, historySnapshot) {
                  if (historySnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Card(
                      child: Padding(
                        padding: EdgeInsets.all(PlantCareSpacing.md),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    );
                  }

                  if (historySnapshot.hasError) {
                    return const Card(
                      child: ListTile(
                        leading: Icon(Icons.info_outline),
                        title: Text('Diagnosis history unavailable'),
                        subtitle: Text(
                          'We could not load previous AI scan results.',
                        ),
                      ),
                    );
                  }

                  final history = historySnapshot.data ?? const [];
                  if (history.isEmpty) {
                    return const Card(
                      child: ListTile(
                        leading: Icon(Icons.health_and_safety_outlined),
                        title: Text('No AI diagnoses yet'),
                        subtitle: Text(
                          'Your future plant scans will appear here.',
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: [
                      for (final record in history) ...[
                        _DiagnosisTimelineCard(record: record),
                        if (record != history.last)
                          const SizedBox(height: PlantCareSpacing.sm),
                      ],
                    ],
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  String _wateringTitle(DateTime? next) {
    if (next == null) return 'Watering schedule not set';
    final today = DateTime.now();
    final date = DateTime(next.year, next.month, next.day);
    final current = DateTime(today.year, today.month, today.day);
    if (date == current) return 'Water today';
    if (date == current.add(const Duration(days: 1))) return 'Water tomorrow';
    return 'Next watering: ${_formatDate(next)}';
  }

  String _wateringLabel(DateTime? next) {
    if (next == null) return 'Not set';
    final today = DateTime.now();
    final date = DateTime(next.year, next.month, next.day);
    final current = DateTime(today.year, today.month, today.day);
    if (date == current) return 'Today';
    if (date == current.add(const Duration(days: 1))) return 'Tomorrow';
    return _formatDate(next);
  }

  String _formatDate(DateTime value) {
    final local = value.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/${local.year}';
  }
}

class _DiagnosisTimelineCard extends StatelessWidget {
  final DiagnosisRecord record;

  const _DiagnosisTimelineCard({required this.record});

  @override
  Widget build(BuildContext context) {
    final percent = (record.result.confidence * 100).round();
    final lowConfidence =
        record.result.needsExpertReview || record.result.confidence < 0.70;
    final alternatives = record.result.topPredictions.skip(1).take(2).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(PlantCareSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  lowConfidence
                      ? Icons.warning_amber_rounded
                      : Icons.biotech_outlined,
                  color: lowConfidence
                      ? PlantCareColors.warning
                      : PlantCareColors.primary,
                ),
                const SizedBox(width: PlantCareSpacing.sm),
                Expanded(
                  child: Text(
                    record.result.condition,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                Text(
                  '$percent%',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: lowConfidence
                        ? PlantCareColors.warning
                        : PlantCareColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              _formatDate(record.createdAt),
              style: const TextStyle(
                color: PlantCareColors.muted,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: PlantCareSpacing.sm),
            Text(
              record.result.explanation,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: PlantCareSpacing.sm),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _MetadataChip(
                  icon: Icons.auto_awesome_outlined,
                  label: record.result.capability,
                ),
                _MetadataChip(
                  icon: Icons.memory_outlined,
                  label: record.result.modelVersion,
                ),
                if (lowConfidence)
                  const _MetadataChip(
                    icon: Icons.support_agent_outlined,
                    label: 'Review recommended',
                  ),
              ],
            ),
            if (alternatives.isNotEmpty) ...[
              const SizedBox(height: PlantCareSpacing.sm),
              const Text(
                'Other possibilities',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              for (final alternative in alternatives)
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    '• ${alternative.className} — '
                    '${(alternative.confidence * 100).round()}%',
                    style: const TextStyle(
                      color: PlantCareColors.muted,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime value) {
    final local = value.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/${local.year}';
  }
}

class _MetadataChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetadataChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: PlantCareColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PlantCareColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: PlantCareColors.primary),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
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
      child: Padding(
        padding: const EdgeInsets.only(right: PlantCareSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: PlantCareColors.muted,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}
