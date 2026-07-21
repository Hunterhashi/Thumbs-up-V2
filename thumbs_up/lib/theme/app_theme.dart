import 'package:flutter/material.dart';

/// Brand color tokens for Thumbs Up.
///
/// These are derived from the app icon (warm yellow gradient + matte black
/// thumb) and the Speed Stream feedback colors (correct/incorrect input).
class AppColors {
  AppColors._();

  static const Color brandYellow = Color(0xFFF4C542);
  static const Color brandYellowTop = Color(0xFFFCD34D);
  static const Color matteBlack = Color(0xFF121214);
  static const Color canvasLight = Color(0xFFFAFAFA);
  static const Color canvasDark = Color(0xFF1C1C1E);

  static const Color correctEmerald = Color(0xFF10B981);
  static const Color typoCoral = Color(0xFFF43F5E);

  static const Color appleGray = Color(0xFF8E8E93);
  static const Color pureWhite = Color(0xFFFFFFFF);
}

/// App-wide [ThemeData] for Thumbs Up.
///
/// Style goal: minimalist, Apple-like — neutral surfaces, large rounded
/// corners, generous spacing, and the brand yellow reserved for accents.
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.canvasLight,
      primaryColor: AppColors.brandYellow,
      colorScheme: const ColorScheme.light(
        primary: AppColors.brandYellow,
        onPrimary: AppColors.matteBlack,
        secondary: AppColors.matteBlack,
        onSecondary: AppColors.canvasLight,
        surface: AppColors.canvasLight,
        onSurface: AppColors.matteBlack,
        error: AppColors.typoCoral,
        outline: AppColors.appleGray,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.w800,
          color: AppColors.matteBlack,
          letterSpacing: -1.2,
          height: 1.05,
        ),
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: AppColors.matteBlack,
          letterSpacing: -0.8,
        ),
        headlineMedium: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w700,
          color: AppColors.matteBlack,
          letterSpacing: -0.5,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.matteBlack,
        ),
        titleMedium: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: AppColors.matteBlack,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColors.appleGray,
          height: 1.45,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.appleGray,
          height: 1.4,
        ),
        labelLarge: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.matteBlack,
          letterSpacing: 0.2,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: AppColors.matteBlack,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.brandYellow,
          foregroundColor: AppColors.matteBlack,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.matteBlack,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.canvasDark,
      primaryColor: AppColors.brandYellow,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.brandYellow,
        onPrimary: AppColors.matteBlack,
        secondary: AppColors.pureWhite,
        onSecondary: AppColors.matteBlack,
        surface: AppColors.canvasDark,
        onSurface: AppColors.pureWhite,
        error: AppColors.typoCoral,
        outline: AppColors.appleGray,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.w800,
          color: AppColors.pureWhite,
          letterSpacing: -1.2,
          height: 1.05,
        ),
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: AppColors.pureWhite,
          letterSpacing: -0.8,
        ),
        headlineMedium: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w700,
          color: AppColors.pureWhite,
          letterSpacing: -0.5,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.pureWhite,
        ),
        titleMedium: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: AppColors.pureWhite,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColors.appleGray,
          height: 1.45,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.appleGray,
          height: 1.4,
        ),
        labelLarge: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.pureWhite,
          letterSpacing: 0.2,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: AppColors.pureWhite,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.brandYellow,
          foregroundColor: AppColors.matteBlack,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.pureWhite,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
