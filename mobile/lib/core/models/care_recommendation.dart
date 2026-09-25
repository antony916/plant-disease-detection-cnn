enum CareRecommendationAction {
  water,
  wait,
  monitor,
}

class CareRecommendation {
  final CareRecommendationAction action;
  final String title;
  final String message;
  final String reason;
  final DateTime evaluatedAt;

  const CareRecommendation({
    required this.action,
    required this.title,
    required this.message,
    required this.reason,
    required this.evaluatedAt,
  });
}
