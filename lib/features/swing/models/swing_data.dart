class SwingData {


  final double acceleration;


  final double force;


  final double rotationAngle;


  final double maxAcceleration;


  final double maxForce;


  final bool swingDetected;


  final double accelerometerX;
  final double accelerometerY;
  final double accelerometerZ;


  final double gyroscopeX;
  final double gyroscopeY;
  final double gyroscopeZ;

  const SwingData({
    required this.acceleration,
    required this.force,
    required this.rotationAngle,
    required this.maxAcceleration,
    required this.maxForce,
    required this.swingDetected,
    required this.accelerometerX,
    required this.accelerometerY,
    required this.accelerometerZ,
    required this.gyroscopeX,
    required this.gyroscopeY,
    required this.gyroscopeZ,
  });


  factory SwingData.empty() {
    return const SwingData(
      acceleration: 0,
      force: 0,
      rotationAngle: 0,
      maxAcceleration: 0,
      maxForce: 0,
      swingDetected: false,
      accelerometerX: 0,
      accelerometerY: 0,
      accelerometerZ: 0,
      gyroscopeX: 0,
      gyroscopeY: 0,
      gyroscopeZ: 0,
    );
  }
}
