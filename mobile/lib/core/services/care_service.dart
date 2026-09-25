import '../models/care_recommendation.dart';
import '../models/plant.dart';

abstract interface class CareService {
  Future<CareRecommendation> wateringRecommendation(Plant plant);
}

class RuleBasedCareService implements CareService {
  @override
  Future<CareRecommendation> wateringRecommendation(Plant plant) async {
    final now = DateTime.now();
    final next = plant.nextWatering;

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
        reason: 'The saved watering schedule is due today.',
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
