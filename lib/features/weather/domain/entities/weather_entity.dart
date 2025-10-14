import 'package:equatable/equatable.dart';

class WeatherEntity extends Equatable {
  final String cityName;
  final String country;
  final double temperature;
  final String description;
  final String mainWeather;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final int pressure;
  final DateTime dateTime;
  final String icon;

  const WeatherEntity({
    required this.cityName,
    required this.country,
    required this.temperature,
    required this.description,
    required this.mainWeather,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.pressure,
    required this.dateTime,
    required this.icon,
  });

  @override
  List<Object?> get props => [
        cityName,
        country,
        temperature,
        description,
        mainWeather,
        feelsLike,
        humidity,
        windSpeed,
        pressure,
        dateTime,
        icon,
      ];
}










