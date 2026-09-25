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
