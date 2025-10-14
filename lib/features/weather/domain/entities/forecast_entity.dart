// lib/features/weather/domain/entities/forecast_entity.dart
import 'package:equatable/equatable.dart';
import 'package:weather_app/features/weather/domain/entities/weather_entity.dart';

class ForecastEntity extends Equatable {
  final List<WeatherEntity> forecasts;

  const ForecastEntity({required this.forecasts});

  @override
  List<Object?> get props => [forecasts];
}
