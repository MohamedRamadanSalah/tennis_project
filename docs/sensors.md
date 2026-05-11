# Sensor Usage

## What Sensors Does This App Use?

| Sensor | Measures | Unit | Our Use Case |
|--------|----------|------|-------------|
| **Accelerometer** | Linear acceleration | m/s² | Detect swing speed |
| **Gyroscope** | Rotational velocity | rad/s | Detect swing rotation |

---

## 1. Accelerometer — Detecting Movement

An accelerometer measures how quickly the phone speeds up or slows down along three axes:

```
        Y (up/down)
        ▲
        │
        ┼──────→ X (left/right)
       ╱
      ▼
    Z (forward/backward)
```

### Standard vs. User Accelerometer

| Type | Includes Gravity? | We Use? |
|------|-------------------|---------|
| `accelerometerEventStream` | ✅ Yes (9.8 m/s²) | ❌ |
| `userAccelerometerEventStream` | ❌ No | ✅ |

We use `userAccelerometerEventStream` because we only want acceleration from the user's hand, not gravity.

### Calculating Total Acceleration

```
acceleration = √(x² + y² + z²)
```

**Example:** x=3, y=4, z=0 → `√(9+16+0) = 5.0 m/s²`

```dart
final double acceleration = sqrt(
  _accelX * _accelX + _accelY * _accelY + _accelZ * _accelZ,
);
```

---

## 2. Gyroscope — Detecting Rotation

The gyroscope measures rotation speed in radians per second. We accumulate it to get total angle:

```
angular_speed = √(gyroX² + gyroY² + gyroZ²)
angle_change  = angular_speed × Δt × (180/π)
total_angle   = total_angle + angle_change
```

Where `Δt = 0.05s` (50ms interval) and `180/π ≈ 57.296` converts radians to degrees.

```dart
final double dtSeconds = AppConstants.sensorIntervalMs / 1000.0;
final double angularSpeed = sqrt(
  _gyroX * _gyroX + _gyroY * _gyroY + _gyroZ * _gyroZ,
);
_totalRotation += angularSpeed * dtSeconds * (180 / pi);
```

---

## 3. Sampling Rate

We sample at **50ms** (20 readings/second) — a good balance of accuracy and battery life.

| Rate | Readings/sec | Trade-off |
|------|-------------|-----------|
| 10 ms | 100 | Very accurate, high battery drain |
| **50 ms** | **20** | **Good balance (our choice)** |
| 200 ms | 5 | Low drain, misses fast swings |

---

## 4. Data Flow

```
Accelerometer → x, y, z (m/s²) ─┐
                                 ├→ SensorService → SwingData → Cubit → UI
Gyroscope     → x, y, z (rad/s) ┘
```

---

## 5. Limitations

| Limitation | Explanation |
|-----------|-------------|
| **Sensor drift** | Gyroscope accumulates small errors over time |
| **Phone ≠ racket** | Actual racket dynamics are more complex |
| **No calibration** | A production app would calibrate before use |
| **Device variation** | Different phones have different sensor quality |
