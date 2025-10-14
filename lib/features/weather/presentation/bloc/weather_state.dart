// lib/features/weather/presentation/bloc/weather_state.dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/forecast_entity.dart';
import '../../domain/entities/weather_entity.dart';

abstract class WeatherState extends Equatable {
  const WeatherState();

  @override
  List<Object?> get props => [];
}

class WeatherInitial extends WeatherState {
  const WeatherInitial();
}

class WeatherLoading extends WeatherState {
  const WeatherLoading();
}

class WeatherLoaded extends WeatherState {
  final WeatherEntity currentWeather;
  final ForecastEntity? forecast;

  const WeatherLoaded({required this.currentWeather, this.forecast});

  @override
  List<Object?> get props => [currentWeather, forecast];

  WeatherLoaded copyWith({
    WeatherEntity? currentWeather,
    ForecastEntity? forecast,
  }) {
    return WeatherLoaded(
      currentWeather: currentWeather ?? this.currentWeather,
      forecast: forecast ?? this.forecast,
    );
  }
}

class WeatherError extends WeatherState {
  final String message;

  const WeatherError(this.message);

  @override
  List<Object> get props => [message];
}
