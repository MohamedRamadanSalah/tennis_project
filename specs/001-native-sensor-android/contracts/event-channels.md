# Platform Channel Contract: Sensor EventChannels

**Date**: 2026-05-16 | **Branch**: `001-native-sensor-android`

This document defines the contract between the native Android (Kotlin) layer and the Flutter (Dart) layer for sensor data streaming.

## Accelerometer EventChannel

**Channel name**: `com.example.flutter_project/accelerometer`
**Direction**: Native → Dart (streaming)
**Protocol**: Flutter Standard Message Codec

### Stream Events (success)

Each event is a `List<Double>` with exactly 3 elements:

```
[x: Double, y: Double, z: Double]
```

- **x**: Linear acceleration along the X axis (m/s²), gravity removed
- **y**: Linear acceleration along the Y axis (m/s²), gravity removed
- **z**: Linear acceleration along the Z axis (m/s²), gravity removed

### Stream Errors

| Error Code            | Message                         | Details |
|-----------------------|---------------------------------|---------|
| `SENSOR_UNAVAILABLE`  | "Linear acceleration sensor not available" | `null`  |

### Lifecycle

| Dart Action                           | Native Reaction                                      |
|---------------------------------------|------------------------------------------------------|
| `stream.listen()`                     | `SensorManager.registerListener()` with `TYPE_LINEAR_ACCELERATION` |
| `subscription.cancel()`              | `SensorManager.unregisterListener()`                 |

---

## Gyroscope EventChannel

**Channel name**: `com.example.flutter_project/gyroscope`
**Direction**: Native → Dart (streaming)
**Protocol**: Flutter Standard Message Codec

### Stream Events (success)

Each event is a `List<Double>` with exactly 3 elements:

```
[x: Double, y: Double, z: Double]
```

- **x**: Angular velocity around the X axis (rad/s)
- **y**: Angular velocity around the Y axis (rad/s)
- **z**: Angular velocity around the Z axis (rad/s)

### Stream Errors

| Error Code            | Message                       | Details |
|-----------------------|-------------------------------|---------|
| `SENSOR_UNAVAILABLE`  | "Gyroscope sensor not available" | `null`  |

### Lifecycle

| Dart Action                           | Native Reaction                                      |
|---------------------------------------|------------------------------------------------------|
| `stream.listen()`                     | `SensorManager.registerListener()` with `TYPE_GYROSCOPE` |
| `subscription.cancel()`              | `SensorManager.unregisterListener()`                 |

---

## Sampling Configuration

| Parameter        | Value                          | Source                         |
|------------------|--------------------------------|--------------------------------|
| Sampling period  | 50,000 μs (50 ms / 20 Hz)     | `AppConstants.sensorIntervalMs × 1000` |
| Sensor delay     | Custom interval in μs          | Passed to `registerListener()` |

## Extension Pattern

To add a new sensor type (e.g., magnetometer):

1. Register a new `EventChannel` in `MainActivity.configureFlutterEngine()` with name `com.example.flutter_project/<sensor_name>`
2. Create a `SensorStreamHandler` instance with the corresponding `Sensor.TYPE_*` constant
3. Set the handler on the new channel
4. On the Dart side, create a new `EventChannel` and expose the stream

No existing sensor code needs to be modified.
