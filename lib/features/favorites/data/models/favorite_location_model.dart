import 'package:weather_app/features/weather/domain/entities/favorite_location.dart';

class FavoriteLocationModel extends FavoriteLocation {
  const FavoriteLocationModel({
    required super.cityName,
    required super.country,
    required super.latitude,
    required super.longitude,
    required super.addedAt,
    required super.name,
  });

  factory FavoriteLocationModel.fromJson(Map<String, dynamic> json) {
    return FavoriteLocationModel(
      cityName: json['cityName'] as String,
      country: json['country'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      addedAt: DateTime.parse(json['addedAt'] as String),
      name: '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cityName': cityName,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  factory FavoriteLocationModel.fromWeatherEntity(
    String cityName,
    String country,
    double latitude,
    double longitude,
  ) {
    return FavoriteLocationModel(
      cityName: cityName,
      country: country,
      latitude: latitude,
      longitude: longitude,
      addedAt: DateTime.now(),
      name: '',
    );
  }
}
