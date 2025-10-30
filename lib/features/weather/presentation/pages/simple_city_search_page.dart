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
  // Controller for the search text field
  final TextEditingController searchController = TextEditingController();
  final Dio dio = Dio();

  // Variables to track state
  bool showSearchScreen = true;
  bool isSearching = false;
  List<LocationEntity> searchResults = [];
  String? errorMessage;
  LocationEntity? selectedLocation;

  // Search for cities using the API
  Future<void> searchForCities(String cityName) async {
    // Don't search if user typed less than 2 letters
    if (cityName.length < 2) {
      setState(() {
        searchResults = [];
        errorMessage = null;
      });
      return;
    }

    // Show loading
    setState(() {
      isSearching = true;
      errorMessage = null;
    });

    try {
      debugPrint("Searching for: $cityName");

      // Call the weather API
      final response = await dio.get(
        '${ApiConstants.geocodingBaseUrl}${ApiConstants.geocodingDirectEndpoint}',
        queryParameters: {
          'q': cityName,
          'limit': 10,
          'appid': ApiConstants.apiKey,
        },
      );

      // Check if request was successful
      if (response.statusCode == 200) {
        final data = response.data as List<dynamic>;

        // No results found
        if (data.isEmpty) {
          setState(() {
            searchResults = [];
            errorMessage = 'No cities found for "$cityName"';
            isSearching = false;
          });
        } else {
          // Remove duplicate locations
          final uniqueLocations = <String, LocationEntity>{};

          for (var json in data) {
            final location = LocationModel.fromJson(json);
            final key =
                '${location.latitude.toStringAsFixed(2)}_${location.longitude.toStringAsFixed(2)}';

            if (!uniqueLocations.containsKey(key)) {
              uniqueLocations[key] = location;
            }
          }

          setState(() {
            searchResults = uniqueLocations.values.toList();
            isSearching = false;
          });
          debugPrint("Found ${searchResults.length} cities");
        }
      }
    } catch (e) {
      debugPrint("Error: $e");
      setState(() {
        errorMessage = 'Something went wrong. Try again.';
        isSearching = false;
      });
    }
  }

  // When user selects a city from search results
  void selectCity(LocationEntity location) {
    setState(() {
      showSearchScreen = false;
      selectedLocation = location;
    });
  }

  // Create display name for location (e.g., "New York, NY, USA")
  String getLocationName(LocationEntity location) {
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
        extendBodyBehindAppBar: !showSearchScreen,
        appBar: AppBar(
          backgroundColor: showSearchScreen
              ? const Color(0xFF2d5016)
              : Colors.transparent,
          title: Text(
            showSearchScreen ? 'Search City' : 'Weather Info',
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
            // Show these buttons only on weather screen
            if (!showSearchScreen) ...[
              // Search button
              IconButton(
                icon: const Icon(Icons.search, color: Colors.white),
                onPressed: () {
                  setState(() {
                    showSearchScreen = true;
                    searchController.clear();
                    searchResults.clear();
                  });
                },
              ),

              // Favorites list button
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FavoritesPage()),
                  );
                },
                icon: const Icon(Icons.list, color: Colors.white),
              ),

              // Favorite/Unfavorite button
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
                            (f) => f.cityName == cityName,
                          );
                        }
                      }

                      return IconButton(
                        onPressed:
                            weatherState is WeatherLoaded &&
                                selectedLocation != null
                            ? () {
                                if (isFavorite) {
                                  // Remove from favorites
                                  context.read<FavoritesBloc>().add(
                                    RemoveFavorite(cityName!),
                                  );
                                } else {
                                  // Add to favorites
                                  context.read<FavoritesBloc>().add(
                                    AddFavorite(
                                      cityName: cityName!,
                                      country: country ?? '',
                                      latitude: selectedLocation!.latitude,
                                      longitude: selectedLocation!.longitude,
                                    ),
                                  );
                                }
                              }
                            : null,
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.white,
                        ),
                      );
                    },
                  );
                },
              ),

              // Refresh button
              IconButton(
                onPressed: () {
                  if (selectedLocation != null) {
                    context.read<WeatherBloc>().add(
                      GetWeatherForCoordinates(
                        selectedLocation!.latitude,
                        selectedLocation!.longitude,
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.refresh, color: Colors.white),
              ),
            ],
          ],
        ),
        body: showSearchScreen ? buildSearchScreen() : buildWeatherScreen(),
      ),
    );
  }

  // Build the search screen
  Widget buildSearchScreen() {
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
          // Search bar
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.public, color: Color(0xFF90ee90)),
                const SizedBox(width: 8),

                Expanded(
                  child: TextField(
                    controller: searchController,
                    autofocus: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Search for a city...',
                      hintStyle: TextStyle(color: Colors.white54),
                      border: InputBorder.none,
                    ),
                    onChanged: (text) {
                      // Wait 500ms before searching (debouncing)
                      Future.delayed(const Duration(milliseconds: 500), () {
                        if (searchController.text == text) {
                          searchForCities(text);
                        }
                      });
                    },
                  ),
                ),

                // Clear button
                if (searchController.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear, color: Colors.white70),
                    onPressed: () {
                      searchController.clear();
                      setState(() {
                        searchResults = [];
                        errorMessage = null;
                      });
                    },
                  ),
              ],
            ),
          ),

          // Results area
          Expanded(
            child: isSearching
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.lightGreen),
                  )
                : errorMessage != null
                ? buildErrorMessage(errorMessage!)
                : searchResults.isEmpty
                ? buildInitialMessage()
                : buildSearchResultsList(),
          ),
        ],
      ),
    );
  }

  // Show initial message
  Widget buildInitialMessage() {
    return Center(
      child: Text(
        "Type a city name to start searching",
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.7),
          fontSize: 16,
        ),
      ),
    );
  }

  // Show error message
  Widget buildErrorMessage(String message) {
    return Center(
      child: Text(
        message,
        style: const TextStyle(color: Colors.redAccent, fontSize: 16),
      ),
    );
  }

  // Show list of search results
  Widget buildSearchResultsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        final location = searchResults[index];
        final displayName = getLocationName(location);

        return Card(
          color: const Color(0xFF1a3409).withValues(alpha: 0.8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            title: Text(
              displayName,
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              '${location.latitude.toStringAsFixed(2)}, ${location.longitude.toStringAsFixed(2)}',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 12,
              ),
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white70,
              size: 16,
            ),
            onTap: () {
              debugPrint("Selected $displayName");
              selectCity(location);

              // Load weather for this location
              context.read<WeatherBloc>().add(
                GetWeatherForCoordinates(location.latitude, location.longitude),
              );
            },
          ),
        );
      },
    );
  }

  // Build the weather screen
  Widget buildWeatherScreen() {
    return BlocBuilder<WeatherBloc, WeatherState>(
      builder: (context, state) {
        // Loading state
        if (state is WeatherLoading) {
          return const WeatherBackground(
            weatherCondition: 'default',
            child: LoadingWidget(message: 'Loading weather...'),
          );
        }
        // Success state - show weather
        else if (state is WeatherLoaded) {
          return WeatherBackground(
            weatherCondition: state.currentWeather.mainWeather,
            child: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    CurrentWeatherCard(weather: state.currentWeather),

                    if (state.forecast != null)
                      ForecastList(forecast: state.forecast!),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          );
        }
        // Error state
        else if (state is WeatherError) {
          return WeatherBackground(
            weatherCondition: 'default',
            child: ErrorDisplayWidget(
              message: state.message,
              onRetry: () {
                setState(() {
                  showSearchScreen = true;
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
    searchController.dispose();
    super.dispose();
  }
}
