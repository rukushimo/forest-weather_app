import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weather_app/core/error/failures.dart';
import 'package:weather_app/features/weather/domain/entities/weather_entity.dart';
import 'package:weather_app/features/weather/domain/repositories/weather_repositories.dart';
import 'package:weather_app/features/weather/domain/usecases/get_current_weather.dart';

class MockWeatherRepository extends Mock implements WeatherRepository {}

void main() {
  late GetCurrentWeather usecase;
  late MockWeatherRepository mockWeatherRepository;

  setUp(() {
    mockWeatherRepository = MockWeatherRepository();
    usecase = GetCurrentWeather(mockWeatherRepository);
  });

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
    dateTime: DateTime.parse('2023-01-01T12:00:00.000Z'),
    icon: '01d',
  );

  const testParams = WeatherParams(latitude: 0.0, longitude: 0.0);

  test('should get current weather from the repository', () async {
    // arrange
    when(
      () => mockWeatherRepository.getCurrentWeather(any(), any()),
    ).thenAnswer((_) async => Right(testWeatherEntity));

    // act
    final result = await usecase(testParams);

    // assert
    expect(result, Right(testWeatherEntity));
    verify(() => mockWeatherRepository.getCurrentWeather(0.0, 0.0));
    verifyNoMoreInteractions(mockWeatherRepository);
  });

  test('should return failure when repository call is unsuccessful', () async {
    // arrange
    when(
      () => mockWeatherRepository.getCurrentWeather(any(), any()),
    ).thenAnswer((_) async => const Left(ServerFailure('Server error')));

    // act
    final result = await usecase(testParams);

    // assert
    expect(result, const Left(ServerFailure('Server error')));
    verify(() => mockWeatherRepository.getCurrentWeather(0.0, 0.0));
    verifyNoMoreInteractions(mockWeatherRepository);
  });
}
