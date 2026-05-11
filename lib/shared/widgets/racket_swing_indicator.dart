import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// ============================================================
/// RacketSwingIndicator — Animated Widget
/// ============================================================
/// A visual tennis racket that reacts to sensor data, giving
/// the "Wii-like" experience the assignment requires.
///
/// WHAT IT DOES:
/// - Rotates based on the rotation angle from the gyroscope
/// - Scales up when acceleration increases (bigger = harder swing)
/// - Glows green when a swing is detected (above threshold)
/// - Stays grey when idle
///
/// This widget is StatelessWidget — all animation is driven by
/// the values passed in, which change every 50ms from the Cubit.
/// ============================================================

class RacketSwingIndicator extends StatelessWidget {
  /// Current acceleration — controls the size/intensity of the visual.
  final double acceleration;

  /// Current rotation angle (degrees) — rotates the racket icon.
  final double rotationAngle;

  /// Whether acceleration is above the swing threshold.
  final bool swingDetected;

  const RacketSwingIndicator({
    super.key,
    required this.acceleration,
    required this.rotationAngle,
    required this.swingDetected,
  });

  @override
  Widget build(BuildContext context) {
    // ── Scale calculation ──
    // Map acceleration (0–20+ m/s²) to a scale factor (1.0–1.5).
    // clamp ensures we never go below 1.0 or above 1.5.
    final double scale = (1.0 + (acceleration / 40.0)).clamp(1.0, 1.5);

    // ── Rotation calculation ──
    // Convert degrees to radians. We use modulo 360 to keep it
    // within one full rotation, and limit the visual rotation
    // to ±45 degrees so the icon doesn't spin wildly.
    final double rotationRadians =
        (rotationAngle % 360).clamp(-45, 45) * (pi / 180);

    // ── Color based on swing state ──
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
        // Glow effect — the shadow spreads wider when swinging
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
