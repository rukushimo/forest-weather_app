import 'package:equatable/equatable.dart';
import 'package:weather_app/features/weather/domain/entities/favorite_location.dart';

abstract class FavoritesState extends Equatable {
  const FavoritesState();

  @override
  List<Object?> get props => [];
}

class FavoritesInitial extends FavoritesState {
  const FavoritesInitial();
}

class FavoritesLoading extends FavoritesState {
  const FavoritesLoading();
}

class FavoritesLoaded extends FavoritesState {
  final List<FavoriteLocation> favorites;
  final bool isCurrentLocationFavorite;

  const FavoritesLoaded({
    required this.favorites,
    this.isCurrentLocationFavorite = false,
  });

  @override
  List<Object?> get props => [favorites, isCurrentLocationFavorite];

  FavoritesLoaded copyWith({
    List<FavoriteLocation>? favorites,
    bool? isCurrentLocationFavorite,
  }) {
    return FavoritesLoaded(
      favorites: favorites ?? this.favorites,
      isCurrentLocationFavorite:
          isCurrentLocationFavorite ?? this.isCurrentLocationFavorite,
    );
  }
}

class FavoritesError extends FavoritesState {
  final String message;

  const FavoritesError(this.message);

  @override
  List<Object> get props => [message];
}
