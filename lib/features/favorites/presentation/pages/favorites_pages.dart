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
        return FavoriteWeatherCard(
          cityName: favorite.cityName,
          country: favorite.country,
          latitude: favorite.latitude,
          longitude: favorite.longitude,
          onDelete: () => _showDeleteConfirmation(context, favorite.cityName),
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

// Separate widget that fetches and displays weather for each favorite
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
  WeatherEntity? _weather;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    try {
      final getCurrentWeather = di.sl<GetCurrentWeather>();
      final result = await getCurrentWeather(
        WeatherParams(latitude: widget.latitude, longitude: widget.longitude),
      );

      result.fold(
        (failure) {
          if (mounted) {
            setState(() {
              _error = 'Failed to load';
              _isLoading = false;
            });
          }
        },
        (weather) {
          if (mounted) {
            setState(() {
              _weather = weather;
              _isLoading = false;
            });
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error';
          _isLoading = false;
        });
      }
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
          // Navigate to full weather page with these exact coordinates
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
              // Header with city name and delete button
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF90ee90).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.location_city,
                      color: Color(0xFF90ee90),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.cityName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          widget.country,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: widget.onDelete,
                    tooltip: 'Remove',
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Weather info
              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(
                      color: Color(0xFF90ee90),
                      strokeWidth: 2,
                    ),
                  ),
                )
              else if (_error != null)
                Center(
                  child: Text(
                    _error!,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 14,
                    ),
                  ),
                )
              else if (_weather != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Weather icon and description
                    Expanded(
                      child: Row(
                        children: [
                          WeatherIcon(iconCode: _weather!.icon, size: 50),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _weather!.description
                                  .split(' ')
                                  .map(
                                    (word) =>
                                        word[0].toUpperCase() +
                                        word.substring(1),
                                  )
                                  .join(' '),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Temperature
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${_weather!.temperature.round()}°C',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Feels ${_weather!.feelsLike.round()}°',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

              // Additional weather details
              if (_weather != null) ...[
                const SizedBox(height: 12),
                const Divider(
                  color: Color(0xFF90ee90),
                  thickness: 0.5,
                  height: 1,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildWeatherDetail(
                      Icons.water_drop,
                      '${_weather!.humidity}%',
                      'Humidity',
                    ),
                    _buildWeatherDetail(
                      Icons.air,
                      '${_weather!.windSpeed.toStringAsFixed(1)} m/s',
                      'Wind',
                    ),
                    _buildWeatherDetail(
                      Icons.compress,
                      '${_weather!.pressure} hPa',
                      'Pressure',
                    ),
                  ],
                ),
              ],

              // Tap to view full details hint
              const SizedBox(height: 12),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Tap to view full forecast',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward,
                      size: 12,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherDetail(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF90ee90), size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
