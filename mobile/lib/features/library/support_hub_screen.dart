import 'package:flutter/material.dart';
import '../../core/services/plant_care_support_service.dart';
import '../../core/theme/app_theme.dart';

class SupportHubScreen extends StatelessWidget {
  const SupportHubScreen({super.key});
  @override
  Widget build(BuildContext context) {
    const service = PlantCareSupportService();
    return Scaffold(
      appBar: AppBar(title: const Text('PlantCare Support', style: TextStyle(fontWeight: FontWeight.w800))),
      body: ListView(
        padding: const EdgeInsets.all(PlantCareSpacing.lg),
        children: [
          const Text('More ways to care', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          const Text('Community, experts, local support and trusted resources.', style: TextStyle(color: PlantCareColors.muted)),
          const SizedBox(height: PlantCareSpacing.lg),
          for (final item in service.items) ...[
            Card(child: ListTile(contentPadding: const EdgeInsets.all(PlantCareSpacing.md), leading: CircleAvatar(backgroundColor: PlantCareColors.surface, child: Icon(_iconFor(item.section), color: PlantCareColors.primary)), title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w800)), subtitle: Text(item.subtitle), trailing: const Icon(Icons.chevron_right), onTap: () => _showDetails(context, item))),
            const SizedBox(height: PlantCareSpacing.sm),
          ],
          const Card(child: Padding(padding: EdgeInsets.all(PlantCareSpacing.md), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(Icons.verified_outlined, color: PlantCareColors.primary), SizedBox(width: PlantCareSpacing.sm), Expanded(child: Text('PlantCare separates AI suggestions from expert or official guidance. A low-confidence model result should not be treated as a confirmed diagnosis.'))]))),
        ],
      ),
    );
  }
  static IconData _iconFor(SupportSection section) {
    switch (section) {
      case SupportSection.community: return Icons.groups_outlined;
      case SupportSection.experts: return Icons.support_agent_outlined;
      case SupportSection.shops: return Icons.storefront_outlined;
      case SupportSection.resources: return Icons.menu_book_outlined;
    }
  }
  static void _showDetails(BuildContext context, SupportItem item) {
    showModalBottomSheet<void>(context: context, showDragHandle: true, builder: (_) => Padding(padding: const EdgeInsets.all(PlantCareSpacing.lg), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Text(item.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)), const SizedBox(height: PlantCareSpacing.sm), Text(item.detail), const SizedBox(height: PlantCareSpacing.lg)])));
  }
}