import 'package:flutter_test/flutter_test.dart';
import 'package:plantcare_ai/core/models/plant.dart';
import 'package:plantcare_ai/core/services/care_service.dart';
import 'package:plantcare_ai/core/services/plant_assistant_service.dart';
import 'package:plantcare_ai/core/models/weather_snapshot.dart';
import 'package:plantcare_ai/core/services/weather_service.dart';

class _WeatherStub implements WeatherService {
  @override
  Future<WeatherSnapshot?> getCurrentWeather(
          {required String location}) async =>
      null;
}

void main() {
  final now = DateTime(2026, 9, 28);
  final plants = [
    Plant(
        id: 'p1',
        name: 'Tomato',
        species: 'Tomato',
        health: 'Healthy',
        wateringIntervalDays: 2,
        sunlight: 'Full sun',
        location: 'Terrace',
        soilType: 'Loamy potting mix',
        nextWatering: now,
        createdAt: now)
  ];

  test('assistant uses saved plant context for watering questions', () async {
    final service = PlantAssistantService(RuleBasedCareService(_WeatherStub()));
    final reply = await service.answer(
        question: 'What should I water today?', plants: plants);
    expect(reply.message, contains('Tomato'));
    expect(reply.message, contains('Water today'));
  });

  test('assistant gives safe symptom guidance', () async {
    final service = PlantAssistantService(RuleBasedCareService(_WeatherStub()));
    final reply = await service.answer(
        question: 'Why are my leaves yellow?', plants: plants);
    expect(reply.message, contains('several causes'));
    expect(reply.message, contains('clear photo'));
  });
}
