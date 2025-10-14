import 'package:flutter/material.dart';

class AppTheme {
  static const Color errorColor = Color(0xFFCF6679);

  //  Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      primary: Colors.blue,
      secondary: Colors.teal,
      surface: Colors.white,
      error: errorColor,
    ),
  );

  //  Dark Theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.dark(
      primary: Colors.blue,
      secondary: Colors.teal,
      surface: Color(0xFF1E1E1E),
      error: errorColor,
    ),
  );

  // 🌲 Forest Theme
  static ThemeData forestTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.light(
      primary: Colors.green.shade800,
      secondary: Colors.greenAccent.shade400,
      surface: Colors.green.shade50,
      error: errorColor,
    ),
    scaffoldBackgroundColor: Colors.green.shade50,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.green.shade700,
      foregroundColor: Colors.white,
    ),
  );

  //  Sea Theme
  static ThemeData seaTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.light(
      primary: Colors.blue.shade800,
      secondary: Colors.tealAccent.shade400,
      surface: Colors.blue.shade50,
      error: errorColor,
    ),
    scaffoldBackgroundColor: Colors.blue.shade50,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.blue.shade600,
      foregroundColor: Colors.white,
    ),
  );
}
