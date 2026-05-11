// ============================================================
// App Constants
// ============================================================
// This file holds all the constant values used across the app.
// Keeping constants in one place makes them easy to find, update,
// and prevents "magic numbers" scattered throughout the codebase.
// ============================================================

class AppConstants {
  // ── Private constructor ──
  // Prevents anyone from creating an instance of this class.
  // It's a container for static values only.
  AppConstants._();

  // ── App Info ──
  static const String appName = 'Tennis Swing Analyzer';
  static const String appVersion = '1.0.0';

  // ── Physics Constants ──
  // Default mass of a tennis racket in kilograms.
  // Users can adjust this later; this is just the starting value.
  static const double defaultRacketMassKg = 0.300; // 300 grams

  // ── Sensor Configuration ──
  // How often we read sensor data (in milliseconds).
  // 50 ms = 20 readings per second — a good balance between
  // accuracy and battery usage.
  static const int sensorIntervalMs = 50;

  // ── Swing Detection ──
  // Minimum acceleration (m/s²) to count as a real swing.
  // Below this threshold, movement is just idle hand tremor.
  // A gentle swing is ~5 m/s², a hard one is 15+ m/s².
  static const double swingDetectionThreshold = 5.0;

  // ── Mass Slider Range ──
  // Min and max values for the racket mass input slider (kg).
  static const double minRacketMassKg = 0.100; // 100 grams
  static const double maxRacketMassKg = 0.500; // 500 grams

  // ── UI Constants ──
  static const double defaultPadding = 16.0;
  static const double cardBorderRadius = 16.0;
  static const double iconSizeLarge = 48.0;
  static const double iconSizeMedium = 32.0;
}
