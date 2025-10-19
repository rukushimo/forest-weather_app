import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../shared/widgets/weather_background.dart';
import '../../../../shared/widgets/weather_icon.dart';
import '../../domain/entities/weather_entity.dart';

class HourlyForecastPage extends StatelessWidget {
  final DateTime date;
  final List<WeatherEntity> hourlyForecasts;
  final String cityName;

  const HourlyForecastPage({
    super.key,
    required this.date,
    required this.hourlyForecasts,
    required this.cityName,
  });

  @override
  Widget build(BuildContext context) {
    // Get main weather condition for background
    final mainWeather = hourlyForecasts.isNotEmpty
        ? hourlyForecasts.first.mainWeather
        : 'Clear';

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              cityName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              DateFormat('EEEE, MMMM d').format(date),
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ),
      body: WeatherBackground(
        weatherCondition: mainWeather,
        child: SafeArea(
          child: hourlyForecasts.isEmpty
              ? _buildEmptyState()
              : _buildHourlyList(),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.info_outline, size: 64, color: Colors.white70),
          SizedBox(height: 16),
          Text(
            'No hourly data available',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHourlyList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: hourlyForecasts.length,
      itemBuilder: (context, index) {
        final forecast = hourlyForecasts[index];
        return _buildHourlyCard(forecast, index == 0);
      },
    );
  }

  Widget _buildHourlyCard(WeatherEntity forecast, bool isFirst) {
    // ignore: unused_local_variable
    final time = DateFormat('HH:mm').format(forecast.dateTime);
    final hour = DateFormat('ha').format(forecast.dateTime);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isFirst
              ? Colors.white.withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.2),
          width: isFirst ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          // Time header
          Row(
            children: [
              Icon(
                Icons.access_time,
                color: Colors.white.withValues(alpha: 0.8),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                hour,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      offset: Offset(1, 1),
                      blurRadius: 3,
                      color: Colors.black87,
                    ),
                  ],
                ),
              ),
              if (isFirst) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Next',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 16),

          // Main content row
          Row(
            children: [
              // Weather icon and description
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    WeatherIcon(iconCode: forecast.icon, size: 60),
                    const SizedBox(height: 8),
                    Text(
                      forecast.description
                          .split(' ')
                          .map(
                            (word) => word[0].toUpperCase() + word.substring(1),
                          )
                          .join(' '),
                      textAlign: TextAlign.center,
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
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // Temperature
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '${forecast.temperature.round()}°',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 48,
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
                    Text(
                      'Feels ${forecast.feelsLike.round()}°',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 14,
                        shadows: const [
                          Shadow(
                            offset: Offset(1, 1),
                            blurRadius: 3,
                            color: Colors.black87,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // Additional details
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow(
                      Icons.water_drop,
                      'Humidity',
                      '${forecast.humidity}%',
                    ),
                    const SizedBox(height: 8),
                    _buildDetailRow(
                      Icons.air,
                      'Wind',
                      '${forecast.windSpeed.toStringAsFixed(1)} m/s',
                    ),
                    const SizedBox(height: 8),
                    _buildDetailRow(
                      Icons.compress,
                      'Pressure',
                      '${forecast.pressure} hPa',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white.withValues(alpha: 0.8), size: 16),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 11,
                  shadows: const [
                    Shadow(
                      offset: Offset(1, 1),
                      blurRadius: 2,
                      color: Colors.black87,
                    ),
                  ],
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
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
            ],
          ),
        ),
      ],
    );
  }
}
