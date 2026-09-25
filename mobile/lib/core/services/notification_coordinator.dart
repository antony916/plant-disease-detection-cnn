import '../models/garden_task.dart';
import '../models/notification_center_item.dart';
import '../models/plant.dart';
import 'notification_center_service.dart';

class NotificationCoordinator {
  final NotificationCenterService center;
  NotificationCoordinator(this.center);

  Future<void> syncGardenTasks({
    required List<Plant> plants,
    required List<GardenTask> tasks,
    DateTime? now,
  }) async {
    final current = now ?? DateTime.now();
    final preferences = await center.getPreferences();
    if (!preferences.wateringReminders || preferences.isQuietHour(current)) return;

    for (final task in tasks) {
      if (task.type != GardenTaskType.watering || task.completed) continue;
      final plant = _plantForTask(plants, task.plantId);
      if (plant == null) continue;
      final dateKey = task.dueAt.year.toString() + '-' + task.dueAt.month.toString() + '-' + task.dueAt.day.toString();
      await center.add(NotificationCenterItem(
        id: 'watering-' + plant.id + '-' + dateKey,
        type: NotificationCenterType.watering,
        title: 'Water ' + plant.name,
        body: 'Your ' + plant.name + ' is due for watering. Check the soil first.',
        createdAt: current,
        plantId: plant.id,
      ));
    }
  }

  Plant? _plantForTask(List<Plant> plants, String plantId) {
    for (final plant in plants) {
      if (plant.id == plantId) return plant;
    }
    return null;
  }
}