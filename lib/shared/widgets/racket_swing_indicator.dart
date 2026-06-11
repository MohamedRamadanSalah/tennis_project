import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';


class RacketSwingIndicator extends StatelessWidget {

  final double acceleration;


  final double rotationAngle;


  final bool swingDetected;

  const RacketSwingIndicator({
    super.key,
    required this.acceleration,
    required this.rotationAngle,
    required this.swingDetected,
  });

  @override
  Widget build(BuildContext context) {


    final double scale = (1.0 + (acceleration / 40.0)).clamp(1.0, 1.5);


    final double rotationRadians =
        (rotationAngle % 360).clamp(-45, 45) * (pi / 180);


    final Color glowColor =
        swingDetected ? AppTheme.accentColor : Colors.grey.shade300;
    final Color iconColor =
        swingDetected ? AppTheme.primaryColor : Colors.grey.shade500;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        shape: BoxShape.circle,

        boxShadow: [
          BoxShadow(
            color: glowColor.withValues(alpha: swingDetected ? 0.5 : 0.1),
            blurRadius: swingDetected ? 30 : 10,
            spreadRadius: swingDetected ? 8 : 0,
          ),
        ],
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: glowColor.withValues(alpha: 0.15),
          border: Border.all(
            color: glowColor.withValues(alpha: 0.4),
            width: 2,
          ),
        ),
        child: AnimatedScale(
          scale: scale,
          duration: const Duration(milliseconds: 100),
          child: AnimatedRotation(
            turns: rotationRadians / (2 * pi),
            duration: const Duration(milliseconds: 100),
            child: Icon(
              Icons.sports_tennis,
              size: 72,
              color: iconColor,
            ),
          ),
        ),
      ),
    );
  }
}
