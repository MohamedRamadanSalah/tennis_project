import 'package:flutter/material.dart';

/// ============================================================
/// StatusBadge — Reusable Widget
/// ============================================================
/// A small, pill-shaped badge that shows the current recording
/// status (e.g., "Ready", "Recording", "Stopped").
///
/// Useful for giving the user a clear visual indicator of what
/// the app is currently doing.
/// ============================================================

class StatusBadge extends StatelessWidget {
  /// The text to display inside the badge.
  final String text;

  /// The background color of the badge.
  final Color color;

  /// The icon to show before the text (optional).
  final IconData? icon;

  const StatusBadge({
    super.key,
    required this.text,
    required this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
          ],
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
