enum NotificationType { watering, diagnosis, care }

class CareNotification {
  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final DateTime scheduledAt;
  final String? plantId;

  const CareNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.scheduledAt,
    this.plantId,
  });
}
