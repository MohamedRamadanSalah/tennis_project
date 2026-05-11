import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/swing_data.dart';
import '../services/sensor_service.dart';
import 'swing_state.dart';

/// ============================================================
/// SwingCubit
/// ============================================================
/// The "brain" of the Swing feature. It sits between the UI and
/// the SensorService and controls the flow of data.
///
/// WHAT IS A CUBIT?
/// - A Cubit is a simplified version of a Bloc.
/// - Instead of receiving Events (like Bloc), you call methods
///   directly: startRecording(), stopRecording(), reset().
/// - It emits States that the UI listens to and rebuilds from.
///
/// DATA FLOW:
///   Phone Sensors → SensorService → SwingCubit → UI
/// ============================================================

class SwingCubit extends Cubit<SwingState> {
  /// The service that reads from hardware sensors.
  final SensorService _sensorService;

  /// Subscription to the sensor data stream.
  StreamSubscription<SwingData>? _subscription;

  /// Tracks whether we already triggered haptic for the current swing.
  /// We reset this on each new recording so the user gets ONE vibration
  /// per swing, not continuous buzzing.
  bool _hapticTriggered = false;

  /// Constructor — receives a SensorService via dependency injection.
  SwingCubit({required SensorService sensorService})
      : _sensorService = sensorService,
        super(const SwingInitial());

  // ── Public Methods (called by the UI) ──

  /// Starts recording sensor data.
  void startRecording() {
    // Reset haptic flag for the new recording session
    _hapticTriggered = false;

    // 1. Tell the service to begin reading sensors
    _sensorService.startListening();

    // 2. Listen to the stream of SwingData and emit new states
    _subscription = _sensorService.swingDataStream.listen((swingData) {
      // Trigger haptic feedback ONCE when a swing is first detected.
      // This gives the "Wii-like" tactile feel — you feel a buzz
      // when your swing is strong enough to register.
      if (swingData.swingDetected && !_hapticTriggered) {
        HapticFeedback.heavyImpact();
        _hapticTriggered = true;
      }

      // If swing ended (below threshold), allow haptic to fire
      // again on the next swing within the same session.
      if (!swingData.swingDetected) {
        _hapticTriggered = false;
      }

      emit(SwingRecording(data: swingData));
    });
  }

  /// Stops recording and freezes the display.
  void stopRecording() {
    _subscription?.cancel();
    _sensorService.stopListening();

    final currentState = state;
    if (currentState is SwingRecording) {
      emit(SwingStopped(data: currentState.data));
    }
  }

  /// Updates the racket mass (called when the user moves the slider).
  void updateMass(double massKg) {
    _sensorService.setRacketMass(massKg);
  }

  /// Returns the current racket mass value for the slider.
  double get currentMass => _sensorService.racketMass;

  /// Resets everything back to the beginning.
  void reset() {
    _subscription?.cancel();
    _sensorService.stopListening();
    _sensorService.reset();
    _hapticTriggered = false;
    emit(const SwingInitial());
  }

  /// Clean up when this Cubit is disposed.
  @override
  Future<void> close() {
    _subscription?.cancel();
    _sensorService.dispose();
    return super.close();
  }
}
