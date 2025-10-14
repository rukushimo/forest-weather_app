// lib/features/weather/presentation/pages/forest_weather_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/dependency_injection/injection_container.dart' as di;
import '../../../../shared/widgets/error_widget.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../bloc/weather_bloc.dart';
import '../bloc/weather_event.dart';
import '../bloc/weather_state.dart';
import '../widgets/current_weather_card.dart';
import '../widgets/forecast_list.dart';

class ForestWeatherPage extends StatelessWidget {
  const ForestWeatherPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          di.sl<WeatherBloc>()..add(const GetWeatherForCurrentLocation()),
      child: const ForestWeatherView(),
    );
  }
}

class ForestWeatherView extends StatelessWidget {
  const ForestWeatherView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.forest, color: Color(0xFF90ee90)),
            SizedBox(width: 8),
            Text(
              'Forest Weather',
              style: TextStyle(
                color: Color(0xFFf5f5dc),
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.forest, color: Color(0xFF90ee90)),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              context.read<WeatherBloc>().add(const RefreshWeather());
            },
            icon: const Icon(Icons.refresh, color: Color(0xFF90ee90)),
            tooltip: 'Refresh Weather',
          ),
        ],
      ),

      // ✅ Replaced body with background + overlay
      body: Container(
        // Forest background image
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/forest_background.png'),
            fit: BoxFit.cover,
          ),
        ),
        // Dark gradient overlay
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withValues(alpha: 0.6)],
            ),
          ),
          // Weather content
          child: BlocBuilder<WeatherBloc, WeatherState>(
            builder: (context, state) {
              if (state is WeatherLoading) {
                return const LoadingWidget(message: 'Getting weather data...');
              } else if (state is WeatherLoaded) {
                return SafeArea(
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
                );
              } else if (state is WeatherError) {
                return ErrorDisplayWidget(
                  message: state.message,
                  onRetry: () {
                    context.read<WeatherBloc>().add(
                      const GetWeatherForCurrentLocation(),
                    );
                  },
                );
              }

              return const Center(
                child: Text(
                  'Welcome to Weather App!\nTap refresh to get started.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
