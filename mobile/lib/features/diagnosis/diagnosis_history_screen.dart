import 'package:flutter/material.dart';

import '../../core/app_services.dart';
import '../../core/models/diagnosis_record.dart';
import '../../core/theme/app_theme.dart';
import '../../core/ui/empty_state.dart';
import '../../core/navigation/app_router.dart';

class DiagnosisHistoryScreen extends StatefulWidget {
  const DiagnosisHistoryScreen({super.key});

  @override
  State<DiagnosisHistoryScreen> createState() => _DiagnosisHistoryScreenState();
}

class _DiagnosisHistoryScreenState extends State<DiagnosisHistoryScreen> {
  late Future<List<DiagnosisRecord>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _historyFuture = AppServices.diagnosis.history();
  }

  Future<void> _confirmClearHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear diagnosis history?'),
        content: const Text(
          'This permanently removes your saved diagnosis history. '
          'Your plants will not be deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear history'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await AppServices.diagnosis.clearHistory();
      if (!mounted) return;
      setState(_load);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Diagnosis history cleared.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Couldn’t clear history: $error')),
      );
    }
  }

  Future<void> _refresh() async {
    setState(_load);
    await _historyFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Health Timeline',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: 'Clear diagnosis history',
            onPressed: _confirmClearHistory,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: FutureBuilder<List<DiagnosisRecord>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _StateMessage(
              icon: Icons.cloud_off_outlined,
              title: 'Couldn’t load your history',
              message: 'Check your connection and try again.',
              action: FilledButton.icon(
                onPressed: () => setState(_load),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            );
          }

          final records = snapshot.data ?? const <DiagnosisRecord>[];
          if (records.isEmpty) {
            return EmptyState(
              icon: Icons.health_and_safety_outlined,
              title: 'No diagnoses yet',
              helperText:
                  'Your plant scans will appear here as a health timeline.',
              actionLabel: 'Scan a plant',
              onAction: () =>
                  Navigator.pushReplacementNamed(context, AppRouter.scanner),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              padding: const EdgeInsets.all(PlantCareSpacing.lg),
              itemCount: records.length,
              itemBuilder: (context, index) {
                final record = records[index];
                final confidence =
                    (record.result.confidence * 100).toStringAsFixed(1);
                final date = _formatDate(record.createdAt);

                return Card(
                  margin: const EdgeInsets.only(bottom: PlantCareSpacing.sm),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(PlantCareSpacing.sm),
                    leading: CircleAvatar(
                      backgroundColor: PlantCareColors.surface,
                      child: Icon(
                        record.result.needsExpertReview
                            ? Icons.warning_amber_outlined
                            : Icons.eco_outlined,
                        color: record.result.needsExpertReview
                            ? Colors.orange
                            : PlantCareColors.primary,
                      ),
                    ),
                    title: Text(
                      record.result.condition,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: Text(
                      record.result.plantName +
                          ' • ' +
                          confidence +
                          '% confidence\n' +
                          date,
                    ),
                    isThreeLine: true,
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRouter.diagnosis,
                      arguments: record.result,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime value) {
    final local = value.toLocal();
    final hour = local.hour == 0
        ? 12
        : local.hour > 12
            ? local.hour - 12
            : local.hour;
    final minute = local.minute.toString().padLeft(2, '0');
    final suffix = local.hour >= 12 ? 'PM' : 'AM';
    return local.day.toString() +
        '/' +
        local.month.toString() +
        '/' +
        local.year.toString() +
        ' • ' +
        hour.toString() +
        ':' +
        minute +
        ' ' +
        suffix;
  }
}

class _StateMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Widget action;

  const _StateMessage({
    required this.icon,
    required this.title,
    required this.message,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(PlantCareSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 52, color: PlantCareColors.muted),
            const SizedBox(height: PlantCareSpacing.md),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: PlantCareSpacing.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: PlantCareColors.muted),
            ),
            const SizedBox(height: PlantCareSpacing.lg),
            action,
          ],
        ),
      ),
    );
  }
}
