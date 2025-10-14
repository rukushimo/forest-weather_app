// lib/features/weather/domain/usecases/get_current_weather.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:weather_app/features/weather/domain/repositories/weather_repositories.dart';
import 'package:weather_app/core/usecases/usecase.dart';
import '../../../../core/error/failures.dart';
import '../entities/weather_entity.dart';

class GetCurrentWeather implements UseCase<WeatherEntity, WeatherParams> {
  final WeatherRepository repository;

  GetCurrentWeather(this.repository);

  @override
  Future<Either<Failure, WeatherEntity>> call(WeatherParams params) async {
    return await repository.getCurrentWeather(
      params.latitude,
      params.longitude,
    );
  }
}

class WeatherParams extends Equatable {
  final double latitude;
  final double longitude;

  const WeatherParams({required this.latitude, required this.longitude});

  @override
  List<Object> get props => [latitude, longitude];
}
