import 'package:flutter_test/flutter_test.dart';

import 'package:plantcare_ai/core/services/notification_service.dart';

class FakeNotificationService implements NotificationService {
  final List<PlantCareNotification> scheduled = <PlantCareNotification>[];
  final List<String> cancelled = <String>[];

  @override
  Future<void> initialize() async {}
  @override
  Future<void> registerDeviceToken(String token) async {}
  @override
  Future<void> schedule(PlantCareNotification notification) async {
    scheduled.add(notification);
  }

  @override
  Future<void> cancel(String notificationId) async {
    cancelled.add(notificationId);
  }
}

void main() {
  test('watering reminder uses a deterministic ID', () async {
    final service = FakeNotificationService();
    final scheduler = NotificationScheduler(service);
    final when = DateTime(2026, 9, 28, 8);
    await scheduler.scheduleWatering(
        plantId: 'plant-1', plantName: 'Tomato', when: when);
    expect(service.scheduled, hasLength(1));
    expect(service.scheduled.single.id,
        'watering-plant-1-\${when.millisecondsSinceEpoch}');
    expect(service.scheduled.single.plantId, 'plant-1');
  });

  test('repeating the same watering reminder is idempotent in one app session',
      () async {
    final service = FakeNotificationService();
    final scheduler = NotificationScheduler(service);
    final when = DateTime(2026, 9, 28, 8);
    await scheduler.scheduleWatering(
        plantId: 'plant-1', plantName: 'Tomato', when: when);
    await scheduler.scheduleWatering(
        plantId: 'plant-1', plantName: 'Tomato', when: when);
    expect(service.scheduled, hasLength(1));
  });

  test('cancel removes the reminder from the scheduler cache', () async {
    final service = FakeNotificationService();
    final scheduler = NotificationScheduler(service);
    final when = DateTime(2026, 9, 28, 8);
    await scheduler.scheduleWatering(
        plantId: 'plant-1', plantName: 'Tomato', when: when);
    final id = service.scheduled.single.id;
    await scheduler.cancel(id);
    await scheduler.scheduleWatering(
        plantId: 'plant-1', plantName: 'Tomato', when: when);
    expect(service.cancelled, [id]);
    expect(service.scheduled, hasLength(2));
  });
}
