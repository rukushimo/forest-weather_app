// lib/features/weather/data/datasources/weather_remote_data_source_mock.dart
import 'dart:developer';

import 'package:weather_app/features/weather/data/models/location_model.dart';
import 'weather_remote_data_source.dart';
import '../models/weather_model.dart';
import '../models/forecast_model.dart';
import 'weather_mock_data_source.dart';

class WeatherRemoteDataSourceMock implements WeatherRemoteDataSource {
  @override
  Future<WeatherModel> getCurrentWeather(double lat, double lon) async {
    log('🧪 Using MOCK weather data (no API key needed)');
    return await WeatherMockDataSource.getMockCurrentWeather();
  }

  @override
  Future<ForecastModel> getWeatherForecast(double lat, double lon) async {
    log('🧪 Using MOCK forecast data (no API key needed)');
    return await WeatherMockDataSource.getMockForecast();
  }

  @override
  Future<WeatherModel> getWeatherByCity(String cityName) async {
    log('🧪 Using MOCK weather data for city: $cityName');
    final weather = await WeatherMockDataSource.getMockCurrentWeather();
    return WeatherModel(
      cityName: cityName,
      country: 'XX',
      temperature: weather.temperature,
      description: weather.description,
      mainWeather: weather.mainWeather,
      feelsLike: weather.feelsLike,
      humidity: weather.humidity,
      windSpeed: weather.windSpeed,
      pressure: weather.pressure,
      dateTime: weather.dateTime,
      icon: weather.icon,
      latitude: weather.latitude,
      longitude: weather.longitude,
    );
  }

  @override
  Future<List<LocationModel>> searchLocations(String query) async {
    log('🧪 MOCK: searchLocations not implemented, returning empty list');
    return [];
  }
}
