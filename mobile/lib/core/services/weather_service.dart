import '../models/weather_snapshot.dart';

abstract interface class WeatherService {
  Future<WeatherSnapshot?> getCurrentWeather({String? location});
}

/// Development-only weather source. It deliberately returns no live weather data.
class DemoWeatherService implements WeatherService {
  @override
  Future<WeatherSnapshot?> getCurrentWeather({String? location}) async => null;
}
