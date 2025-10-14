import 'package:flutter/material.dart';

class ForestWeatherBackground extends StatelessWidget {
  final String weatherCondition;
  final Widget child;

  const ForestWeatherBackground({
    super.key,
    required this.weatherCondition,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(_getBackgroundImage(weatherCondition)),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withValues(alpha: 0.3),
            BlendMode.darken,
          ),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black.withValues(alpha: 0.4)],
          ),
        ),
        child: child,
      ),
    );
  }

  String _getBackgroundImage(String condition) {
    // Map weather conditions to available forest backgrounds
    switch (condition.toLowerCase()) {
      case 'clear':
        return 'assets/images/forest_sunny.png';
      case 'clouds':
        return 'assets/images/forest_sunny.png';
      case 'rain':
      case 'drizzle':
        return 'assets/images/forest_sunny.png';
      default:
        return 'assets/images/forest_sunny.png';
    }
  }
}
