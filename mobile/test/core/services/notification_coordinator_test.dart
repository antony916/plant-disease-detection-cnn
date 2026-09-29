import 'package:flutter_test/flutter_test.dart';

import 'package:plantcare_ai/core/models/care_recommendation.dart';
import 'package:plantcare_ai/core/models/garden_task.dart';
import 'package:plantcare_ai/core/models/notification_center_item.dart';
import 'package:plantcare_ai/core/models/notification_preferences.dart';
import 'package:plantcare_ai/core/models/plant.dart';
import 'package:plantcare_ai/core/services/care_service.dart';
import 'package:plantcare_ai/core/services/notification_center_service.dart';
import 'package:plantcare_ai/core/services/notification_coordinator.dart';

class _FakeCenter implements NotificationCenterService {
  final List<NotificationCenterItem> items = [];
  NotificationPreferences preferences = const NotificationPreferences(
    quietHoursEnabled: false,
  );

  @override
  Future<List<NotificationCenterItem>> getItems() async => items;

  @override
  Future<void> add(NotificationCenterItem item) async {
    items.removeWhere((existing) => existing.id == item.id);
    items.insert(0, item);
  }

  @override
  Future<void> markRead(String id) async {}

  @override
  Future<void> markAllRead() async {}

  @override
  Future<void> clearAll() async {
    items.clear();
  }

  @override
  Future<NotificationPreferences> getPreferences() async => preferences;

  @override
  Future<void> savePreferences(NotificationPreferences preferences) async {
    this.preferences = preferences;
  }
}

class _FakeCareService implements CareService {
  final CareRecommendation recommendation;

  _FakeCareService(this.recommendation);

  @override
  Future<CareRecommendation> wateringRecommendation(Plant plant) async =>
      recommendation;
}

Plant _plant() => Plant(
      id: 'tomato-1',
      name: 'Tomato',
      species: 'Solanum lycopersicum',
      health: 'Healthy',
      nextWatering: DateTime(2026, 9, 28, 10),
      wateringIntervalDays: 2,
      createdAt: DateTime(2026, 9, 1),
    );

GardenTask _task() => GardenTask(
      id: 'task-1',
      plantId: 'tomato-1',
      type: GardenTaskType.watering,
      title: 'Water Tomato',
      subtitle: 'Balcony',
      dueAt: DateTime(2026, 9, 28, 10),
    );

void main() {
  test('uses smart-care recommendation in watering notification', () async {
    final center = _FakeCenter();
    final coordinator = NotificationCoordinator(
      center,
      _FakeCareService(
        CareRecommendation(
          action: CareRecommendationAction.wait,
          title: 'Rain may cover watering',
          message: 'Check the soil after the rain before watering this plant.',
          reason: 'Near-term rain is likely.',
          evaluatedAt: DateTime(2026, 9, 28, 9),
        ),
      ),
    );

    await coordinator.syncGardenTasks(
      plants: [_plant()],
      tasks: [_task()],
      now: DateTime(2026, 9, 28, 9),
    );

    expect(center.items, hasLength(1));
    expect(center.items.single.id, 'watering-tomato-1-2026-9-28');
    expect(center.items.single.title, 'Hold watering: Tomato');
    expect(
      center.items.single.body,
      'Check the soil after the rain before watering this plant.',
    );
  });

  test('does not create notifications during quiet hours', () async {
    final center = _FakeCenter();
    center.preferences = const NotificationPreferences(
      quietHoursEnabled: true,
      quietStartHour: 22,
      quietEndHour: 7,
    );
    final coordinator = NotificationCoordinator(
      center,
      _FakeCareService(
        CareRecommendation(
          action: CareRecommendationAction.water,
          title: 'Water today',
          message: 'Check soil moisture before watering.',
          reason: 'Watering is due.',
          evaluatedAt: DateTime(2026, 9, 28, 23),
        ),
      ),
    );

    await coordinator.syncGardenTasks(
      plants: [_plant()],
      tasks: [_task()],
      now: DateTime(2026, 9, 28, 23),
    );

    expect(center.items, isEmpty);
  });
}
