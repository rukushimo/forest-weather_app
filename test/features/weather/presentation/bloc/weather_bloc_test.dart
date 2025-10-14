import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weather_app/core/error/failures.dart';
import 'package:weather_app/core/services/location_service.dart';
import 'package:weather_app/features/weather/domain/entities/weather_entity.dart';
import 'package:weather_app/features/weather/domain/entities/forecast_entity.dart';
import 'package:weather_app/features/weather/domain/usecases/get_current_location.dart';
import 'package:weather_app/features/weather/domain/usecases/get_current_weather.dart';
import 'package:weather_app/features/weather/domain/usecases/get_weather_forecast.dart';
import 'package:weather_app/core/usecases/usecase.dart';
import 'package:weather_app/features/weather/presentation/bloc/weather_bloc.dart';
import 'package:weather_app/features/weather/presentation/bloc/weather_event.dart';
import 'package:weather_app/features/weather/presentation/bloc/weather_state.dart';

class MockGetCurrentWeather extends Mock implements GetCurrentWeather {}

class MockGetWeatherForecast extends Mock implements GetWeatherForecast {}

class MockGetCurrentLocation extends Mock implements GetCurrentLocation {}

void main() {
  late WeatherBloc bloc;
  late MockGetCurrentWeather mockGetCurrentWeather;
  late MockGetWeatherForecast mockGetWeatherForecast;
  late MockGetCurrentLocation mockGetCurrentLocation;

  setUp(() {
    mockGetCurrentWeather = MockGetCurrentWeather();
    mockGetWeatherForecast = MockGetWeatherForecast();
    mockGetCurrentLocation = MockGetCurrentLocation();
    bloc = WeatherBloc(
      getCurrentWeather: mockGetCurrentWeather,
      getWeatherForecast: mockGetWeatherForecast,
      getCurrentLocation: mockGetCurrentLocation,
    );
  });

  final testLocationData = LocationData(latitude: 0.0, longitude: 0.0);
  final testWeatherEntity = WeatherEntity(
    cityName: 'Test City',
    country: 'TC',
    temperature: 25.0,
    description: 'sunny',
    mainWeather: 'Clear',
    feelsLike: 27.0,
    humidity: 60,
    windSpeed: 3.5,
    pressure: 1013,
    dateTime: DateTime(2023, 1, 1, 12, 0, 0),
    icon: '01d',
  );
  final testForecastEntity = ForecastEntity(forecasts: [testWeatherEntity]);

  setUpAll(() {
    registerFallbackValue(const WeatherParams(latitude: 0.0, longitude: 0.0));
    registerFallbackValue(const NoParams());
  });

  test('initial state should be WeatherInitial', () {
    expect(bloc.state, equals(const WeatherInitial()));
  });

  group('GetWeatherForCurrentLocation', () {
    blocTest<WeatherBloc, WeatherState>(
      'should emit [WeatherLoading, WeatherLoaded] when getting weather is successful',
      build: () {
        when(
          () => mockGetCurrentLocation(any()),
        ).thenAnswer((_) async => Right(testLocationData));
        when(
          () => mockGetCurrentWeather(any()),
        ).thenAnswer((_) async => Right(testWeatherEntity));
        when(
          () => mockGetWeatherForecast(any()),
        ).thenAnswer((_) async => Right(testForecastEntity));
        return bloc;
      },
      act: (bloc) => bloc.add(const GetWeatherForCurrentLocation()),
      expect: () => [
        const WeatherLoading(),
        WeatherLoaded(
          currentWeather: testWeatherEntity,
          forecast: testForecastEntity,
        ),
      ],
    );

    blocTest<WeatherBloc, WeatherState>(
      'should emit [WeatherLoading, WeatherError] when getting location fails',
      build: () {
        when(() => mockGetCurrentLocation(any())).thenAnswer(
          (_) async => const Left(LocationFailure('Location error')),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(const GetWeatherForCurrentLocation()),
      expect: () => [
        const WeatherLoading(),
        const WeatherError('Location error'),
      ],
    );

    blocTest<WeatherBloc, WeatherState>(
      'should emit [WeatherLoading, WeatherError] when getting weather fails',
      build: () {
        when(
          () => mockGetCurrentLocation(any()),
        ).thenAnswer((_) async => Right(testLocationData));
        when(
          () => mockGetCurrentWeather(any()),
        ).thenAnswer((_) async => const Left(ServerFailure('Server error')));
        return bloc;
      },
      act: (bloc) => bloc.add(const GetWeatherForCurrentLocation()),
      expect: () => [
        const WeatherLoading(),
        const WeatherError('Server error'),
      ],
    );
  });
}
