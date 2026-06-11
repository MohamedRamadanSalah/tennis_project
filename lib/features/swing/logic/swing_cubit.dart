import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/swing_data.dart';
import '../services/sensor_service.dart';
import 'swing_state.dart';


class SwingCubit extends Cubit<SwingState> {

  final SensorService _sensorService;


  StreamSubscription<SwingData>? _subscription;


  bool _hapticTriggered = false;


  SwingCubit({required SensorService sensorService})
      : _sensorService = sensorService,
        super(const SwingInitial());


  void startRecording() {

    _hapticTriggered = false;


    _sensorService.startListening();


    _subscription = _sensorService.swingDataStream.listen((swingData) {


      if (swingData.swingDetected && !_hapticTriggered) {
        HapticFeedback.heavyImpact();
        _hapticTriggered = true;
      }


      if (!swingData.swingDetected) {
        _hapticTriggered = false;
      }

      emit(SwingRecording(data: swingData));
    });
  }


  void stopRecording() {
    _subscription?.cancel();
    _sensorService.stopListening();

    final currentState = state;
    if (currentState is SwingRecording) {
      emit(SwingStopped(data: currentState.data));
    }
  }


  void updateMass(double massKg) {
    _sensorService.setRacketMass(massKg);
  }


  double get currentMass => _sensorService.racketMass;


  void reset() {
    _subscription?.cancel();
    _sensorService.stopListening();
    _sensorService.reset();
    _hapticTriggered = false;
    emit(const SwingInitial());
  }


  @override
  Future<void> close() {
    _subscription?.cancel();
    _sensorService.dispose();
    return super.close();
  }
}
