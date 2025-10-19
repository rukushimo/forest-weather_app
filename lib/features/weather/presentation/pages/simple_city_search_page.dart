import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/dependency_injection/injection_container.dart' as di;
import '../../../../shared/widgets/error_widget.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/weather_background.dart';
import '../../domain/entities/location_entity.dart';
import '../../data/models/location_model.dart';
import '../../../favorites/presentation/bloc/favorite_bloc.dart';
import '../../../favorites/presentation/bloc/favorite_event.dart';
import '../../../favorites/presentation/bloc/favorite_state.dart';
import '../../../favorites/presentation/pages/favorites_pages.dart';
import '../bloc/weather_bloc.dart';
import '../bloc/weather_event.dart';
import '../bloc/weather_state.dart';
import '../widgets/current_weather_card.dart';
import '../widgets/forecast_list.dart';

class SimpleCitySearchPage extends StatefulWidget {
  const SimpleCitySearchPage({super.key});

  @override
  State<SimpleCitySearchPage> createState() => _SimpleCitySearchPageState();
}

class _SimpleCitySearchPageState extends State<SimpleCitySearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final Dio _dio = Dio();

  bool _showSearch = true;
  bool _isSearching = false;
  List<LocationEntity> _searchResults = [];
  String? _errorMessage;

  LocationEntity? _currentLocation;

  Future<void> _searchCities(String query) async {
    if (query.length < 2) {
      setState(() {
        _searchResults = [];
        _errorMessage = null;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _errorMessage = null;
    });

    try {
      debugPrint('🔍 Searching for: $query');

      final response = await _dio.get(
        '${ApiConstants.geocodingBaseUrl}${ApiConstants.geocodingDirectEndpoint}',
        queryParameters: {
          'q': query,
          'limit': 10,
          'appid': ApiConstants.apiKey,
        },
      );

      debugPrint('✅ Search response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;

        if (data.isEmpty) {
          setState(() {
            _searchResults = [];
            _errorMessage = 'No cities found for "$query"';
            _isSearching = false;
          });
        } else {
          // Remove duplicate locations based on coordinates (rounded to 2 decimals)
          final uniqueLocations = <String, LocationEntity>{};

          for (var json in data) {
            final location = LocationModel.fromJson(
              json as Map<String, dynamic>,
            );
            final key =
                '${location.latitude.toStringAsFixed(2)}_${location.longitude.toStringAsFixed(2)}';

            // Only add if we don't have this location already
            if (!uniqueLocations.containsKey(key)) {
              uniqueLocations[key] = location;
            }
          }

          setState(() {
            _searchResults = uniqueLocations.values.toList();
            _isSearching = false;
          });
          debugPrint('✅ Found ${_searchResults.length} unique cities');
        }
      }
    } catch (e) {
      debugPrint('❌ Search error: $e');
      setState(() {
        _errorMessage = 'Search failed. Please try again.';
        _isSearching = false;
        _searchResults = [];
      });
    }
  }

  void _loadWeatherForLocation(LocationEntity location) {
    setState(() {
      _showSearch = false;
      _currentLocation = location;
    });
  }

  String _getLocationDisplayName(LocationEntity location) {
    // Build a clear, unique name
    final parts = <String>[location.name];

    if (location.state != null && location.state!.isNotEmpty) {
      parts.add(location.state!);
    }

    parts.add(location.country);

    return parts.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => di.sl<WeatherBloc>()),
        BlocProvider(
          create: (context) =>
              di.sl<FavoritesBloc>()..add(const LoadFavorites()),
        ),
      ],
      child: Scaffold(
        extendBodyBehindAppBar: !_showSearch,
        appBar: AppBar(
          backgroundColor: _showSearch
              ? const Color(0xFF2d5016)
              : Colors.transparent,
          title: Text(
            _showSearch ? 'Search Any City' : 'Weather',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            if (!_showSearch) ...[
              IconButton(
                icon: const Icon(Icons.search, color: Colors.white),
                onPressed: () {
                  setState(() {
                    _showSearch = true;
                    _searchController.clear();
                    _searchResults = [];
                  });
                },
                tooltip: 'Search again',
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FavoritesPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.list, color: Colors.white),
                tooltip: 'View Favorites',
              ),
              BlocBuilder<WeatherBloc, WeatherState>(
                builder: (context, weatherState) {
                  return BlocBuilder<FavoritesBloc, FavoritesState>(
                    builder: (context, favState) {
                      bool isFavorite = false;
                      String? cityName;
                      String? country;

                      if (weatherState is WeatherLoaded) {
                        cityName = weatherState.currentWeather.cityName;
                        country = weatherState.currentWeather.country;

                        if (favState is FavoritesLoaded) {
                          isFavorite = favState.favorites.any(
                            (fav) => fav.cityName == cityName,
                          );
                        }
                      }

                      return IconButton(
                        onPressed:
                            weatherState is WeatherLoaded &&
                                cityName != null &&
                                _currentLocation != null
                            ? () {
                                if (isFavorite) {
                                  context.read<FavoritesBloc>().add(
                                    RemoveFavorite(cityName!),
                                  );
                                } else {
                                  context.read<FavoritesBloc>().add(
                                    AddFavorite(
                                      cityName: cityName!,
                                      country: country ?? '',
                                      latitude: _currentLocation!.latitude,
                                      longitude: _currentLocation!.longitude,
                                    ),
                                  );
                                }
                              }
                            : null,
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.white,
                        ),
                        tooltip: isFavorite
                            ? 'Remove from favorites'
                            : 'Add to favorites',
                      );
                    },
                  );
                },
              ),
              IconButton(
                onPressed: () {
                  if (_currentLocation != null) {
                    context.read<WeatherBloc>().add(
                      GetWeatherForCoordinates(
                        _currentLocation!.latitude,
                        _currentLocation!.longitude,
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.refresh, color: Colors.white),
                tooltip: 'Refresh Weather',
              ),
            ],
          ],
        ),
        body: _showSearch ? _buildSearchView() : _buildWeatherView(),
      ),
    );
  }

  Widget _buildSearchView() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2d5016), Color(0xFF1a3409), Color(0xFF654321)],
        ),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF90ee90).withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.public, color: Color(0xFF90ee90), size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    decoration: const InputDecoration(
                      hintText: 'Search any city worldwide...',
                      hintStyle: TextStyle(color: Colors.white54),
                      border: InputBorder.none,
                    ),
                    onChanged: (query) {
                      Future.delayed(const Duration(milliseconds: 500), () {
                        if (_searchController.text == query) {
                          _searchCities(query);
                        }
                      });
                    },
                  ),
                ),
                if (_searchController.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear, color: Colors.white70),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchResults = [];
                        _errorMessage = null;
                      });
                    },
                  ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              _searchController.text.isEmpty
                  ? 'Type at least 2 characters to search'
                  : _isSearching
                  ? 'Searching...'
                  : _searchResults.isNotEmpty
                  ? 'Found ${_searchResults.length} ${_searchResults.length == 1 ? 'location' : 'locations'}'
                  : '',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 8),

          Expanded(
            child: Builder(
              builder: (builderContext) {
                if (_searchController.text.isEmpty) {
                  return _buildInitialState();
                } else if (_isSearching) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF90ee90)),
                  );
                } else if (_errorMessage != null) {
                  return _buildErrorState(_errorMessage!);
                } else if (_searchResults.isEmpty) {
                  return _buildNoResults();
                } else {
                  return _buildResultsList(builderContext);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.travel_explore,
              size: 100,
              color: Colors.white.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            const Text(
              'Search Any City Worldwide',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Type the name of any city, state, or country',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Text(
              'Try: Paris, New York, Tokyo, Mumbai, Cairo...',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.5),
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off,
              size: 80,
              color: Colors.white.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            const Text(
              'No cities found',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Try a different spelling or city name',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 80, color: Colors.redAccent),
            const SizedBox(height: 24),
            const Text(
              'Search Error',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withValues(alpha: 0.8),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsList(BuildContext builderContext) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final location = _searchResults[index];
        final displayName = _getLocationDisplayName(location);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          color: const Color(0xFF1a3409).withValues(alpha: 0.9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: const Color(0xFF90ee90).withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF90ee90).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.location_on,
                color: Color(0xFF90ee90),
                size: 26,
              ),
            ),
            title: Text(
              displayName,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '${location.latitude.toStringAsFixed(4)}°, ${location.longitude.toStringAsFixed(4)}°',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 11,
                  fontFamily: 'monospace',
                ),
              ),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              color: const Color(0xFF90ee90).withValues(alpha: 0.7),
              size: 18,
            ),
            onTap: () {
              debugPrint('🎯 Loading weather for: $displayName');
              debugPrint(
                '📍 Coordinates: ${location.latitude}, ${location.longitude}',
              );
              _loadWeatherForLocation(location);
              builderContext.read<WeatherBloc>().add(
                GetWeatherForCoordinates(location.latitude, location.longitude),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildWeatherView() {
    return BlocBuilder<WeatherBloc, WeatherState>(
      builder: (context, state) {
        if (state is WeatherLoading) {
          return const WeatherBackground(
            weatherCondition: 'default',
            child: LoadingWidget(message: 'Loading weather...'),
          );
        } else if (state is WeatherLoaded) {
          return WeatherBackground(
            weatherCondition: state.currentWeather.mainWeather,
            child: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    CurrentWeatherCard(weather: state.currentWeather),
                    if (state.forecast != null)
                      ForecastList(forecast: state.forecast!),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          );
        } else if (state is WeatherError) {
          return WeatherBackground(
            weatherCondition: 'default',
            child: ErrorDisplayWidget(
              message: state.message,
              onRetry: () {
                setState(() {
                  _showSearch = true;
                });
              },
            ),
          );
        }
        return const SizedBox();
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
