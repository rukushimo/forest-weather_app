// lib/features/weather/data/models/weather_model.dart
import '../../domain/entities/weather_entity.dart';

class WeatherModel extends WeatherEntity {
  const WeatherModel({
    required super.cityName,
    required super.country,
    required super.temperature,
    required super.description,
    required super.mainWeather,
    required super.feelsLike,
    required super.humidity,
    required super.windSpeed,
    required super.pressure,
    required super.dateTime,
    required super.icon,
    required latitude,
    required longitude,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      cityName: json['name'] ?? '',
      country: json['sys']['country'] ?? '',
      temperature: (json['main']['temp'] as num).toDouble(),
      description: json['weather'][0]['description'] ?? '',
      mainWeather: json['weather'][0]['main'] ?? '',
      feelsLike: (json['main']['feels_like'] as num).toDouble(),
      humidity: json['main']['humidity'] ?? 0,
      windSpeed: (json['wind']['speed'] as num).toDouble(),
      pressure: json['main']['pressure'] ?? 0,
      dateTime: DateTime.fromMillisecondsSinceEpoch((json['dt'] as int) * 1000),
      icon: json['weather'][0]['icon'] ?? '',
      latitude: null,
      longitude: null,
    );
  }

  factory WeatherModel.fromForecastJson(
    Map<String, dynamic> json,
    String cityName,
    String country,
  ) {
    return WeatherModel(
      cityName: cityName,
      country: country,
      temperature: (json['main']['temp'] as num).toDouble(),
      description: json['weather'][0]['description'] ?? '',
      mainWeather: json['weather'][0]['main'] ?? '',
      feelsLike: (json['main']['feels_like'] as num).toDouble(),
      humidity: json['main']['humidity'] ?? 0,
      windSpeed: (json['wind']['speed'] as num).toDouble(),
      pressure: json['main']['pressure'] ?? 0,
      dateTime: DateTime.fromMillisecondsSinceEpoch((json['dt'] as int) * 1000),
      icon: json['weather'][0]['icon'] ?? '',
      latitude: null,
      longitude: null,
    );
  }

  get latitude => null;

  get longitude => null;

  Map<String, dynamic> toJson() {
    return {
      'name': cityName,
      'sys': {'country': country},
      'main': {
        'temp': temperature,
        'feels_like': feelsLike,
        'humidity': humidity,
        'pressure': pressure,
      },
      'weather': [
        {'main': mainWeather, 'description': description, 'icon': icon},
      ],
      'wind': {'speed': windSpeed},
      'dt': dateTime.millisecondsSinceEpoch ~/ 1000,
    };
  }
}
