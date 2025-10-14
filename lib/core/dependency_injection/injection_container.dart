import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_app/core/services/location_service.dart';
import 'package:weather_app/features/favorites/presentation/bloc/favorite_bloc.dart';
import 'package:weather_app/features/weather/data/repositories/weather_repositories_impl.dart';
import 'package:weather_app/features/weather/domain/repositories/weather_repositories.dart';

import '../network/network_info.dart';
import '../../features/weather/data/datasources/weather_remote_data_source.dart';
import '../../features/weather/domain/usecases/get_current_location.dart';
import '../../features/weather/domain/usecases/get_current_weather.dart';
import '../../features/weather/domain/usecases/get_weather_forecast.dart';
import '../../features/weather/presentation/bloc/weather_bloc.dart';
import '../../features/weather/presentation/bloc/search_bloc.dart';
import '../../features/favorites/data/datasources/favorites_local_data_source.dart';

final sl = GetIt.instance;

Future<void> init() async {
  log('🔧 Initializing dependency injection...');

  //! Features - Weather
  // Bloc
  sl.registerFactory(() {
    log('📦 Creating WeatherBloc');
    return WeatherBloc(
      getCurrentWeather: sl(),
      getWeatherForecast: sl(),
      getCurrentLocation: sl(),
    );
  });

  // SearchBloc
  sl.registerFactory(() {
    log('📦 Creating SearchBloc');
    return SearchBloc(remoteDataSource: sl());
  });

  // Use cases
  sl.registerLazySingleton(() => GetCurrentWeather(sl()));
  sl.registerLazySingleton(() => GetWeatherForecast(sl()));
  sl.registerLazySingleton(() => GetCurrentLocation(sl()));

  // Repository
  sl.registerLazySingleton<WeatherRepository>(
    () => WeatherRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );

  // Data sources
  sl.registerLazySingleton<WeatherRemoteDataSource>(
    () => WeatherRemoteDataSourceImpl(dio: sl()),
  );

  //! Features - Favorites
  // Bloc
  sl.registerFactory(() {
    log('📦 Creating FavoritesBloc');
    return FavoritesBloc(localDataSource: sl());
  });

  // Data sources
  sl.registerLazySingleton<FavoritesLocalDataSource>(
    () => FavoritesLocalDataSourceImpl(sharedPreferences: sl()),
  );

  //! Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
  sl.registerLazySingleton<LocationService>(() => LocationServiceImpl());

  //! External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => Dio());
  sl.registerLazySingleton(() => Connectivity());

  log('✅ Dependency injection initialized!');
}
