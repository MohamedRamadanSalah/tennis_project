import 'package:flutter/material.dart';

/// ============================================================
/// App Theme
/// ============================================================
/// This file defines the visual identity of the entire app.
///
/// WHY a dedicated theme file?
/// - Every screen automatically inherits these colors, fonts, and
///   shapes, so the UI stays consistent without repeating styles.
/// - To change the look-and-feel app-wide, you edit ONE file.
/// ============================================================

class AppTheme {
  AppTheme._();

  // ── Color Palette ──
  // We use a sporty green as the primary brand color.
  static const Color primaryColor = Color(0xFF2E7D32); // Forest green
  static const Color secondaryColor = Color(0xFF66BB6A); // Light green
  static const Color accentColor = Color(0xFFFFC107); // Amber / tennis ball
  static const Color backgroundColor = Color(0xFFF5F5F5); // Light grey
  static const Color surfaceColor = Colors.white;
  static const Color errorColor = Color(0xFFD32F2F);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);

  // ── The ThemeData object ──
  // Flutter's MaterialApp reads this to style every widget automatically.
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,

      // Color scheme derived from our palette
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        error: errorColor,
        brightness: Brightness.light,
      ),

      // Scaffold (background of every screen)
      scaffoldBackgroundColor: backgroundColor,

      // AppBar style
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white, // icon & text color
        elevation: 0,
        centerTitle: true,
      ),

      // Card style — used heavily for the data display cards
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: surfaceColor,
      ),

      // Elevated button style
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Text styles
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: textSecondary,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}
