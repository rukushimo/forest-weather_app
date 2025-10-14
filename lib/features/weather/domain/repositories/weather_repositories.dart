import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/weather_entity.dart';
import '../entities/forecast_entity.dart';

abstract class WeatherRepository {
  Future<Either<Failure, WeatherEntity>> getCurrentWeather(
    double latitude, 
    double longitude
  );
  
  Future<Either<Failure, ForecastEntity>> getWeatherForecast(
    double latitude, 
    double longitude
  );
  
  Future<Either<Failure, WeatherEntity>> getWeatherByCity(String cityName);
}