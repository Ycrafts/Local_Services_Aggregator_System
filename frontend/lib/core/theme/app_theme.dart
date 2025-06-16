import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF2196F3);
  static const Color secondaryColor = Color(0xFF03A9F4);
  static const Color accentColor = Color(0xFF42A5F5);
  static const Color errorColor = Color(0xFFE57373);
  static const Color successColor = Color(0xFF81C784);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color textColor = Color(0xFF212121);
  static const Color textLightColor = Color(0xFF757575);
  static const Color searchBarFillColor = Color(0xFFF5F5F5);
  static const Color cardBackgroundColor = Colors.white;
  static const Color shadowColor = Color(0xFFE0E0E0);

  // Specific colors for popular service cards (example brand colors)
  static const Color smartHomePrimaryColor = Color(0xFFFB3B67);
  static const Color smartHomeBackgroundColor = Color(0xFFFB3B67);
  static const Color paintingPrimaryColor = Color(0xFF336CFF);
  static const Color paintingBackgroundColor = Color(0xFF336CFF);
  static const Color repairPrimaryColor = Colors.orangeAccent;
  static const Color repairBackgroundColor = Colors.orangeAccent;

  // Specific colors for category service cards (example brand colors)
  static const Color electricianPrimaryColor = Colors.orange;
  static const Color cleanerPrimaryColor = Colors.lightBlue;
  static const Color plumberPrimaryColor = Colors.blue;
  static const Color housekeeperPrimaryColor = Colors.pink;

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        error: errorColor,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: textColor),
        titleTextStyle: TextStyle(
          color: textColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: searchBarFillColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: primaryColor),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: errorColor),
        ),
        labelStyle: const TextStyle(color: textLightColor),
        hintStyle: const TextStyle(color: textLightColor),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: cardBackgroundColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: textLightColor,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        elevation: 10,
      ),
    );
  }
} 