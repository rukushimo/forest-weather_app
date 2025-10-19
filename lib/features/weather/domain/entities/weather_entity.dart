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
  final double? latitude; // Added this
  final double? longitude; // Add this

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
    this.latitude, // Add this
    this.longitude, // Add this
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
    latitude, // Add this
    longitude, // Add this
  ];
}
