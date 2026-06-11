import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';
import '../../../core/constants/app_constants.dart';
import '../models/swing_data.dart';


class SensorService {


  double _racketMassKg = AppConstants.defaultRacketMassKg;


  final _swingDataController = StreamController<SwingData>.broadcast();


  StreamSubscription? _accelSubscription;
  StreamSubscription? _gyroSubscription;


  double _accelX = 0, _accelY = 0, _accelZ = 0;
  double _gyroX = 0, _gyroY = 0, _gyroZ = 0;


  double _totalRotation = 0;


  double _maxAcceleration = 0;
  double _maxForce = 0;


  Stream<SwingData> get swingDataStream => _swingDataController.stream;


  void setRacketMass(double massKg) {
    _racketMassKg = massKg;
  }


  double get racketMass => _racketMassKg;


  void startListening() {
    final interval = Duration(milliseconds: AppConstants.sensorIntervalMs);


    _accelSubscription = userAccelerometerEventStream(
      samplingPeriod: interval,
    ).listen((event) {
      _accelX = event.x;
      _accelY = event.y;
      _accelZ = event.z;


      _emitSwingData();
    });


    _gyroSubscription = gyroscopeEventStream(
      samplingPeriod: interval,
    ).listen((event) {
      _gyroX = event.x;
      _gyroY = event.y;
      _gyroZ = event.z;


      final double dtSeconds = AppConstants.sensorIntervalMs / 1000.0;
      final double angularSpeed = sqrt(
        _gyroX * _gyroX + _gyroY * _gyroY + _gyroZ * _gyroZ,
      );
      _totalRotation += angularSpeed * dtSeconds * (180 / pi);
    });
  }


  void stopListening() {
    _accelSubscription?.cancel();
    _gyroSubscription?.cancel();
  }


  void reset() {
    _totalRotation = 0;
    _maxAcceleration = 0;
    _maxForce = 0;
    _accelX = 0;
    _accelY = 0;
    _accelZ = 0;
    _gyroX = 0;
    _gyroY = 0;
    _gyroZ = 0;


    _swingDataController.add(SwingData.empty());
  }


  void dispose() {
    stopListening();
    _swingDataController.close();
  }


  void _emitSwingData() {

    final double acceleration = sqrt(
      _accelX * _accelX + _accelY * _accelY + _accelZ * _accelZ,
    );


    final double force = _racketMassKg * acceleration;


    if (acceleration > _maxAcceleration) {
      _maxAcceleration = acceleration;
    }
    if (force > _maxForce) {
      _maxForce = force;
    }


    final bool swingDetected =
        acceleration >= AppConstants.swingDetectionThreshold;


    final data = SwingData(
      acceleration: acceleration,
      force: force,
      rotationAngle: _totalRotation,
      maxAcceleration: _maxAcceleration,
      maxForce: _maxForce,
      swingDetected: swingDetected,
      accelerometerX: _accelX,
      accelerometerY: _accelY,
      accelerometerZ: _accelZ,
      gyroscopeX: _gyroX,
      gyroscopeY: _gyroY,
      gyroscopeZ: _gyroZ,
    );

    _swingDataController.add(data);
  }
}
