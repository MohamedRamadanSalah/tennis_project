import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/constants/app_constants.dart';
import 'features/swing/logic/swing_cubit.dart';
import 'features/swing/services/sensor_service.dart';

/// ============================================================
/// main.dart — Application Entry Point
/// ============================================================
/// This is the first file Flutter executes when the app launches.
///
/// WHAT HAPPENS HERE:
///   1. Flutter engine is initialized (WidgetsFlutterBinding).
///   2. We lock the screen to portrait mode (since we're
///      simulating holding a tennis racket upright).
///   3. We create the root widget tree:
///        MaterialApp
///          └─ BlocProvider (creates & provides the SwingCubit)
///              └─ SwingScreen (the main UI)
/// ============================================================

void main() {
  // Ensure Flutter is initialized before calling platform code
  WidgetsFlutterBinding.ensureInitialized();

  // Lock the app to portrait mode — makes sense for a tennis
  // swing app where the user holds the phone like a racket.
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(const TennisSwingAnalyzerApp());
}

/// The root widget of the application.
class TennisSwingAnalyzerApp extends StatelessWidget {
  const TennisSwingAnalyzerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return
        // ── BlocProvider ──
        // Creates the SwingCubit and makes it available to every
        // widget in the tree below. This is how dependency injection
        // works with flutter_bloc.
        BlocProvider(
      // `create` is called once when the provider is first built.
      // We instantiate the SensorService here and inject it into
      // the Cubit — this keeps both classes loosely coupled.
      create: (_) => SwingCubit(
        sensorService: SensorService(),
      ),

      child: MaterialApp(
        // ── App Identity ──
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,

        // ── Theme ──
        // Our custom theme defined in app_theme.dart
        theme: AppTheme.lightTheme,

        // ── Routing ──
        // Initial route and route map from our router file
        initialRoute: AppRouter.swingScreen,
        routes: AppRouter.routes,
      ),
    );
  }
}
