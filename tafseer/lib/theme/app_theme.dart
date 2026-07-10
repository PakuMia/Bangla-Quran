import 'package:flutter/material.dart';

const _teal = Color(0xFF2EC5B6);
const _tealDark = Color(0xFF1FA99C);

class AppTheme {
  static const teal = _teal;

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.dark(
          primary: _teal,
          secondary: _teal,
          surface: const Color(0xFF161b20),
          onSurface: const Color(0xFFDCE3E8),
        ),
        scaffoldBackgroundColor: const Color(0xFF101418),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0d1117),
          foregroundColor: Color(0xFFDCE3E8),
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: Color(0xFFDCE3E8),
            fontSize: 18,
            fontWeight: FontWeight.w300,
            letterSpacing: 0.5,
          ),
        ),
        dividerColor: const Color(0xFF1c2329),
        cardColor: const Color(0xFF161b20),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF161b20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF232b32)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF232b32)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _teal),
          ),
          hintStyle: const TextStyle(color: Color(0xFF5b6770)),
          prefixIconColor: const Color(0xFF5b6770),
        ),
        tabBarTheme: const TabBarThemeData(
          labelColor: _teal,
          unselectedLabelColor: Color(0xFF66747f),
          indicatorColor: _teal,
          dividerColor: Color(0xFF1c2329),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: _teal),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF66747f)),
      );

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.light(
          primary: _tealDark,
          secondary: _tealDark,
          surface: Colors.white,
          onSurface: const Color(0xFF1a1a1a),
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F7F8),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF1a1a1a),
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: Color(0xFF1a1a1a),
            fontSize: 18,
            fontWeight: FontWeight.w300,
            letterSpacing: 0.5,
          ),
          surfaceTintColor: Colors.transparent,
        ),
        dividerColor: const Color(0xFFE8EAED),
        cardColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _tealDark),
          ),
          hintStyle: const TextStyle(color: Color(0xFFAAAAAA)),
          prefixIconColor: const Color(0xFFAAAAAA),
        ),
        tabBarTheme: const TabBarThemeData(
          labelColor: _tealDark,
          unselectedLabelColor: Color(0xFF888888),
          indicatorColor: _tealDark,
          dividerColor: Color(0xFFE8EAED),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF888888)),
      );
}
