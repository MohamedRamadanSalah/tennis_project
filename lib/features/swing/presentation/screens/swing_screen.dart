import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/metric_card.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../../shared/widgets/racket_swing_indicator.dart';
import '../../../../shared/widgets/swing_result_card.dart';
import '../../logic/swing_cubit.dart';
import '../../logic/swing_state.dart';
import '../../models/swing_data.dart';


class SwingScreen extends StatelessWidget {
  const SwingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: const Text(AppConstants.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'About this app',
            onPressed: () => _showAboutDialog(context),
          ),
        ],
      ),


      body: BlocBuilder<SwingCubit, SwingState>(
        builder: (context, state) {

          final SwingData data = switch (state) {
            SwingInitial() => SwingData.empty(),
            SwingRecording(:final data) => data,
            SwingStopped(:final data) => data,
          };

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                children: [

                  _buildStatusBadge(state),

                  const SizedBox(height: 16),


                  Expanded(
                    child: ListView(
                      children: [


                        Center(
                          child: RacketSwingIndicator(
                            acceleration: data.acceleration,
                            rotationAngle: data.rotationAngle,
                            swingDetected: data.swingDetected,
                          ),
                        ),

                        const SizedBox(height: 8),


                        Center(
                          child: AnimatedOpacity(
                            opacity: data.swingDetected ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 200),
                            child: const Text(
                              '🎾 Swing Detected!',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),


                        if (state is SwingStopped) ...[
                          SwingResultCard(
                            maxAcceleration: data.maxAcceleration,
                            maxForce: data.maxForce,
                            totalRotation: data.rotationAngle,
                            racketMass: context.read<SwingCubit>().currentMass,
                          ),
                          const SizedBox(height: 16),
                        ],


                        MetricCard(
                          icon: Icons.speed,
                          color: AppTheme.primaryColor,
                          label: 'Acceleration',
                          value: data.acceleration.toStringAsFixed(2),
                          unit: 'm/s²',
                        ),
                        const SizedBox(height: 10),

                        MetricCard(
                          icon: Icons.fitness_center,
                          color: AppTheme.accentColor,
                          label: 'Force (F = m × a)',
                          value: data.force.toStringAsFixed(2),
                          unit: 'N',
                        ),
                        const SizedBox(height: 10),

                        MetricCard(
                          icon: Icons.rotate_right,
                          color: AppTheme.secondaryColor,
                          label: 'Rotation Angle',
                          value: data.rotationAngle.toStringAsFixed(1),
                          unit: '°',
                        ),
                        const SizedBox(height: 10),


                        if (state is SwingRecording || state is SwingStopped)
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppConstants.cardBorderRadius,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(
                                AppConstants.defaultPadding,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Peak Values',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.arrow_upward,
                                          size: 16, color: AppTheme.primaryColor),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          'Max Accel: ${data.maxAcceleration.toStringAsFixed(2)} m/s²',
                                          style: Theme.of(context).textTheme.bodyMedium,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(Icons.arrow_upward,
                                          size: 16, color: AppTheme.accentColor),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          'Max Force: ${data.maxForce.toStringAsFixed(2)} N',
                                          style: Theme.of(context).textTheme.bodyMedium,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                        const SizedBox(height: 10),


                        _buildMassSlider(context),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),


                  _buildActionButtons(context, state),
                ],
              ),
            ),
          );
        },
      ),
    );
  }


  Widget _buildStatusBadge(SwingState state) {
    return switch (state) {
      SwingInitial() => const StatusBadge(
          text: 'Ready — Hold phone like a racket',
          color: Colors.blue,
          icon: Icons.radio_button_unchecked,
        ),
      SwingRecording() => const StatusBadge(
          text: 'Recording — Swing now!',
          color: Colors.red,
          icon: Icons.fiber_manual_record,
        ),
      SwingStopped() => const StatusBadge(
          text: 'Stopped — Results below',
          color: Colors.orange,
          icon: Icons.stop_circle_outlined,
        ),
    };
  }


  Widget _buildMassSlider(BuildContext context) {
    final cubit = context.read<SwingCubit>();

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.sports_tennis, color: AppTheme.textSecondary),
                const SizedBox(width: 8),
                Text(
                  'Racket Mass',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const Spacer(),
                Text(
                  '${cubit.currentMass.toStringAsFixed(3)} kg',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryColor,
                      ),
                ),
              ],
            ),
            Slider(
              value: cubit.currentMass,
              min: AppConstants.minRacketMassKg,
              max: AppConstants.maxRacketMassKg,
              divisions: 40,
              activeColor: AppTheme.primaryColor,
              label: '${(cubit.currentMass * 1000).round()} g',
              onChanged: (value) {
                cubit.updateMass(value);
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${(AppConstants.minRacketMassKg * 1000).round()}g',
                    style: Theme.of(context).textTheme.bodyMedium),
                Text('${(AppConstants.maxRacketMassKg * 1000).round()}g',
                    style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildActionButtons(BuildContext context, SwingState state) {
    final cubit = context.read<SwingCubit>();

    return switch (state) {
      SwingInitial() => SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: cubit.startRecording,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Start Recording'),
          ),
        ),
      SwingRecording() => SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: cubit.stopRecording,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            icon: const Icon(Icons.stop),
            label: const Text('Stop Recording'),
          ),
        ),
      SwingStopped() => SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: cubit.reset,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.secondaryColor,
            ),
            icon: const Icon(Icons.refresh),
            label: const Text('New Swing'),
          ),
        ),
    };
  }


  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(AppConstants.appName),
        content: const Text(
          'This app uses your phone\'s accelerometer and gyroscope '
          'to simulate a tennis racket — like Wii games!\n\n'
          'Hold your phone and swing it. The app calculates:\n'
          '• Acceleration (from the accelerometer)\n'
          '• Force using F = m × a (Newton\'s Second Law)\n'
          '• Rotation angle (from the gyroscope)\n\n'
          'Adjust the racket mass with the slider to see how '
          'it affects the force calculation.\n\n'
          'Everything runs offline — no internet needed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}
