// lib/features/weather/domain/usecases/get_weather_forecast.dart
import 'package:dartz/dartz.dart';
import 'package:weather_app/features/weather/domain/repositories/weather_repositories.dart';
import 'package:weather_app/core/usecases/usecase.dart';
import '../../../../core/error/failures.dart';
import '../entities/forecast_entity.dart';
import 'get_current_weather.dart';

class GetWeatherForecast implements UseCase<ForecastEntity, WeatherParams> {
  final WeatherRepository repository;

  GetWeatherForecast(this.repository);

  @override
  Future<Either<Failure, ForecastEntity>> call(WeatherParams params) async {
    return await repository.getWeatherForecast(
      params.latitude,
      params.longitude,
    );
  }
}
