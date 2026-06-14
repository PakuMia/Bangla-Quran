import 'package:flutter/material.dart';

/// Central place for the app's "Islamic Green" branding.
class AppTheme {
  static const Color islamicGreen = Color(0xFF0E6B3A);
  static const Color islamicGreenDark = Color(0xFF09462A);
  static const Color islamicGreenLight = Color(0xFFE3F1E9);
  static const Color gold = Color(0xFFC9A227);

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: islamicGreen,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme.copyWith(primary: islamicGreen, secondary: gold),
      scaffoldBackgroundColor: const Color(0xFFF6FBF7),
      appBarTheme: const AppBarTheme(
        backgroundColor: islamicGreen,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: islamicGreen,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: islamicGreen),
      sliderTheme: SliderThemeData(
        activeTrackColor: islamicGreen,
        thumbColor: islamicGreen,
        inactiveTrackColor: islamicGreen.withValues(alpha: 0.15),
      ),
      iconTheme: const IconThemeData(color: islamicGreen),
      listTileTheme: const ListTileThemeData(iconColor: islamicGreen),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: islamicGreen,
        foregroundColor: Colors.white,
      ),
    );
  }
}
