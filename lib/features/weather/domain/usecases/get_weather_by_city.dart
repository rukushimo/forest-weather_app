import 'package:dartz/dartz.dart';
import 'package:weather_app/features/weather/domain/repositories/weather_repositories.dart';
import 'package:weather_app/core/usecases/usecase.dart';
import '../../../../core/error/failures.dart';
import '../entities/weather_entity.dart';

class WeatherCityParams {
  final String cityName;

  const WeatherCityParams({required this.cityName});
}

class GetWeatherByCity implements UseCase<WeatherEntity, WeatherCityParams> {
  final WeatherRepository repository;

  GetWeatherByCity(this.repository);

  @override
  Future<Either<Failure, WeatherEntity>> call(WeatherCityParams params) async {
    return await repository.getWeatherByCity(params.cityName);
  }
}
