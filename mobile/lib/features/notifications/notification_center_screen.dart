import 'package:flutter/material.dart';

import '../../core/app_services.dart';
import '../../core/models/notification_center_item.dart';
import '../../core/theme/app_theme.dart';
import '../../core/navigation/app_router.dart';

class NotificationCenterScreen extends StatefulWidget {
  const NotificationCenterScreen({super.key});
  @override
  State<NotificationCenterScreen> createState() =>
      _NotificationCenterScreenState();
}

class _NotificationCenterScreenState extends State<NotificationCenterScreen> {
  late Future<List<NotificationCenterItem>> _future;
  @override
  void initState() {
    super.initState();
    _future = AppServices.notificationCenter.getItems();
  }

  void _reload() =>
      setState(() => _future = AppServices.notificationCenter.getItems());

  Future<void> _confirmClearAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear notifications?'),
        content: const Text('This removes all notifications from your notification history.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear all'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await AppServices.notificationCenter.clearAll();
      if (!mounted) return;
      _reload();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notifications cleared.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Couldn’t clear notifications: $error')),
      );
    }
  }

  Future<void> _openNotification(NotificationCenterItem item) async {
    await AppServices.notificationCenter.markRead(item.id);
    if (!mounted) return;
    _reload();

    if (item.plantId == null) return;
    final plants = await AppServices.garden.getPlants();
    if (!mounted) return;
    for (final plant in plants) {
      if (plant.id == item.plantId) {
        Navigator.pushNamed(context, AppRouter.plant, arguments: plant.name);
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () async {
              await AppServices.notificationCenter.markAllRead();
              _reload();
            },
            child: const Text('Mark all read'),
          ),
          IconButton(
            tooltip: 'Clear notifications',
            onPressed: _confirmClearAll,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: FutureBuilder<List<NotificationCenterItem>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError)
            return const Center(
                child: Text('We could not load your notifications.'));
          final items = snapshot.data ?? const <NotificationCenterItem>[];
          if (items.isEmpty)
            return const Center(
                child: Padding(
                    padding: EdgeInsets.all(PlantCareSpacing.xl),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.notifications_none, size: 48),
                      SizedBox(height: 12),
                      Text('You are all caught up.',
                          style: TextStyle(fontWeight: FontWeight.w800)),
                      SizedBox(height: 4),
                      Text(
                          'PlantCare will show care reminders and alerts here.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: PlantCareColors.muted))
                    ])));
          return ListView.separated(
            padding: const EdgeInsets.all(PlantCareSpacing.lg),
            itemCount: items.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: PlantCareSpacing.sm),
            itemBuilder: (context, index) {
              final item = items[index];
              final icon = item.type == NotificationCenterType.watering
                  ? Icons.water_drop_outlined
                  : item.type == NotificationCenterType.diagnosis
                      ? Icons.health_and_safety_outlined
                      : Icons.eco_outlined;
              return Card(
                  child: ListTile(
                leading: Icon(icon,
                    color: item.read
                        ? PlantCareColors.muted
                        : PlantCareColors.primary),
                title: Text(item.title,
                    style: TextStyle(
                        fontWeight:
                            item.read ? FontWeight.w500 : FontWeight.w800)),
                subtitle: Text(item.body),
                trailing: item.read ? null : const Icon(Icons.circle, size: 9),
                onTap: () => _openNotification(item),
              ));
            },
          );
        },
      ),
    );
  }
}
