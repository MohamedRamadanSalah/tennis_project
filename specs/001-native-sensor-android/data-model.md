# Data Model: Native Android Sensor Integration

**Date**: 2026-05-16 | **Branch**: `001-native-sensor-android`

## Entities

### SensorEvent (Native → Dart boundary)

The data transmitted across the EventChannel for each sensor reading.

| Field | Type     | Description                                      |
|-------|----------|--------------------------------------------------|
| x     | `double` | Sensor value along the X axis                    |
| y     | `double` | Sensor value along the Y axis                    |
| z     | `double` | Sensor value along the Z axis                    |

**Wire format**: `List<Double>` of 3 elements `[x, y, z]` — transmitted via Flutter's standard message codec.

**Units**:
- Accelerometer: m/s² (linear acceleration, gravity removed)
- Gyroscope: rad/s (angular velocity)

---

### SwingData (Dart domain model — unchanged)

The existing `SwingData` class remains unchanged. It is computed inside `SensorService` from the raw sensor events above.

| Field           | Type     | Source                                          |
|-----------------|----------|-------------------------------------------------|
| acceleration    | `double` | `sqrt(x² + y² + z²)` from accelerometer        |
| force           | `double` | `racketMass × acceleration`                     |
| rotationAngle   | `double` | Accumulated from gyroscope angular speed         |
| maxAcceleration | `double` | Peak acceleration seen during session            |
| maxForce        | `double` | Peak force seen during session                   |
| swingDetected   | `bool`   | `acceleration >= swingDetectionThreshold`        |
| accelerometerX  | `double` | Raw accelerometer X from native                  |
| accelerometerY  | `double` | Raw accelerometer Y from native                  |
| accelerometerZ  | `double` | Raw accelerometer Z from native                  |
| gyroscopeX      | `double` | Raw gyroscope X from native                      |
| gyroscopeY      | `double` | Raw gyroscope Y from native                      |
| gyroscopeZ      | `double` | Raw gyroscope Z from native                      |

---

### Channel Names (Platform Channel identifiers)

| Channel Name                                    | Direction       | Sensor Type              |
|-------------------------------------------------|-----------------|--------------------------|
| `com.example.flutter_project/accelerometer`     | Native → Dart   | Linear Acceleration      |
| `com.example.flutter_project/gyroscope`         | Native → Dart   | Gyroscope                |

---

## State Transitions

No state transitions change. The existing `SwingState` sealed class hierarchy remains:

```
SwingInitial → SwingRecording → SwingStopped
     ↑                              │
     └────────── (reset) ───────────┘
```

## Validation Rules

- Sensor values (x, y, z) are IEEE 754 doubles — no validation needed at the channel boundary.
- `SensorService` validates sensor availability indirectly: if the EventChannel sends an error (`SENSOR_UNAVAILABLE`), the Dart stream emits an error that the Cubit can handle.
- Sampling interval must be a positive integer in milliseconds (enforced by `AppConstants.sensorIntervalMs`).
