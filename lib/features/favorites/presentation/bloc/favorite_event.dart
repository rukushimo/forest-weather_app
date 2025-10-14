import 'package:equatable/equatable.dart';

abstract class FavoritesEvent extends Equatable {
  const FavoritesEvent();

  @override
  List<Object?> get props => [];
}

class LoadFavorites extends FavoritesEvent {
  const LoadFavorites();
}

class AddFavorite extends FavoritesEvent {
  final String cityName;
  final String country;
  final double latitude;
  final double longitude;

  const AddFavorite({
    required this.cityName,
    required this.country,
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object> get props => [cityName, country, latitude, longitude];
}

class RemoveFavorite extends FavoritesEvent {
  final String cityName;

  const RemoveFavorite(this.cityName);

  @override
  List<Object> get props => [cityName];
}

class CheckIfFavorite extends FavoritesEvent {
  final String cityName;

  const CheckIfFavorite(this.cityName);

  @override
  List<Object> get props => [cityName];
}
