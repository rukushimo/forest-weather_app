// lib/features/weather/data/datasources/weather_remote_data_source.dart
// ignore: unused_import
import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/weather_model.dart';
import '../models/forecast_model.dart';
import '../models/location_model.dart';

abstract class WeatherRemoteDataSource {
  Future<WeatherModel> getCurrentWeather(double lat, double lon);
  Future<ForecastModel> getWeatherForecast(double lat, double lon);
  Future<WeatherModel> getWeatherByCity(String cityName);
  Future<List<LocationModel>> searchLocations(String query);
}

class WeatherRemoteDataSourceImpl implements WeatherRemoteDataSource {
  final Dio dio;

  WeatherRemoteDataSourceImpl({required this.dio});

  @override
  Future<WeatherModel> getCurrentWeather(double lat, double lon) async {
    try {
      final response = await dio.get(
        '${ApiConstants.baseUrl}${ApiConstants.currentWeatherEndpoint}',
        queryParameters: {
          'lat': lat,
          'lon': lon,
          'appid': ApiConstants.apiKey,
          'units': 'metric',
        },
      );

      if (response.statusCode == 200) {
        return WeatherModel.fromJson(response.data);
      } else {
        throw ServerException('Failed to get current weather');
      }
    } on DioException catch (e) {
      throw ServerException(_handleDioError(e));
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<ForecastModel> getWeatherForecast(double lat, double lon) async {
    try {
      final response = await dio.get(
        '${ApiConstants.baseUrl}${ApiConstants.forecastEndpoint}',
        queryParameters: {
          'lat': lat,
          'lon': lon,
          'appid': ApiConstants.apiKey,
          'units': 'metric',
        },
      );

      if (response.statusCode == 200) {
        return ForecastModel.fromJson(response.data);
      } else {
        throw ServerException('Failed to get weather forecast');
      }
    } on DioException catch (e) {
      throw ServerException(_handleDioError(e));
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<WeatherModel> getWeatherByCity(String cityName) async {
    try {
      final response = await dio.get(
        '${ApiConstants.baseUrl}${ApiConstants.currentWeatherEndpoint}',
        queryParameters: {
          'q': cityName,
          'appid': ApiConstants.apiKey,
          'units': 'metric',
        },
      );

      if (response.statusCode == 200) {
        return WeatherModel.fromJson(response.data);
      } else {
        throw ServerException('Failed to get weather for city');
      }
    } on DioException catch (e) {
      throw ServerException(_handleDioError(e));
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  String _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout';
      case DioExceptionType.sendTimeout:
        return 'Send timeout';
      case DioExceptionType.receiveTimeout:
        return 'Receive timeout';
      case DioExceptionType.badResponse:
        return 'Bad response: ${e.response?.statusCode}';
      case DioExceptionType.cancel:
        return 'Request cancelled';
      case DioExceptionType.connectionError:
        return 'Connection error';
      default:
        return 'Network error occurred';
    }
  }

  @override
  Future<List<LocationModel>> searchLocations(String query) async {
    try {
      log('🔍 Searching for: $query');
      log(
        '🌐 URL: ${ApiConstants.geocodingBaseUrl}${ApiConstants.geocodingDirectEndpoint}',
      );
      log('🔑 API Key: ${ApiConstants.apiKey.substring(0, 8)}...');
      final response = await dio.get(
        '${ApiConstants.geocodingBaseUrl}${ApiConstants.geocodingDirectEndpoint}',
        queryParameters: {
          'q': query,
          'limit': 10, // Return up to 10 results
          'appid': ApiConstants.apiKey,
        },
      );
      log('✅ Response status: ${response.statusCode}');
      log('📦 Response data: ${response.data}');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        if (data.isEmpty) {
          log('⚠️ No cities found for: $query');
        } else {
          log('✅ Found ${data.length} cities');
        }
        return data
            .map((json) => LocationModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw ServerException('Failed to search locations');
      }
    } on DioException catch (e) {
      log('❌ DioException: ${e.response?.statusCode}');
      log('❌ Error data: ${e.response?.data}');
      throw ServerException(_handleDioError(e));
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }
}
