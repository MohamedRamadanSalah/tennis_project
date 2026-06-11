import 'package:flutter/material.dart';
import '../../features/swing/presentation/screens/swing_screen.dart';


class AppRouter {
  AppRouter._();


  static const String swingScreen = '/';


  static Map<String, WidgetBuilder> get routes {
    return {
      swingScreen: (_) => const SwingScreen(),


    };
  }
}
