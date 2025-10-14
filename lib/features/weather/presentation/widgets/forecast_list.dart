import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../shared/widgets/weather_icon.dart';
import '../../domain/entities/forecast_entity.dart';
import '../../domain/entities/weather_entity.dart';

class ForecastList extends StatelessWidget {
  final ForecastEntity forecast;

  const ForecastList({super.key, required this.forecast});

  @override
  Widget build(BuildContext context) {
    // Group forecasts by day
    final Map<String, WeatherEntity> dailyForecasts = {};

    for (final weather in forecast.forecasts) {
      final dayKey = DateFormat('yyyy-MM-dd').format(weather.dateTime);
      if (!dailyForecasts.containsKey(dayKey) && dailyForecasts.length < 5) {
        dailyForecasts[dayKey] = weather;
      }
    }

    final List<WeatherEntity> fiveDayForecast = dailyForecasts.values.toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 8, bottom: 16),
            child: Text(
              '5-Day Forecast',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    offset: Offset(2, 2),
                    blurRadius: 6,
                    color: Colors.black87,
                  ),
                ],
              ),
            ),
          ),
          ...fiveDayForecast.map(
            (weather) => _buildForecastItem(context, weather),
          ),
        ],
      ),
    );
  }

  Widget _buildForecastItem(BuildContext context, WeatherEntity weather) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // Semi-transparent background so text is readable
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Day
          Expanded(
            flex: 2,
            child: Text(
              DateFormat('EEE, MMM d').format(weather.dateTime),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                shadows: [
                  Shadow(
                    offset: Offset(1, 1),
                    blurRadius: 3,
                    color: Colors.black87,
                  ),
                ],
              ),
            ),
          ),

          // Weather icon
          WeatherIcon(iconCode: weather.icon, size: 40),

          const SizedBox(width: 16),

          // Weather description
          Expanded(
            flex: 3,
            child: Text(
              weather.description
                  .split(' ')
                  .map((word) => word[0].toUpperCase() + word.substring(1))
                  .join(' '),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                shadows: [
                  Shadow(
                    offset: Offset(1, 1),
                    blurRadius: 3,
                    color: Colors.black87,
                  ),
                ],
              ),
            ),
          ),

          // Temperature
          Text(
            '${weather.temperature.round()}°',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
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
      ),
    );
  }
}
