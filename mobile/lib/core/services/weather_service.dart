import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/weather_snapshot.dart';
import 'location_service.dart';
import 'weather_service.dart';

class OpenMeteoWeatherService implements WeatherService {
  final LocationService locationService;
  final http.Client client;

  OpenMeteoWeatherService({
    required this.locationService,
    http.Client? client,
  }) : client = client ?? http.Client();

  @override
  Future<WeatherSnapshot?> getCurrentWeather({String? location}) async {
    final selected = await locationService.getSelectedLocation();
    if (selected == null) return null;

    final uri = Uri.https(
      'api.open-meteo.com',
      '/v1/forecast',
      {
        'latitude': selected.latitude.toString(),
        'longitude': selected.longitude.toString(),
        'current':
            'temperature_2m,relative_humidity_2m,precipitation,rain',
        'hourly': 'precipitation_probability',
        'forecast_days': '1',
        'timezone': 'auto',
      },
    );

    try {
      final response = await client.get(uri);
      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final current = data['current'] as Map<String, dynamic>?;
      final hourly = data['hourly'] as Map<String, dynamic>?;

      if (current == null) return null;

      final probabilities =
          (hourly?['precipitation_probability'] as List<dynamic>?)
              ?.whereType<num>()
              .map((value) => value.toDouble())
              .toList() ??
          const <double>[];

      final rainProbability = probabilities.isEmpty
          ? 0
          : probabilities.reduce((a, b) => a > b ? a : b);

      return WeatherSnapshot(
        locationLabel: selected.label,
        temperatureC:
            (current['temperature_2m'] as num?)?.toDouble() ?? 0,
        humidityPercent:
            (current['relative_humidity_2m'] as num?)?.toDouble() ?? 0,
        rainProbabilityPercent: rainProbability,
        rainfallMm: (current['rain'] as num?)?.toDouble() ??
            (current['precipitation'] as num?)?.toDouble() ??
            0,
        observedAt: DateTime.tryParse(
              current['time'] as String? ?? '',
            ) ??
            DateTime.now(),
        isForecast: false,
      );
    } catch (_) {
      return null;
    }
  }
}
