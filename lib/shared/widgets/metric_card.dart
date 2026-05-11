import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';

/// ============================================================
/// MetricCard — Reusable Widget
/// ============================================================
/// Displays a single metric (acceleration, force, or rotation)
/// in a clean card format with an icon, label, and value.
///
/// WHY a reusable widget?
/// - The Swing screen shows 3 nearly identical cards. Instead of
///   copy-pasting card code 3 times, we build it once and reuse it.
/// - If we want to change the card design, we update ONE file.
/// ============================================================

class MetricCard extends StatelessWidget {
  /// The icon to show at the top of the card.
  final IconData icon;

  /// The color used for the icon and accent elements.
  final Color color;

  /// The label text (e.g., "Acceleration").
  final String label;

  /// The numeric value to display (e.g., "12.34").
  final String value;

  /// The unit of measurement (e.g., "m/s²").
  final String unit;

  const MetricCard({
    super.key,
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      // Card shape & elevation come from the theme, but we add
      // a subtle colored left border for visual distinction.
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        side: BorderSide(color: color.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Icon + Label Row ──
            Row(
              children: [
                // Circular icon container with tinted background
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ── Value + Unit ──
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Large value text
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(width: 6),
                // Smaller unit text, aligned to the baseline
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    unit,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: color.withValues(alpha: 0.7),
                        ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
