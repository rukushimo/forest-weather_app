// lib/features/weather/presentation/pages/weather_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_app/features/favorites/presentation/bloc/favorite_bloc.dart';
import 'package:weather_app/features/favorites/presentation/bloc/favorite_event.dart';
import 'package:weather_app/features/favorites/presentation/bloc/favorite_state.dart';
import 'package:weather_app/features/favorites/presentation/pages/favorites_pages.dart';
import 'package:weather_app/features/weather/presentation/pages/simple_city_search_page.dart';
import '../../../../core/dependency_injection/injection_container.dart' as di;
import '../../../../shared/widgets/error_widget.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/weather_background.dart';
import '../bloc/weather_bloc.dart';
import '../bloc/weather_event.dart';
import '../bloc/weather_state.dart';
import '../widgets/current_weather_card.dart';
import '../widgets/forecast_list.dart';
// ignore: unused_import
import 'city_search_page.dart';

class WeatherPage extends StatelessWidget {
  const WeatherPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              di.sl<WeatherBloc>()..add(const GetWeatherForCurrentLocation()),
        ),
        BlocProvider(
          create: (context) =>
              di.sl<FavoritesBloc>()..add(const LoadFavorites()),
        ),
      ],
      child: const WeatherView(),
    );
  }
}

class WeatherView extends StatelessWidget {
  const WeatherView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Weather App',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          // Search button
          IconButton(
            onPressed: () async {
              // Navigate and wait for result
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SimpleCitySearchPage(),
                ),
              );
              // Refresh weather when coming back
              if (context.mounted) {
                context.read<WeatherBloc>().add(const RefreshWeather());
              }
            },
            icon: const Icon(Icons.search, color: Colors.white),
            tooltip: 'Search City',
          ),
          // Favorites list button
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FavoritesPage()),
              );
            },
            icon: const Icon(Icons.list, color: Colors.white),
            tooltip: 'View Favorites',
          ),
          // Favorite heart button
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
                      isFavorite = favState.isCurrentLocationFavorite;
                    }
                  }

                  return IconButton(
                    onPressed: weatherState is WeatherLoaded && cityName != null
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
                                  latitude: 0.0,
                                  longitude: 0.0,
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
          // Refresh button
          IconButton(
            onPressed: () {
              context.read<WeatherBloc>().add(const RefreshWeather());
            },
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Refresh Weather',
          ),
        ],
      ),
      body: BlocBuilder<WeatherBloc, WeatherState>(
        builder: (context, state) {
          if (state is WeatherLoading) {
            return const WeatherBackground(
              weatherCondition: 'default',
              child: LoadingWidget(message: 'Getting weather data...'),
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
                  context.read<WeatherBloc>().add(
                    const GetWeatherForCurrentLocation(),
                  );
                },
              ),
            );
          }

          return const WeatherBackground(
            weatherCondition: 'default',
            child: Center(
              child: Text(
                'Welcome to Weather App!\nTap refresh to get started.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          );
        },
      ),
    );
  }
}
