// lib/features/weather/presentation/widgets/forest_current_weather_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../shared/widgets/forest_weather_icon.dart';
import '../../domain/entities/weather_entity.dart';

class ForestCurrentWeatherCard extends StatelessWidget {
  final WeatherEntity weather;

  const ForestCurrentWeatherCard({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF2d5016).withValues(alpha: 0.9),
              const Color(0xFF1a3409).withValues(alpha: 0.9),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Location with leaf decoration
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.eco, color: Color(0xFF90ee90), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '${weather.cityName}, ${weather.country}',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: const Color(0xFFf5f5dc),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.eco, color: Color(0xFF90ee90), size: 20),
                ],
              ),
              const SizedBox(height: 8),

              // Date
              Text(
                DateFormat('EEEE, MMMM dd').format(weather.dateTime),
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: const Color(0xFFc8c8a0)),
              ),
              const SizedBox(height: 24),

              // Weather icon and temperature
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ForestWeatherIcon(iconCode: weather.icon, size: 100),
                  const SizedBox(width: 24),
                  Text(
                    '${weather.temperature.round()}°C',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontSize: 56,
                      color: const Color(0xFFf5f5dc),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Weather description
              Text(
                weather.description
                    .split(' ')
                    .map((word) => word[0].toUpperCase() + word.substring(1))
                    .join(' '),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: const Color(0xFF90ee90),
                  fontSize: 20,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Weather details with forest styling
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF90ee90).withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildDetailItem(
                      context,
                      Icons.thermostat,
                      'Feels like',
                      '${weather.feelsLike.round()}°C',
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: const Color(0xFF90ee90).withValues(alpha: 0.3),
                    ),
                    _buildDetailItem(
                      context,
                      Icons.water_drop,
                      'Humidity',
                      '${weather.humidity}%',
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: const Color(0xFF90ee90).withValues(alpha: 0.3),
                    ),
                    _buildDetailItem(
                      context,
                      Icons.air,
                      'Wind',
                      '${weather.windSpeed.toStringAsFixed(1)} m/s',
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

  Widget _buildDetailItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF90ee90), size: 28),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: const Color(0xFFc8c8a0),
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: const Color(0xFFf5f5dc),
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}
