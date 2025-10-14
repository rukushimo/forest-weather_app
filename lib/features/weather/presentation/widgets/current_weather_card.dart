import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../shared/widgets/weather_icon.dart';
import '../../domain/entities/weather_entity.dart';

class CurrentWeatherCard extends StatelessWidget {
  final WeatherEntity weather;

  const CurrentWeatherCard({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Location with forest decoration
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_on, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                '${weather.cityName}, ${weather.country}',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      offset: Offset(2, 2),
                      blurRadius: 8,
                      color: Colors.black87,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Date
          Text(
            DateFormat('EEEE, MMMM dd').format(weather.dateTime),
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              shadows: [
                Shadow(
                  offset: Offset(1, 1),
                  blurRadius: 4,
                  color: Colors.black87,
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),

          // Weather icon and temperature - BIG and BOLD
          WeatherIcon(iconCode: weather.icon, size: 120),
          const SizedBox(height: 16),

          Text(
            '${weather.temperature.round()}°',
            style: const TextStyle(
              fontSize: 96,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1,
              shadows: [
                Shadow(
                  offset: Offset(3, 3),
                  blurRadius: 12,
                  color: Colors.black87,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Weather description
          Text(
            weather.description
                .split(' ')
                .map((word) => word[0].toUpperCase() + word.substring(1))
                .join(' '),
            style: const TextStyle(
              fontSize: 24,
              color: Colors.white,
              fontWeight: FontWeight.w500,
              shadows: [
                Shadow(
                  offset: Offset(2, 2),
                  blurRadius: 6,
                  color: Colors.black87,
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),

          // Weather details - no box, just text
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildDetailItem(
                context,
                Icons.thermostat,
                'Feels like',
                '${weather.feelsLike.round()}°C',
              ),
              _buildDetailItem(
                context,
                Icons.water_drop,
                'Humidity',
                '${weather.humidity}%',
              ),
              _buildDetailItem(
                context,
                Icons.air,
                'Wind',
                '${weather.windSpeed.toStringAsFixed(1)} m/s',
              ),
            ],
          ),
        ],
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
        Icon(
          icon,
          color: Colors.white,
          size: 32,
          shadows: const [
            Shadow(offset: Offset(2, 2), blurRadius: 4, color: Colors.black87),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white70,
            shadows: [
              Shadow(
                offset: Offset(1, 1),
                blurRadius: 3,
                color: Colors.black87,
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(
                offset: Offset(2, 2),
                blurRadius: 4,
                color: Colors.black87,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
