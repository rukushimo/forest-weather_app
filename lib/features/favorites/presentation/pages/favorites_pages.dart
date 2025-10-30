import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/dependency_injection/injection_container.dart' as di;
import '../../../../shared/widgets/weather_icon.dart';
import '../../../weather/domain/entities/weather_entity.dart';
import '../../../weather/domain/usecases/get_current_weather.dart';
import '../../../weather/presentation/bloc/weather_bloc.dart';
import '../../../weather/presentation/bloc/weather_event.dart';
import '../bloc/favorite_bloc.dart';
import '../bloc/favorite_event.dart';
import '../bloc/favorite_state.dart';

// This page shows the user's saved favorite locations
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
              //  print error to debug
              debugPrint('Error loading favorites: ${state.message}');
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
            return const SizedBox(); // fallback
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
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'You can add favorites by tapping the heart icon on the main page.',
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
        final fav = state.favorites[index];
        return FavoriteWeatherCard(
          cityName: fav.cityName,
          country: fav.country,
          latitude: fav.latitude,
          longitude: fav.longitude,
          onDelete: () => _confirmDelete(context, fav.cityName),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, String cityName) {
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
          'Are you sure you want to remove $cityName?',
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

class FavoriteWeatherCard extends StatefulWidget {
  final String cityName;
  final String country;
  final double latitude;
  final double longitude;
  final VoidCallback onDelete;

  const FavoriteWeatherCard({
    super.key,
    required this.cityName,
    required this.country,
    required this.latitude,
    required this.longitude,
    required this.onDelete,
  });

  @override
  State<FavoriteWeatherCard> createState() => _FavoriteWeatherCardState();
}

class _FavoriteWeatherCardState extends State<FavoriteWeatherCard> {
  WeatherEntity? weatherData;
  bool loading = true;
  String? errorText;

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    try {
      final getWeather = di.sl<GetCurrentWeather>();
      final result = await getWeather(
        WeatherParams(latitude: widget.latitude, longitude: widget.longitude),
      );

      result.fold(
        (failure) {
          debugPrint('Failed to load weather for ${widget.cityName}');
          setState(() {
            errorText = 'Failed to load weather data';
            loading = false;
          });
        },
        (weather) {
          setState(() {
            weatherData = weather;
            loading = false;
          });
        },
      );
    } catch (e) {
      setState(() {
        errorText = 'Something went wrong';
        loading = false;
      });
      debugPrint('Weather load error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
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
      child: InkWell(
        onTap: () {
          // not perfect navigation but works fine
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => BlocProvider(
                create: (context) => di.sl<WeatherBloc>()
                  ..add(
                    GetWeatherForCoordinates(widget.latitude, widget.longitude),
                  ),
                child: const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                ),
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.location_city,
                    color: Color(0xFF90ee90),
                    size: 28,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.cityName,
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: widget.onDelete,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (loading)
                const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF90ee90),
                    strokeWidth: 2,
                  ),
                )
              else if (errorText != null)
                Text(errorText!, style: const TextStyle(color: Colors.white70))
              else if (weatherData != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        WeatherIcon(iconCode: weatherData!.icon, size: 40),
                        const SizedBox(width: 10),
                        Text(
                          weatherData!.description,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${weatherData!.temperature.round()}°C (feels like ${weatherData!.feelsLike.round()}°)',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  'Tap to view full forecast →',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
