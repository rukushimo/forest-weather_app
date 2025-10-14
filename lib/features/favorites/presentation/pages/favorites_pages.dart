import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/dependency_injection/injection_container.dart' as di;
// ignore: unused_import
import '../../../weather/presentation/bloc/weather_bloc.dart';
// ignore: unused_import
import '../../../weather/presentation/bloc/weather_event.dart';
import '../bloc/favorite_bloc.dart';
import '../bloc/favorite_event.dart';
import '../bloc/favorite_state.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<FavoritesBloc>()..add(const LoadFavorites()),
      child: const FavoritesView(),
    );
  }
}

class FavoritesView extends StatelessWidget {
  const FavoritesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Favorite Locations',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF2d5016),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2d5016), Color(0xFF1a3409), Color(0xFF654321)],
          ),
        ),
        child: BlocBuilder<FavoritesBloc, FavoritesState>(
          builder: (context, state) {
            if (state is FavoritesLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF90ee90)),
              );
            } else if (state is FavoritesLoaded) {
              if (state.favorites.isEmpty) {
                return _buildEmptyState(context);
              }
              return _buildFavoritesList(context, state);
            } else if (state is FavoritesError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 100,
              color: Colors.white.withValues(alpha: .5),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Favorites Yet',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Start adding your favorite locations by tapping the heart icon on the weather page!',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withValues(alpha: .8),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back to Weather'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2d5016),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoritesList(BuildContext context, FavoritesLoaded state) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.favorites.length,
      itemBuilder: (context, index) {
        final favorite = state.favorites[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          color: const Color(0xFF1a3409).withValues(alpha: .8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: const Color(0xFF90ee90).withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 12,
            ),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF90ee90).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.location_city,
                color: Color(0xFF90ee90),
                size: 28,
              ),
            ),
            title: Text(
              favorite.cityName,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            subtitle: Text(
              favorite.country,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // View weather button
                IconButton(
                  icon: const Icon(Icons.wb_sunny, color: Color(0xFF90ee90)),
                  onPressed: () {
                    // 🔥 Dispatch event to WeatherBloc
                    context.read<WeatherBloc>().add(
                      GetWeatherForCity(favorite.cityName),
                    );

                    // ✅ Close FavoritesPage → go back to WeatherPage
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Loading weather for ${favorite.cityName}...',
                        ),
                        backgroundColor: const Color(0xFF2d5016),
                      ),
                    );
                    Navigator.pop(context);
                  },
                  tooltip: 'View Weather',
                ),
                // Remove from favorites
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () {
                    _showDeleteConfirmation(context, favorite.cityName);
                  },
                  tooltip: 'Remove',
                ),
              ],
            ),
            onTap: () {
              context.read<WeatherBloc>().add(
                GetWeatherForCity(favorite.cityName),
              );

              Navigator.pop(context);
              // Navigate back and load weather for this location
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Loading weather for ${favorite.cityName}...'),
                  backgroundColor: const Color(0xFF2d5016),
                  duration: const Duration(seconds: 2),
                ),
              );
              Navigator.pop(context);
            },
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, String cityName) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1a3409),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Remove Favorite?',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to remove $cityName from your favorites?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF90ee90)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<FavoritesBloc>().add(RemoveFavorite(cityName));
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$cityName removed from favorites'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}
