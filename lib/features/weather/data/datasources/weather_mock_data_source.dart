// lib/features/weather/data/datasources/weather_mock_data_source.dart
import '../models/weather_model.dart';
import '../models/forecast_model.dart';

class WeatherMockDataSource {
  static Future<WeatherModel> getMockCurrentWeather() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    return WeatherModel(
      cityName: 'Nairobi',
      country: 'KE',
      temperature: 22.5,
      description: 'partly cloudy',
      mainWeather: 'Clouds',
      feelsLike: 24.0,
      humidity: 65,
      windSpeed: 3.2,
      pressure: 1013,
      dateTime: DateTime.now(),
      icon: '02d',
      latitude: null,
      longitude: null,
    );
  }

  static Future<ForecastModel> getMockForecast() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    final List<WeatherModel> forecasts = [];
    final now = DateTime.now();

    // Generate 5 days of mock forecast data
    for (int i = 1; i <= 5; i++) {
      final date = now.add(Duration(days: i));
      final temp = 20 + (i * 2);

      forecasts.add(
        WeatherModel(
          cityName: 'Nakuru',
          country: 'KE',
          temperature: temp.toDouble(),
          description: i.isEven ? 'sunny' : 'cloudy',
          mainWeather: i.isEven ? 'Clear' : 'Clouds',
          feelsLike: temp + 2.0,
          humidity: 60 + (i * 5),
          windSpeed: 2.0 + i,
          pressure: 1010 + i,
          dateTime: date,
          icon: i.isEven ? '01d' : '02d',
          latitude: null,
          longitude: null,
        ),
      );
    }

    return ForecastModel(forecasts: forecasts);
  }
}
