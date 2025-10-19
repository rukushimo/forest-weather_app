// lib/features/favorites/domain/entities/favorite_location.dart
import 'package:equatable/equatable.dart';

class FavoriteLocation extends Equatable {
  final String cityName;
  final String country;
  final double latitude;
  final double longitude;
  final DateTime addedAt;

  const FavoriteLocation({
    required this.cityName,
    required this.country,
    required this.latitude,
    required this.longitude,
    required this.addedAt,
  });

  @override
  List<Object?> get props => [cityName, country, latitude, longitude, addedAt];
}
