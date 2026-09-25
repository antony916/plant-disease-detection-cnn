enum NotificationCenterType { watering, care, diagnosis, system }

class NotificationCenterItem {
  final String id;
  final NotificationCenterType type;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool read;
  final String? plantId;

  const NotificationCenterItem({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    this.read = false,
    this.plantId,
  });

  NotificationCenterItem copyWith({bool? read}) {
    return NotificationCenterItem(
      id: id,
      type: type,
      title: title,
      body: body,
      createdAt: createdAt,
      read: read ?? this.read,
      plantId: plantId,
    );
  }
}
