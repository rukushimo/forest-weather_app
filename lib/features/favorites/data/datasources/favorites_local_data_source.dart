import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/favorite_location_model.dart';

abstract class FavoritesLocalDataSource {
  Future<List<FavoriteLocationModel>> getFavorites();
  Future<void> addFavorite(FavoriteLocationModel location);
  Future<void> removeFavorite(String cityName);
  Future<bool> isFavorite(String cityName);
}

class FavoritesLocalDataSourceImpl implements FavoritesLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String favoritesKey = 'CACHED_FAVORITES';

  FavoritesLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<FavoriteLocationModel>> getFavorites() async {
    final jsonString = sharedPreferences.getString(favoritesKey);
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList
          .map((json) => FavoriteLocationModel.fromJson(json))
          .toList();
    }
    return [];
  }

  @override
  Future<void> addFavorite(FavoriteLocationModel location) async {
    final favorites = await getFavorites();

    // Check if already exists
    final exists = favorites.any((fav) => fav.cityName == location.cityName);
    if (!exists) {
      favorites.add(location);
      final jsonString = json.encode(
        favorites.map((fav) => fav.toJson()).toList(),
      );
      await sharedPreferences.setString(favoritesKey, jsonString);
    }
  }

  @override
  Future<void> removeFavorite(String cityName) async {
    final favorites = await getFavorites();
    favorites.removeWhere((fav) => fav.cityName == cityName);

    final jsonString = json.encode(
      favorites.map((fav) => fav.toJson()).toList(),
    );
    await sharedPreferences.setString(favoritesKey, jsonString);
  }

  @override
  Future<bool> isFavorite(String cityName) async {
    final favorites = await getFavorites();
    return favorites.any((fav) => fav.cityName == cityName);
  }
}
