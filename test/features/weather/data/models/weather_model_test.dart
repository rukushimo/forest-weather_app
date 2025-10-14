import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:weather_app/features/weather/data/models/weather_model.dart';
import 'package:weather_app/features/weather/domain/entities/weather_entity.dart';

import '../../../../fixtures/fixture_reader.dart';

void main() {
  final testWeatherModel = WeatherModel(
    cityName: 'London',
    country: 'GB',
    temperature: 15.0,
    description: 'light rain',
    mainWeather: 'Rain',
    feelsLike: 13.0,
    humidity: 81,
    windSpeed: 4.1,
    pressure: 1016,
    dateTime: DateTime.utc(2023, 1, 1, 12, 0, 0),
    icon: '10d',
    latitude: null,
    longitude: null,
  );

  test('should be a subclass of WeatherEntity', () async {
    // assert
    expect(testWeatherModel, isA<WeatherEntity>());
  });

  group('fromJson', () {
    test(
      'should return a valid model when the JSON contains proper data',
      () async {
        // arrange
        final Map<String, dynamic> jsonMap = json.decode(
          fixture('weather.json'),
        );

        // act
        final result = WeatherModel.fromJson(jsonMap);

        // assert
        expect(result, testWeatherModel);
      },
    );
  });

  group('toJson', () {
    test('should return a JSON map containing the proper data', () async {
      // act
      final result = testWeatherModel.toJson();

      // assert
      final expectedMap = {
        'name': 'London',
        'sys': {'country': 'GB'},
        'main': {
          'temp': 15.0,
          'feels_like': 13.0,
          'humidity': 81,
          'pressure': 1016,
        },
        'weather': [
          {'main': 'Rain', 'description': 'light rain', 'icon': '10d'},
        ],
        'wind': {'speed': 4.1},
        'dt':
            DateTime.parse('2023-01-01T12:00:00.000Z').millisecondsSinceEpoch ~/
            1000,
      };
      expect(result, expectedMap);
    });
  });
}
