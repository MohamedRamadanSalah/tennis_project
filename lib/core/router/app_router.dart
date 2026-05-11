import 'package:flutter/material.dart';
import '../../features/swing/presentation/screens/swing_screen.dart';

/// ============================================================
/// App Router
/// ============================================================
/// Centralizes all navigation routes in one place.
///
/// WHY a separate router file?
/// - As the app grows (e.g., adding a History screen or Settings),
///   you add routes here instead of scattering Navigator calls.
/// - It keeps main.dart clean and focused.
///
/// For this educational project we use Flutter's built-in named
/// routes. For production apps, consider go_router or auto_route.
/// ============================================================

class AppRouter {
  AppRouter._();

  // ── Route Names ──
  // Define route names as static constants to avoid typos.
  static const String swingScreen = '/';

  // ── Route Map ──
  // Maps each route name to the widget (screen) it should show.
  static Map<String, WidgetBuilder> get routes {
    return {
      swingScreen: (_) => const SwingScreen(),
      // Add future routes here, for example:
      // '/history': (_) => const HistoryScreen(),
      // '/settings': (_) => const SettingsScreen(),
    };
  }
}
