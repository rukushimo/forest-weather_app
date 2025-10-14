import 'package:flutter/material.dart';

class ForestTheme {
  // Forest Color Palette
  static const Color forestGreen = Color(0xFF2d5016);
  static const Color darkForestGreen = Color(0xFF1a3409);
  static const Color leafGreen = Color(0xFF90ee90);
  static const Color earthBrown = Color(0xFF8b4513);
  static const Color lightBrown = Color(0xFFd2691e);
  static const Color cream = Color(0xFFf5f5dc);
  static const Color darkBrown = Color(0xFF654321);

  // Text Colors
  static const Color primaryText = Color(0xFFf5f5dc);
  static const Color secondaryText = Color(0xFFc8c8a0);

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      colorScheme: const ColorScheme.dark(
        primary: forestGreen,
        secondary: leafGreen,
        surface: darkForestGreen,
        error: Colors.redAccent,
        onPrimary: cream,
        onSecondary: darkForestGreen,
        onSurface: cream,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: cream,
        elevation: 0,
        centerTitle: true,
      ),

      cardTheme: CardThemeData(
        color: darkForestGreen.withValues(alpha: .8),
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),

      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.bold,
          color: cream,
          shadows: [
            Shadow(offset: Offset(2, 2), blurRadius: 4, color: Colors.black45),
          ],
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: cream,
        ),
        bodyLarge: TextStyle(fontSize: 16, color: cream),
        bodyMedium: TextStyle(fontSize: 14, color: secondaryText),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: forestGreen,
          foregroundColor: cream,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      iconTheme: const IconThemeData(color: leafGreen, size: 24),
    );
  }
}
