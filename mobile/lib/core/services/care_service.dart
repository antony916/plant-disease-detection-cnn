import '../models/care_recommendation.dart';
import '../models/plant.dart';
import 'weather_service.dart';

abstract interface class CareService {
  Future<CareRecommendation> wateringRecommendation(Plant plant);
}

class RuleBasedCareService implements CareService {
  final WeatherService weatherService;

  const RuleBasedCareService(this.weatherService);

  @override
  Future<CareRecommendation> wateringRecommendation(Plant plant) async {
    final now = DateTime.now();
    final next = plant.nextWatering;
    final weather = await weatherService.getCurrentWeather(location: plant.location);

    if (next == null) {
      return CareRecommendation(
        action: CareRecommendationAction.monitor,
        title: 'Watering schedule not set',
        message: 'Add a watering interval so PlantCare can create a reminder.',
        reason: 'No watering date is stored for this plant.',
        evaluatedAt: now,
      );
    }

    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(next.year, next.month, next.day);

    if (weather != null &&
        weather.rainProbabilityPercent >= 70 &&
        weather.rainfallMm >= 1) {
      return CareRecommendation(
        action: CareRecommendationAction.wait,
        title: 'Rain may cover watering',
        message: 'Check the soil after the rain before watering this plant.',
        reason: 'The weather service reports a high chance of rain with measurable rainfall.',
        evaluatedAt: now,
      );
    }

    if (due.isBefore(today)) {
      return CareRecommendation(
        action: CareRecommendationAction.water,
        title: 'Watering may be overdue',
        message: 'Check the soil before watering and avoid overwatering.',
        reason: 'The saved watering date has passed.',
        evaluatedAt: now,
      );
    }

    if (due == today) {
      return CareRecommendation(
        action: CareRecommendationAction.water,
        title: 'Water today',
        message: 'Check the soil moisture, then water if the plant needs it.',
        reason: weather == null
            ? 'The saved watering schedule is due today.'
            : 'The saved watering schedule is due today and no rain adjustment was triggered.',
        evaluatedAt: now,
      );
    }

    return CareRecommendation(
      action: CareRecommendationAction.wait,
      title: 'No watering needed yet',
      message: 'Keep the current schedule and check the plant if conditions change.',
      reason: 'The next saved watering date is still in the future.',
      evaluatedAt: now,
    );
  }
}
