import 'package:flutter/material.dart';

class AppTheme {
  static const Color green = Color(0xFF22C55E);
  static const Color cream = Color(0xFFFEF3C7);
  static const Color brown = Color(0xFF78350F);

  static ThemeData get theme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: green,
      primary: green,
      secondary: brown,
      background: Colors.white,
      surface: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: brown,
        foregroundColor: Colors.white,
      ),
    );
  }
}