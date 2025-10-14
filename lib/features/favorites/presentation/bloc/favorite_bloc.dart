import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_app/features/favorites/presentation/bloc/favorite_event.dart';
import 'package:weather_app/features/favorites/presentation/bloc/favorite_state.dart';
import '../../data/datasources/favorites_local_data_source.dart';
import '../../data/models/favorite_location_model.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final FavoritesLocalDataSource localDataSource;

  FavoritesBloc({required this.localDataSource})
    : super(const FavoritesInitial()) {
    on<LoadFavorites>(_onLoadFavorites);
    on<AddFavorite>(_onAddFavorite);
    on<RemoveFavorite>(_onRemoveFavorite);
    on<CheckIfFavorite>(_onCheckIfFavorite);
  }

  Future<void> _onLoadFavorites(
    LoadFavorites event,
    Emitter<FavoritesState> emit,
  ) async {
    emit(const FavoritesLoading());
    try {
      final favorites = await localDataSource.getFavorites();
      emit(FavoritesLoaded(favorites: favorites));
    } catch (e) {
      emit(FavoritesError('Failed to load favorites: $e'));
    }
  }

  Future<void> _onAddFavorite(
    AddFavorite event,
    Emitter<FavoritesState> emit,
  ) async {
    try {
      final location = FavoriteLocationModel.fromWeatherEntity(
        event.cityName,
        event.country,
        event.latitude,
        event.longitude,
      );

      await localDataSource.addFavorite(location);

      // Reload favorites
      final favorites = await localDataSource.getFavorites();
      emit(
        FavoritesLoaded(favorites: favorites, isCurrentLocationFavorite: true),
      );
    } catch (e) {
      emit(FavoritesError('Failed to add favorite: $e'));
    }
  }

  Future<void> _onRemoveFavorite(
    RemoveFavorite event,
    Emitter<FavoritesState> emit,
  ) async {
    try {
      await localDataSource.removeFavorite(event.cityName);

      // Reload favorites
      final favorites = await localDataSource.getFavorites();
      emit(
        FavoritesLoaded(favorites: favorites, isCurrentLocationFavorite: false),
      );
    } catch (e) {
      emit(FavoritesError('Failed to remove favorite: $e'));
    }
  }

  Future<void> _onCheckIfFavorite(
    CheckIfFavorite event,
    Emitter<FavoritesState> emit,
  ) async {
    try {
      final isFavorite = await localDataSource.isFavorite(event.cityName);
      final favorites = await localDataSource.getFavorites();
      emit(
        FavoritesLoaded(
          favorites: favorites,
          isCurrentLocationFavorite: isFavorite,
        ),
      );
    } catch (e) {
      emit(FavoritesError('Failed to check favorite: $e'));
    }
  }
}
