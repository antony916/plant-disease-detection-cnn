import 'package:flutter/material.dart';
import '../../core/app_services.dart';
import '../../core/models/notification_center_item.dart';
import '../../core/navigation/app_router.dart';
import '../../core/theme/app_theme.dart';

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
    _reload();
  }

  void _reload() {
    _future = AppServices.notificationCenter.getItems();
  }

  Future<void> _markAll() async {
    await AppServices.notificationCenter.markAllRead();
    if (mounted) setState(_reload);
  }

  Future<void> _clear() async {
    final ok = await showDialog<bool>(
        context: context,
        builder: (d) => AlertDialog(
                title: const Text('Clear notifications?'),
                content: const Text(
                    'This removes all notifications from your history.'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(d, false),
                      child: const Text('Cancel')),
                  FilledButton(
                      onPressed: () => Navigator.pop(d, true),
                      child: const Text('Clear all'))
                ]));
    if (ok != true) return;
    try {
      await AppServices.notificationCenter.clearAll();
      if (mounted) {
        setState(_reload);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Notifications cleared.')));
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Couldn’t clear notifications: $e')));
    }
  }

  Future<void> _open(NotificationCenterItem item) async {
    await AppServices.notificationCenter.markRead(item.id);
    if (!mounted) return;
    setState(_reload);
    if (item.plantId == null) return;
    final plants = await AppServices.garden.getPlants();
    if (!mounted) return;
    for (final p in plants) {
      if (p.id == item.plantId) {
        Navigator.pushNamed(context, AppRouter.plant, arguments: p.name);
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Notifications',
              style: TextStyle(fontWeight: FontWeight.w900)),
          actions: [
            IconButton(
                tooltip: 'Mark all as read',
                onPressed: _markAll,
                icon: const Icon(Icons.done_all_rounded)),
            IconButton(
                tooltip: 'Clear notifications',
                onPressed: _clear,
                icon: const Icon(Icons.delete_outline)),
          ]),
      body: FutureBuilder<List<NotificationCenterItem>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError)
            return Center(
                child: _State(
                    icon: Icons.cloud_off_outlined,
                    title: 'Couldn’t load notifications',
                    message: 'Check your connection and try again.',
                    action: TextButton.icon(
                        onPressed: () => setState(_reload),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'))));
          final items = snapshot.data ?? const <NotificationCenterItem>[];
          if (items.isEmpty)
            return const Center(
                child: _State(
                    icon: Icons.notifications_none_rounded,
                    title: 'You are all caught up',
                    message:
                        'PlantCare will show care reminders and alerts here.'));
          return ListView.separated(
            padding: const EdgeInsets.all(PlantCareSpacing.lg),
            itemCount: items.length,
            separatorBuilder: (_, i) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final item = items[i];
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
                              fontWeight: item.read
                                  ? FontWeight.w500
                                  : FontWeight.w800)),
                      subtitle: Text(item.body),
                      trailing:
                          item.read ? null : const Icon(Icons.circle, size: 9),
                      onTap: () => _open(item)));
            },
          );
        },
      ),
    );
  }
}

class _State extends StatelessWidget {
  final IconData icon;
  final String title, message;
  final Widget? action;
  const _State(
      {required this.icon,
      required this.title,
      required this.message,
      this.action});
  @override
  Widget build(BuildContext c) => Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 52, color: PlantCareColors.muted),
        const SizedBox(height: 16),
        Text(title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        Text(message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: PlantCareColors.muted)),
        if (action != null)
          Padding(padding: const EdgeInsets.only(top: 16), child: action!)
      ]));
}
