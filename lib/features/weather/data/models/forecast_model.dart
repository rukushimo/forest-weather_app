import '../../domain/entities/forecast_entity.dart';
import 'weather_model.dart';

class ForecastModel extends ForecastEntity {
  const ForecastModel({required super.forecasts});

  factory ForecastModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> forecastList = json['list'] ?? [];
    final String cityName = json['city']['name'] ?? '';
    final String country = json['city']['country'] ?? '';

    // Get coordinates from the city object
    final double? latitude = json['city']['coord']?['lat']?.toDouble();
    final double? longitude = json['city']['coord']?['lon']?.toDouble();

    final List<WeatherModel> forecasts = forecastList
        .map(
          (forecast) => WeatherModel.fromForecastJson(
            forecast as Map<String, dynamic>,
            cityName,
            country,
            latitude: latitude,
            longitude: longitude,
          ),
        )
        .toList();

    return ForecastModel(forecasts: forecasts);
  }
}
