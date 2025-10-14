// lib/features/weather/data/repositories/weather_repository_impl.dart
import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:weather_app/features/weather/domain/repositories/weather_repositories.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/forecast_entity.dart';
import '../../domain/entities/weather_entity.dart';
import '../datasources/weather_remote_data_source.dart';

class WeatherRepositoryImpl implements WeatherRepository {
  final WeatherRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  WeatherRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, WeatherEntity>> getCurrentWeather(
    double latitude,
    double longitude,
  ) async {
    log('🌍 Repository: Getting weather for lat=$latitude, lon=$longitude');
    if (await networkInfo.isConnected) {
      try {
        final weather = await remoteDataSource.getCurrentWeather(
          latitude,
          longitude,
        );
        log('✅ Repository: Got weather for ${weather.cityName}');
        return Right(weather);
      } on ServerException catch (e) {
        log('❌ Repository: ServerException - ${e.message}');
        return Left(ServerFailure(e.message));
      }
    } else {
      log('❌ Repository: No internet connection');
      return Left(ConnectionFailure());
    }
  }

  @override
  Future<Either<Failure, ForecastEntity>> getWeatherForecast(
    double latitude,
    double longitude,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final forecast = await remoteDataSource.getWeatherForecast(
          latitude,
          longitude,
        );
        return Right(forecast);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return Left(ConnectionFailure());
    }
  }

  @override
  Future<Either<Failure, WeatherEntity>> getWeatherByCity(
    String cityName,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final weather = await remoteDataSource.getWeatherByCity(cityName);
        return Right(weather);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return Left(ConnectionFailure());
    }
  }
}
