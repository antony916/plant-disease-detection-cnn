import '../models/care_notification.dart';

class PlantCareNotification {
  final String title;
  final String body;
  final DateTime scheduledAt;
  final String? plantId;

  const PlantCareNotification({
    required this.title,
    required this.body,
    required this.scheduledAt,
    this.plantId,
  });
}

abstract interface class NotificationService {
  Future<void> initialize();
  Future<void> registerDeviceToken(String token);
  Future<void> schedule(PlantCareNotification notification);
  Future<void> cancel(String notificationId);
}

class NotificationScheduler {
  final NotificationService service;
  final Set<String> _scheduledIds = <String>{};

  NotificationScheduler(this.service);

  Future<void> scheduleWatering({
    required String plantId,
    required String plantName,
    required DateTime when,
  }) async {
    final id = 'watering-' + plantId + '-' + when.millisecondsSinceEpoch.toString();
    if (_scheduledIds.contains(id)) return;

    await service.schedule(
      PlantCareNotification(
        title: 'PlantCare watering reminder',
        body: 'Check ' + plantName + ' and water it if the soil needs it.',
        scheduledAt: when,
        plantId: plantId,
      ),
    );
    _scheduledIds.add(id);
  }

  Future<void> cancel(String notificationId) async {
    await service.cancel(notificationId);
    _scheduledIds.remove(notificationId);
  }
}