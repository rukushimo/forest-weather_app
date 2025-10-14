import 'package:flutter/material.dart';

class WeatherBackground extends StatelessWidget {
  final String weatherCondition;
  final Widget child;

  const WeatherBackground({
    super.key,
    required this.weatherCondition,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/forest_background.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.2),
              Colors.black.withValues(alpha: 0.3),
            ],
          ),
        ),
        child: child,
      ),
    );
  }
}
