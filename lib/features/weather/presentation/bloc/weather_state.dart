import 'package:equatable/equatable.dart';
import '../../domain/entities/forecast_entity.dart';
import '../../domain/entities/weather_entity.dart';

// Base class for all weather-related states.
abstract class WeatherState extends Equatable {
  const WeatherState();

  @override
  List<Object?> get props => [];
}

// Initial state before any weather data is loaded.
class WeatherInitial extends WeatherState {
  const WeatherInitial();
}

// Indicates that weather data is currently being fetched.
class WeatherLoading extends WeatherState {
  const WeatherLoading();
}

// Represents successfully loaded weather and optional forecast data.
class WeatherLoaded extends WeatherState {
  final WeatherEntity currentWeather;
  final ForecastEntity? forecast;

  const WeatherLoaded({required this.currentWeather, this.forecast});

  @override
  List<Object?> get props => [currentWeather, forecast];

  // Creates a new WeatherLoaded instance with updated values.
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

// Represents an error state during weather data fetching.
class WeatherError extends WeatherState {
  final String message;

  const WeatherError(this.message);

  @override
  List<Object> get props => [message];
}

// Represents successfully loaded hourly forecast data for a specific date.
class HourlyForecastLoaded extends WeatherState {
  final DateTime date;
  final List<WeatherEntity> hourlyForecasts;

  const HourlyForecastLoaded({
    required this.date,
    required this.hourlyForecasts,
  });

  @override
  List<Object> get props => [date, hourlyForecasts];
}
