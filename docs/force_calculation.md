# Force Calculation

## The Physics Behind the App

This app calculates force using **Newton's Second Law of Motion**, one of the most fundamental equations in physics.

---

## Newton's Second Law

```
F = m × a
```

| Symbol | Meaning | Unit | Our Value |
|--------|---------|------|-----------|
| **F** | Force | Newtons (N) | Calculated result |
| **m** | Mass | Kilograms (kg) | 0.300 kg (tennis racket) |
| **a** | Acceleration | m/s² | Measured by accelerometer |

**In plain English:** The force of a swing equals the mass of the racket multiplied by how fast it accelerates.

---

## Step-by-Step Calculation

### Step 1: Read Raw Sensor Data

The accelerometer provides three values every 50 milliseconds:

```
Accelerometer reading:
  x = 2.5 m/s²   (left/right)
  y = 8.1 m/s²   (up/down)
  z = 3.2 m/s²   (forward/backward)
```

### Step 2: Calculate Acceleration Magnitude

We combine the three axes into one number using 3D Pythagorean theorem:

```
a = √(x² + y² + z²)
a = √(2.5² + 8.1² + 3.2²)
a = √(6.25 + 65.61 + 10.24)
a = √82.1
a = 9.06 m/s²
```

### Step 3: Apply Newton's Second Law

```
F = m × a
F = 0.300 kg × 9.06 m/s²
F = 2.72 N
```

**Result:** The estimated force of this swing reading is **2.72 Newtons**.

---

## Implementation in Code

From `sensor_service.dart`:

```dart
// Step 2: Calculate total acceleration magnitude
final double acceleration = sqrt(
  _accelX * _accelX + _accelY * _accelY + _accelZ * _accelZ,
);

// Step 3: Apply Newton's second law: F = m × a
final double force = _racketMassKg * acceleration;
```

The racket mass defaults to 0.300 kg, defined in `app_constants.dart`:

```dart
static const double defaultRacketMassKg = 0.300; // 300 grams
```

---

## Rotation Angle Calculation

Besides force, we also calculate the **rotation angle** of the swing.

### The Formula

```
angular_speed = √(gyroX² + gyroY² + gyroZ²)     ← rad/s
Δangle = angular_speed × Δt × (180 / π)          ← degrees
total_angle = total_angle + Δangle                ← accumulate
```

### Worked Example

```
Gyroscope reading: x=0.5, y=1.2, z=0.8 rad/s
Time interval: Δt = 0.05 seconds

angular_speed = √(0.25 + 1.44 + 0.64) = √2.33 = 1.53 rad/s
Δangle = 1.53 × 0.05 × 57.296 = 4.38°

If previous total was 10.0°:
total_angle = 10.0 + 4.38 = 14.38°
```

---

## Why These Are "Estimates"

Our calculations are **estimates**, not exact measurements. Here's why:

| Factor | Explanation |
|--------|-------------|
| **Phone ≠ racket** | The phone sits in your hand, not at the racket head where forces are highest |
| **Point mass assumption** | We treat the racket as a single point with uniform mass; real rackets have distributed mass |
| **No air resistance** | We ignore drag forces from air |
| **Sensor accuracy** | Phone sensors have limited precision (±0.1 m/s² typically) |
| **Discrete sampling** | We sample 20 times/second; events between samples are missed |

For a university project, these simplifications are acceptable and clearly documented. A professional sports app would use dedicated sensors attached to the racket.

---

## Real-World Context

| Scenario | Typical Force |
|----------|--------------|
| Holding phone still | ~0 N |
| Gentle swing | 1–3 N |
| Moderate swing | 3–8 N |
| Hard swing | 8–15 N |
| Professional tennis serve (real racket) | 50–80 N |

Our values will be lower than professional measurements because we're measuring the hand's acceleration, not the racket head's.

---

## Summary

```
Raw sensor data (x, y, z)
        │
        ▼
  a = √(x² + y² + z²)     ← Acceleration magnitude
        │
        ▼
  F = m × a                ← Newton's Second Law
        │
        ▼
  Display on MetricCard     ← User sees the result
```
