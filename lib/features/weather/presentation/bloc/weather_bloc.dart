import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
// ignore: unused_import
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
// ignore: unused_import
import '../../../../core/services/location_service.dart';
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
  }

  Future<void> _onGetWeatherForCurrentLocation(
    GetWeatherForCurrentLocation event,
    Emitter<WeatherState> emit,
  ) async {
    emit(const WeatherLoading());

    try {
      // First get current location
      final locationResult = await getCurrentLocation(const NoParams());

      await locationResult.fold(
        (failure) async {
          emit(WeatherError(_mapFailureToMessage(failure)));
        },
        (locationData) async {
          // Get current weather
          final weatherParams = WeatherParams(
            latitude: locationData.latitude,
            longitude: locationData.longitude,
          );

          final weatherResult = await getCurrentWeather(weatherParams);

          await weatherResult.fold(
            (failure) async {
              emit(WeatherError(_mapFailureToMessage(failure)));
            },
            (weather) async {
              // Get forecast
              final forecastResult = await getWeatherForecast(weatherParams);

              forecastResult.fold(
                (failure) {
                  // If forecast fails, just show current weather
                  emit(WeatherLoaded(currentWeather: weather));
                },
                (forecast) {
                  emit(
                    WeatherLoaded(currentWeather: weather, forecast: forecast),
                  );
                },
              );
            },
          );
        },
      );
    } catch (e) {
      emit(WeatherError('Unexpected error occurred: $e'));
    }
  }

  Future<void> _onGetWeatherForCity(
    GetWeatherForCity event,
    Emitter<WeatherState> emit,
  ) async {
    emit(const WeatherLoading());

    try {
      // For now, just show an error message
      // City search is handled by the search page with coordinates
      emit(const WeatherError('Please use the search feature to find cities'));
    } catch (e) {
      emit(WeatherError('Failed to get weather: $e'));
    }
  }

  Future<void> _onGetWeatherForCoordinates(
    GetWeatherForCoordinates event,
    Emitter<WeatherState> emit,
  ) async {
    log('🎯 BLoC: Getting weather for coordinates');
    log('📍 Lat: ${event.latitude}, Lon: ${event.longitude}');

    emit(const WeatherLoading());

    try {
      final weatherParams = WeatherParams(
        latitude: event.latitude,
        longitude: event.longitude,
      );

      log('📞 BLoC: Calling getCurrentWeather use case...');

      final weatherResult = await getCurrentWeather(weatherParams);

      await weatherResult.fold(
        (failure) async {
          log('❌ BLoC: Failed - ${_mapFailureToMessage(failure)}');
          emit(WeatherError(_mapFailureToMessage(failure)));
        },
        (weather) async {
          log('✅ BLoC: Got weather for ${weather.cityName}');

          // Get forecast
          final forecastResult = await getWeatherForecast(weatherParams);

          forecastResult.fold(
            (failure) {
              log('⚠️ BLoC: Got weather but forecast failed');
              emit(WeatherLoaded(currentWeather: weather));
            },
            (forecast) {
              log('✅ BLoC: Got weather and forecast');
              emit(WeatherLoaded(currentWeather: weather, forecast: forecast));
            },
          );
        },
      );
    } catch (e) {
      log('❌ BLoC: Exception - $e');
      emit(WeatherError('Failed to get weather: $e'));
    }
  }

  Future<void> _onRefreshWeather(
    RefreshWeather event,
    Emitter<WeatherState> emit,
  ) async {
    // Refresh current weather data
    add(const GetWeatherForCurrentLocation());
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case const (ServerFailure):
        return (failure as ServerFailure).message;
      case const (ConnectionFailure):
        return 'Please check your internet connection';
      case const (LocationFailure):
        return (failure as LocationFailure).message;
      default:
        return 'Something went wrong';
    }
  }
}
