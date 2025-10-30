import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/dependency_injection/injection_container.dart' as di;
import '../../../../shared/widgets/error_widget.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/weather_background.dart';
import '../../../favorites/presentation/bloc/favorite_bloc.dart';
import '../../../favorites/presentation/bloc/favorite_event.dart';
import '../../../favorites/presentation/bloc/favorite_state.dart';
import '../../../favorites/presentation/pages/favorites_pages.dart';
import '../bloc/weather_bloc.dart';
import '../bloc/weather_event.dart';
import '../bloc/weather_state.dart';
import '../widgets/current_weather_card.dart';
import '../widgets/forecast_list.dart';
import 'simple_city_search_page.dart';

class WeatherPage extends StatelessWidget {
  const WeatherPage({super.key});

  @override
  Widget build(BuildContext context) {
    // provide both weather and favorites bloc
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              di.sl<WeatherBloc>()..add(const GetWeatherForCurrentLocation()),
        ),
        BlocProvider(
          create: (_) => di.sl<FavoritesBloc>()..add(const LoadFavorites()),
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
          // search city
          IconButton(
            onPressed: () => _goToSearch(context),
            icon: const Icon(Icons.search, color: Colors.white),
          ),
          // open favorites list
          IconButton(
            onPressed: () => _goToFavorites(context),
            icon: const Icon(Icons.list, color: Colors.white),
          ),
          // add/remove favorites
          _favoriteButton(),
          // refresh current location weather
          IconButton(
            onPressed: () {
              context.read<WeatherBloc>().add(const RefreshWeather());
            },
            icon: const Icon(Icons.refresh, color: Colors.white),
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
          } else {
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
          }
        },
      ),
    );
  }

  Future<void> _goToSearch(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SimpleCitySearchPage()),
    );
    if (context.mounted) {
      context.read<WeatherBloc>().add(const RefreshWeather());
    }
  }

  void _goToFavorites(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const FavoritesPage()),
    );
  }

  Widget _favoriteButton() {
    return BlocBuilder<WeatherBloc, WeatherState>(
      builder: (context, weatherState) {
        return BlocBuilder<FavoritesBloc, FavoritesState>(
          builder: (context, favState) {
            final isFav = _isFavorite(weatherState, favState);
            final canFav = _canFavorite(weatherState);

            return IconButton(
              onPressed: canFav
                  ? () => _toggleFavorite(context, weatherState, isFav)
                  : null,
              icon: Icon(
                isFav ? Icons.favorite : Icons.favorite_border,
                color: isFav ? Colors.red : Colors.white,
              ),
            );
          },
        );
      },
    );
  }

  bool _isFavorite(WeatherState weatherState, FavoritesState favState) {
    if (weatherState is! WeatherLoaded || favState is! FavoritesLoaded) {
      return false;
    }
    return favState.isCurrentLocationFavorite;
  }

  bool _canFavorite(WeatherState state) {
    if (state is! WeatherLoaded) return false;
    final weather = state.currentWeather;
    return weather.latitude != null && weather.longitude != null;
  }

  void _toggleFavorite(BuildContext context, WeatherState state, bool isFav) {
    if (state is! WeatherLoaded) return;
    final weather = state.currentWeather;
    final favBloc = context.read<FavoritesBloc>();

    if (isFav) {
      favBloc.add(RemoveFavorite(weather.cityName));
    } else {
      favBloc.add(
        AddFavorite(
          cityName: weather.cityName,
          country: weather.country,
          latitude: weather.latitude!,
          longitude: weather.longitude!,
        ),
      );
    }
  }
}
