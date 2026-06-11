import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';


class SwingResultCard extends StatelessWidget {

  final double maxAcceleration;


  final double maxForce;


  final double totalRotation;


  final double racketMass;

  const SwingResultCard({
    super.key,
    required this.maxAcceleration,
    required this.maxForce,
    required this.totalRotation,
    required this.racketMass,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        side: BorderSide(color: AppTheme.primaryColor.withValues(alpha: 0.3), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.emoji_events,
                    color: AppTheme.accentColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Swing Results',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),


            _buildResultRow(
              context,
              icon: Icons.speed,
              label: 'Peak Acceleration',
              value: '${maxAcceleration.toStringAsFixed(2)} m/s²',
              color: AppTheme.primaryColor,
            ),
            const SizedBox(height: 12),

            _buildResultRow(
              context,
              icon: Icons.fitness_center,
              label: 'Peak Force (F = m × a)',
              value: '${maxForce.toStringAsFixed(2)} N',
              color: AppTheme.accentColor,
            ),
            const SizedBox(height: 12),

            _buildResultRow(
              context,
              icon: Icons.rotate_right,
              label: 'Total Rotation',
              value: '${totalRotation.toStringAsFixed(1)}°',
              color: AppTheme.secondaryColor,
            ),
            const SizedBox(height: 12),

            _buildResultRow(
              context,
              icon: Icons.sports_tennis,
              label: 'Racket Mass',
              value: '${racketMass.toStringAsFixed(3)} kg',
              color: AppTheme.textSecondary,
            ),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),


            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calculate, color: AppTheme.textSecondary, size: 20),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'F = m × a = ${racketMass.toStringAsFixed(3)} × '
                      '${maxAcceleration.toStringAsFixed(2)} = '
                      '${maxForce.toStringAsFixed(2)} N',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontFamily: 'monospace',
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildResultRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
              ),
        ),
      ],
    );
  }
}
