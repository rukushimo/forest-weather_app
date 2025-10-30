import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_current_location.dart';
import '../../domain/usecases/get_current_weather.dart';
import '../../domain/usecases/get_weather_forecast.dart';
import 'weather_event.dart';
import 'weather_state.dart';

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  final GetCurrentWeather getCurrentWeather;
  final GetWeatherForecast getWeatherForecast;
  final GetCurrentLocation getCurrentLocation;

  WeatherBloc({
    required this.getCurrentWeather,
    required this.getWeatherForecast,
    required this.getCurrentLocation,
  }) : super(const WeatherInitial()) {
    on<GetWeatherForCurrentLocation>(_onGetWeatherForCurrentLocation);
    on<GetWeatherForCity>(_onGetWeatherForCity);
    on<GetWeatherForCoordinates>(_onGetWeatherForCoordinates);
    on<RefreshWeather>(_onRefreshWeather);
    on<GetHourlyForecast>(_onGetHourlyForecast);
  }

  /// Fetches weather data using the user's current location.
  Future<void> _onGetWeatherForCurrentLocation(
    GetWeatherForCurrentLocation event,
    Emitter<WeatherState> emit,
  ) async {
    emit(const WeatherLoading());

    try {
      final locationResult = await getCurrentLocation(const NoParams());

      await locationResult.fold(
        (failure) async => emit(WeatherError(_mapFailureToMessage(failure))),
        (locationData) async {
          final params = WeatherParams(
            latitude: locationData.latitude,
            longitude: locationData.longitude,
          );

          final weatherResult = await getCurrentWeather(params);

          await weatherResult.fold(
            (failure) async =>
                emit(WeatherError(_mapFailureToMessage(failure))),
            (weather) async {
              final forecastResult = await getWeatherForecast(params);

              forecastResult.fold(
                (failure) => emit(WeatherLoaded(currentWeather: weather)),
                (forecast) => emit(
                  WeatherLoaded(currentWeather: weather, forecast: forecast),
                ),
              );
            },
          );
        },
      );
    } catch (e) {
      debugPrint('WeatherBloc error: $e');
      emit(const WeatherError('Unexpected error occurred.'));
    }
  }

  // Placeholder for direct city-based search.
  Future<void> _onGetWeatherForCity(
    GetWeatherForCity event,
    Emitter<WeatherState> emit,
  ) async {
    emit(const WeatherLoading());
    emit(const WeatherError('Please use the search feature to find cities.'));
  }

  // Fetches weather data for given latitude and longitude coordinates.
  Future<void> _onGetWeatherForCoordinates(
    GetWeatherForCoordinates event,
    Emitter<WeatherState> emit,
  ) async {
    emit(const WeatherLoading());

    try {
      final params = WeatherParams(
        latitude: event.latitude,
        longitude: event.longitude,
      );

      final weatherResult = await getCurrentWeather(params);

      await weatherResult.fold(
        (failure) async {
          debugPrint('Weather fetch failed: $failure');
          emit(WeatherError(_mapFailureToMessage(failure)));
        },
        (weather) async {
          final forecastResult = await getWeatherForecast(params);

          forecastResult.fold(
            (failure) {
              debugPrint('Forecast unavailable: $failure');
              emit(WeatherLoaded(currentWeather: weather));
            },
            (forecast) {
              emit(WeatherLoaded(currentWeather: weather, forecast: forecast));
            },
          );
        },
      );
    } catch (e) {
      debugPrint('Exception while fetching weather: $e');
      emit(const WeatherError('Unable to fetch weather data.'));
    }
  }

  // Refreshes the current weather view by fetching the latest data.
  Future<void> _onRefreshWeather(
    RefreshWeather event,
    Emitter<WeatherState> emit,
  ) async {
    add(const GetWeatherForCurrentLocation());
  }

  // Filters and loads hourly forecasts for a specific date.
  Future<void> _onGetHourlyForecast(
    GetHourlyForecast event,
    Emitter<WeatherState> emit,
  ) async {
    final dateKey = DateFormat('yyyy-MM-dd').format(event.date);

    final hourlyForecasts =
        event.allForecasts
            .where(
              (f) => DateFormat('yyyy-MM-dd').format(f.dateTime) == dateKey,
            )
            .toList()
          ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

    emit(
      HourlyForecastLoaded(date: event.date, hourlyForecasts: hourlyForecasts),
    );
  }

  // Maps domain-level failures into readable error messages.
  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case const (ServerFailure):
        return (failure as ServerFailure).message;
      case const (ConnectionFailure):
        return 'Please check your internet connection.';
      case const (LocationFailure):
        return (failure as LocationFailure).message;
      default:
        return 'Something went wrong.';
    }
  }
}
