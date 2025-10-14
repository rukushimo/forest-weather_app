import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/search_bloc.dart';
import 'package:weather_app/features/weather/presentation/bloc/search_event.dart';
import 'package:weather_app/features/weather/presentation/bloc/search_state.dart';
import '../../../../core/dependency_injection/injection_container.dart' as di;
import '../../domain/entities/location_entity.dart';
import '../bloc/weather_bloc.dart';
import '../bloc/weather_event.dart';
import '../bloc/weather_state.dart';

class CitySearchPage extends StatefulWidget {
  const CitySearchPage({super.key});

  @override
  State<CitySearchPage> createState() => _CitySearchPageState();
}

class _CitySearchPageState extends State<CitySearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => di.sl<SearchBloc>()),
        BlocProvider(create: (context) => di.sl<WeatherBloc>()),
      ],
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF2d5016),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Search City',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
          child: Column(
            children: [
              // Search TextField
              _buildSearchField(),
              // Results
              Expanded(child: _buildSearchResults()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
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
          const Icon(Icons.search, color: Color(0xFF90ee90), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _focusNode,
              autofocus: true,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: const InputDecoration(
                hintText: 'Type city name...',
                hintStyle: TextStyle(color: Colors.white54, fontSize: 16),
                border: InputBorder.none,
              ),
              onChanged: (query) {
                context.read<SearchBloc>().add(SearchCities(query));
              },
            ),
          ),
          // Clear button (X)
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _searchController,
            builder: (context, value, child) {
              if (value.text.isEmpty) {
                return const SizedBox.shrink();
              }
              return IconButton(
                icon: const Icon(Icons.clear, color: Colors.white70),
                onPressed: () {
                  _searchController.clear();
                  context.read<SearchBloc>().add(const ClearSearch());
                  _focusNode.requestFocus();
                },
                tooltip: 'Clear',
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return BlocListener<WeatherBloc, WeatherState>(
      listener: (context, state) {
        if (state is WeatherLoaded) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '✅ Loaded weather for ${state.currentWeather.cityName}',
              ),
              backgroundColor: const Color(0xFF2d5016),
              duration: const Duration(seconds: 2),
            ),
          );
          Navigator.pop(context);
        } else if (state is WeatherError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ ${state.message}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
      child: BlocBuilder<SearchBloc, SearchState>(
        builder: (context, searchState) {
          if (searchState is SearchInitial) {
            return _buildInitialState();
          } else if (searchState is SearchLoading) {
            return _buildLoadingState();
          } else if (searchState is SearchLoaded) {
            return _buildResultsList(context, searchState.locations);
          } else if (searchState is SearchEmpty) {
            return _buildEmptyState();
          } else if (searchState is SearchError) {
            return _buildErrorState(searchState.message);
          }
          return const SizedBox();
        },
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
              'Search for any city worldwide',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Type at least 2 characters to see suggestions',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                'London',
                'Paris',
                'Tokyo',
                'New York',
                'Dubai',
              ].map((city) => _buildQuickSearchChip(context, city)).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickSearchChip(BuildContext context, String city) {
    return InkWell(
      onTap: () {
        _searchController.text = city;
        context.read<SearchBloc>().add(SearchCities(city));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF90ee90).withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF90ee90).withValues(alpha: 0.5),
          ),
        ),
        child: Text(
          city,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Color(0xFF90ee90), strokeWidth: 3),
          SizedBox(height: 16),
          Text(
            'Searching cities...',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
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

  Widget _buildResultsList(
    BuildContext context,
    List<LocationEntity> locations,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Found ${locations.length} ${locations.length == 1 ? 'city' : 'cities'}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        Expanded(
          child: BlocBuilder<WeatherBloc, WeatherState>(
            builder: (context, weatherState) {
              final isLoading = weatherState is WeatherLoading;

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: locations.length,
                itemBuilder: (context, index) {
                  final location = locations[index];
                  return _buildLocationCard(context, location, isLoading);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLocationCard(
    BuildContext context,
    LocationEntity location,
    bool isLoading,
  ) {
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
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: isLoading
            ? null
            : () {
                debugPrint(
                  '🎯 User tapped: ${location.name}, ${location.country}',
                );
                debugPrint(
                  '📍 Coordinates: ${location.latitude}, ${location.longitude}',
                );
                context.read<WeatherBloc>().add(
                  GetWeatherForCoordinates(
                    location.latitude,
                    location.longitude,
                  ),
                );
              },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(12),
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
              const SizedBox(width: 16),
              // City info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      location.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      location.state != null
                          ? '${location.state}, ${location.country}'
                          : location.country,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Lat: ${location.latitude.toStringAsFixed(2)}, Lon: ${location.longitude.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.5),
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
              // Loading or arrow
              if (isLoading)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF90ee90),
                  ),
                )
              else
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Color(0xFF90ee90),
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
