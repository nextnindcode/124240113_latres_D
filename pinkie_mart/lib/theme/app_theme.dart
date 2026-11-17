import 'package:flutter/material.dart';

class AppTheme {
  static const Color blush = Color(0xFFFFE5DE);
  static const Color cream = Color(0xFFFFEFD2);
  static const Color pinkSoft = Color(0xFFFBC9C0);
  static const Color pink = Color(0xFFF5A89A);
  static const Color pinkDeep = Color(0xFFE5738A);
  static const Color teal = Color(0xFF6AB0AF);
  static const Color yellow = Color(0xFFFFF2A5);
  static const Color ink = Color(0xFF4A2C2A);
  static const Color white = Color(0xFFFFFFFF);
  static const Color danger = Color(0xFFD9534F);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: blush,
      primaryColor: pink,

      colorScheme: ColorScheme.fromSeed(
        seedColor: pink,
        primary: pink,
        secondary: teal,
        surface: white,
        error: danger,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: pink,
        foregroundColor: ink,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: ink,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      cardTheme: CardThemeData(
        color: white,
        elevation: 2,
        shadowColor: ink.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: pinkSoft),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: pinkDeep, width: 2),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: pink,
          foregroundColor: ink,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ),

      snackBarTheme: const SnackBarThemeData(
        backgroundColor: ink,
        contentTextStyle: TextStyle(color: white),
        behavior: SnackBarBehavior.floating,
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: cream,
        selectedItemColor: pinkDeep,
        unselectedItemColor: ink,
        type: BottomNavigationBarType.fixed,
        elevation: 4,
      ),
    );
  }
}
