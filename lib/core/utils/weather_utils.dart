import '../constants/app_constants.dart';

class WeatherUtils {
  /// Get background image path based on weather condition
  static String getBackgroundImage(String weatherCondition, bool isDaytime) {
    if (!isDaytime) {
      return AppConstants.nightBackground;
    }

    switch (weatherCondition.toLowerCase()) {
      case 'clear':
        return AppConstants.sunnyBackground;
      case 'clouds':
        return AppConstants.cloudyBackground;
      case 'rain':
      case 'drizzle':
        return AppConstants.rainyBackground;
      default:
        return AppConstants.defaultBackground;
    }
  }

  /// Check if it's daytime based on current time and sunrise/sunset
  static bool isDaytime() {
    final now = DateTime.now();
    final hour = now.hour;
    // Simple logic: 6 AM to 6 PM is considered daytime
    return hour >= 6 && hour < 18;
  }

  /// Get weather icon URL
  static String getWeatherIconUrl(String iconCode) {
    return '${AppConstants.iconBaseUrl}$iconCode@2x.png';
  }

  /// Convert temperature if needed
  static double convertTemperature(double celsius, String unit) {
    switch (unit.toLowerCase()) {
      case 'fahrenheit':
      case 'f':
        return (celsius * 9 / 5) + 32;
      case 'kelvin':
      case 'k':
        return celsius + 273.15;
      default:
        return celsius;
    }
  }

  /// Format date for display
  static String formatDate(DateTime date) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${days[date.weekday - 1]}, ${date.day} ${months[date.month - 1]}';
  }

  /// Get wind direction from degrees
  static String getWindDirection(double degrees) {
    const directions = [
      'N',
      'NNE',
      'NE',
      'ENE',
      'E',
      'ESE',
      'SE',
      'SSE',
      'S',
      'SSW',
      'SW',
      'WSW',
      'W',
      'WNW',
      'NW',
      'NNW',
    ];

    final index = ((degrees / 22.5) + 0.5).floor() % 16;
    return directions[index];
  }
}
