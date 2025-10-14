import 'package:flutter/material.dart';

class ForestWeatherIcon extends StatelessWidget {
  final String iconCode;
  final double size;

  const ForestWeatherIcon({super.key, required this.iconCode, this.size = 64});

  @override
  Widget build(BuildContext context) {
    final String iconPath = _getForestIconPath(iconCode);

    return Image.asset(
      iconPath,
      width: size,
      height: size,
      errorBuilder: (context, error, stackTrace) {
        // Fallback to a default icon if custom icon not found
        return Icon(
          _getWeatherIconFallback(iconCode),
          size: size,
          color: const Color(0xFF90ee90),
        );
      },
    );
  }

  String _getForestIconPath(String iconCode) {
    // Map OpenWeatherMap icon codes to your forest icons
    // Check what your icon files are actually named!

    // Common mappings (adjust based on your actual file names):
    if (iconCode.startsWith('01')) {
      // Clear sky
      return 'assets/icons/sunny.png'; // or whatever it's named
    } else if (iconCode.startsWith('02')) {
      // Few clouds
      return 'assets/icons/partly_cloudy.png';
    } else if (iconCode.startsWith('03') || iconCode.startsWith('04')) {
      // Clouds
      return 'assets/icons/cloudy.png';
    } else if (iconCode.startsWith('09') || iconCode.startsWith('10')) {
      // Rain
      return 'assets/icons/rainy.png';
    } else if (iconCode.startsWith('11')) {
      // Thunderstorm
      return 'assets/icons/thunderstorm.png';
    } else if (iconCode.startsWith('13')) {
      // Snow
      return 'assets/icons/snowy.png';
    } else if (iconCode.startsWith('50')) {
      // Mist
      return 'assets/icons/misty.png';
    }

    return 'assets/icons/default.png';
  }

  IconData _getWeatherIconFallback(String iconCode) {
    if (iconCode.startsWith('01')) return Icons.wb_sunny;
    if (iconCode.startsWith('02')) return Icons.wb_cloudy;
    if (iconCode.startsWith('03')) return Icons.cloud;
    if (iconCode.startsWith('04')) return Icons.cloud;
    if (iconCode.startsWith('09')) return Icons.water_drop;
    if (iconCode.startsWith('10')) return Icons.beach_access;
    if (iconCode.startsWith('11')) return Icons.thunderstorm;
    if (iconCode.startsWith('13')) return Icons.ac_unit;
    if (iconCode.startsWith('50')) return Icons.blur_on;
    return Icons.wb_sunny;
  }
}
