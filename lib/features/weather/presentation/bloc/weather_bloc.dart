import 'dart:developer';
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
    on<GetHourlyForecast>(_onGetHourlyForecast); // NEW
  }

  Future<void> _onGetWeatherForCurrentLocation(
    GetWeatherForCurrentLocation event,
    Emitter<WeatherState> emit,
  ) async {
    emit(const WeatherLoading());

    try {
      final locationResult = await getCurrentLocation(const NoParams());

      await locationResult.fold(
        (failure) async {
          emit(WeatherError(_mapFailureToMessage(failure)));
        },
        (locationData) async {
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
              final forecastResult = await getWeatherForecast(weatherParams);

              forecastResult.fold(
                (failure) {
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
    add(const GetWeatherForCurrentLocation());
  }

  // NEW: Handle hourly forecast request
  Future<void> _onGetHourlyForecast(
    GetHourlyForecast event,
    Emitter<WeatherState> emit,
  ) async {
    log(
      '🕐 Getting hourly forecast for ${DateFormat('yyyy-MM-dd').format(event.date)}',
    );

    // Filter forecasts for the selected date
    final dateKey = DateFormat('yyyy-MM-dd').format(event.date);
    final hourlyForecasts = event.allForecasts.where((forecast) {
      final forecastDateKey = DateFormat(
        'yyyy-MM-dd',
      ).format(forecast.dateTime);
      return forecastDateKey == dateKey;
    }).toList();

    // Sort by time
    hourlyForecasts.sort((a, b) => a.dateTime.compareTo(b.dateTime));

    log('✅ Found ${hourlyForecasts.length} hourly forecasts');

    emit(
      HourlyForecastLoaded(date: event.date, hourlyForecasts: hourlyForecasts),
    );
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
