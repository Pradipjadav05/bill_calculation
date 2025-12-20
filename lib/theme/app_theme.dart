import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,

      scaffoldBackgroundColor: const Color(0xFFF6F8FA),

      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF1E88E5), // Electricity Blue
        primary: const Color(0xFF1E88E5),
        secondary: const Color(0xFF43A047), // Water Green
        tertiary: const Color(0xFFFFA000), // Lightning Accent
        error: const Color(0xFFD32F2F),
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E88E5),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 2,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        margin: const EdgeInsets.symmetric(vertical: 6),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E88E5),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        labelStyle: const TextStyle(
          color: Color(0xFF546E7A),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),

      textTheme: const TextTheme(
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        bodyMedium: TextStyle(fontSize: 14),
        bodySmall: TextStyle(fontSize: 12),
      ),
    );
  }
}
