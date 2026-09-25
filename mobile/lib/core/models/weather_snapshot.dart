class WeatherSnapshot {
  final String locationLabel;
  final double temperatureC;
  final double humidityPercent;
  final double rainProbabilityPercent;
  final double rainfallMm;
  final DateTime observedAt;
  final bool isForecast;

  const WeatherSnapshot({
    required this.locationLabel,
    required this.temperatureC,
    required this.humidityPercent,
    required this.rainProbabilityPercent,
    required this.rainfallMm,
    required this.observedAt,
    required this.isForecast,
  });
}
