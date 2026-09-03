import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryLight = Color(0xFF4F46E5);
  static const Color primaryDark = Color(0xFF6366F1);

  static ThemeData get lightTheme => _createTheme(
        brightness: Brightness.light,
        primary: primaryLight,
        bg: const Color(0xFFF8FAFC),
        surface: Colors.white,
        border: const Color(0xFFE2E8F0),
        appBarForeground: const Color(0xFF0F172A),
      );

  static ThemeData get darkTheme => _createTheme(
        brightness: Brightness.dark,
        primary: primaryDark,
        bg: const Color(0xFF0B0F19),
        surface: const Color(0xFF1E293B),
        border: const Color(0xFF334155),
        appBarForeground: const Color(0xFFF8FAFC),
      );

  static ThemeData _createTheme({
    required Brightness brightness,
    required Color primary,
    required Color bg,
    required Color surface,
    required Color border,
    required Color appBarForeground,
  }) {
    return ThemeData(
      brightness: brightness,
      fontFamily: 'Inter',
      scaffoldBackgroundColor: bg,
      primaryColor: primary,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: brightness,
        primary: primary,
        surface: surface,
        outline: border,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: appBarForeground,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: border, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}

