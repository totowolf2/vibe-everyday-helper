import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData? _cachedLightTheme;

  /// Get cached light theme for improved performance
  static ThemeData get cachedLightTheme {
    _cachedLightTheme ??= _buildLightTheme();
    return _cachedLightTheme!;
  }

  /// Get light theme (creates new instance each time)
  static ThemeData get lightTheme => _buildLightTheme();

  /// Build the light theme configuration
  static ThemeData _buildLightTheme() {
    final primaryColor = Colors.blue[700]!;

    return ThemeData(
      primarySwatch: Colors.blue,
      primaryColor: primaryColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.light,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(8),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      fontFamily: 'Roboto',
    );
  }

  /// Clear theme cache (useful for testing or theme switching)
  static void clearCache() {
    _cachedLightTheme = null;
  }

  /// Check if theme is cached
  static bool get isThemeCached => _cachedLightTheme != null;
}
