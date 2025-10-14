import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weather_app/core/error/exceptions.dart';
import 'package:weather_app/core/error/failures.dart';
import 'package:weather_app/core/network/network_info.dart';
import 'package:weather_app/features/weather/data/datasources/weather_remote_data_source.dart';
import 'package:weather_app/features/weather/data/models/weather_model.dart';
import 'package:weather_app/features/weather/data/repositories/weather_repositories_impl.dart';

class MockWeatherRemoteDataSource extends Mock
    implements WeatherRemoteDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late WeatherRepositoryImpl repository;
  late MockWeatherRemoteDataSource mockRemoteDataSource;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockRemoteDataSource = MockWeatherRemoteDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = WeatherRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      networkInfo: mockNetworkInfo,
    );
  });

  final testWeatherModel = WeatherModel(
    cityName: 'Test City',
    country: 'TC',
    temperature: 25.0,
    description: 'sunny',
    mainWeather: 'Clear',
    feelsLike: 27.0,
    humidity: 60,
    windSpeed: 3.5,
    pressure: 1013,
    dateTime: DateTime(2023, 1, 1, 12, 0, 0, 0, 0),
    icon: '01d',
    latitude: null,
    longitude: null,
  );

  group('getCurrentWeather', () {
    test(
      'should return weather when the call to remote data source is successful',
      () async {
        // arrange
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(
          () => mockRemoteDataSource.getCurrentWeather(any(), any()),
        ).thenAnswer((_) async => testWeatherModel);

        // act
        final result = await repository.getCurrentWeather(0.0, 0.0);

        // assert
        verify(() => mockRemoteDataSource.getCurrentWeather(0.0, 0.0));
        expect(result, equals(Right(testWeatherModel)));
      },
    );

    test(
      'should return connection failure when the device is not connected',
      () async {
        // arrange
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);

        // act
        final result = await repository.getCurrentWeather(0.0, 0.0);

        // assert
        verifyZeroInteractions(mockRemoteDataSource);
        expect(result, equals(Left(ConnectionFailure())));
      },
    );

    test(
      'should return server failure when the call to remote data source is unsuccessful',
      () async {
        // arrange
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(
          () => mockRemoteDataSource.getCurrentWeather(any(), any()),
        ).thenThrow(ServerException('Server error'));

        // act
        final result = await repository.getCurrentWeather(0.0, 0.0);

        // assert
        verify(() => mockRemoteDataSource.getCurrentWeather(0.0, 0.0));
        expect(result, equals(const Left(ServerFailure('Server error'))));
      },
    );
  });
}
