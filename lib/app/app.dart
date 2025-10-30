import 'package:flutter/material.dart';
import '../features/weather/presentation/pages/weather_page.dart';

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Weather App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF2D5016), // main green color
          secondary: Color(0xFF90EE90), // light green
        ),
      ),

      home: const WeatherPage(),
    );
  }
}
