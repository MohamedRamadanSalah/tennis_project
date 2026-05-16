# Quickstart: Native Android Sensor Integration

**Date**: 2026-05-16 | **Branch**: `001-native-sensor-android`

## What This Feature Does

Replaces the `sensors_plus` Flutter package with native Android Kotlin code that reads accelerometer and gyroscope sensor data directly using Android's `SensorManager` API. Sensor data is streamed to Flutter via `EventChannel`, keeping the existing UI and state management completely unchanged.

## Prerequisites

- Flutter SDK (3.11+)
- Android SDK with API 21+ support
- An Android device or emulator with accelerometer sensor

## Key Files After Implementation

### Native Android Layer (Kotlin)
```
android/app/src/main/kotlin/com/example/flutter_project/
├── MainActivity.kt             # Registers EventChannels (modified)
└── SensorStreamHandler.kt      # Reusable sensor stream handler (new)
```

### Flutter Layer (Dart)
```
lib/features/swing/services/
└── sensor_service.dart          # Consumes native EventChannels (modified)
```

### Removed
```
pubspec.yaml                     # sensors_plus dependency removed
```

## How It Works

```
┌──────────────────────────────────────────────────────────┐
│ Android Native (Kotlin)                                  │
│                                                          │
│  SensorManager ──► SensorStreamHandler ──► EventSink     │
│  (TYPE_LINEAR_ACCELERATION)                              │
│  (TYPE_GYROSCOPE)                                        │
└──────────────┬───────────────────────────────────────────┘
               │ EventChannel (platform channel)
┌──────────────▼───────────────────────────────────────────┐
│ Flutter (Dart)                                           │
│                                                          │
│  EventChannel.stream ──► SensorService ──► SwingCubit    │
│                           (unchanged API)   (unchanged)  │
│                                                          │
│  SwingCubit ──► UI Widgets (unchanged)                   │
└──────────────────────────────────────────────────────────┘
```

## Build & Run

```bash
# No additional setup needed — standard Flutter build
flutter run
```

## Verify

1. Launch app on Android device
2. Start a recording session
3. Perform a tennis swing motion
4. Verify:
   - Accelerometer x/y/z values update in real time
   - Gyroscope x/y/z values update in real time
   - Acceleration magnitude is calculated correctly
   - Force = mass × acceleration displays correctly
   - Rotation angle accumulates during rotation
   - Swing detection triggers above threshold (5.0 m/s²)
   - Peak values track maximums correctly
   - Haptic feedback triggers on swing detection
5. Stop recording — verify sensor values freeze
6. Background the app — verify no continued sensor activity (check battery stats)

## Adding a New Sensor (Extensibility)

To add magnetometer support:

1. In `MainActivity.kt`, add:
   ```kotlin
   EventChannel(flutterEngine.dartExecutor.binaryMessenger,
       "com.example.flutter_project/magnetometer")
       .setStreamHandler(SensorStreamHandler(this, Sensor.TYPE_MAGNETIC_FIELD, 50000))
   ```

2. In `sensor_service.dart`, add:
   ```dart
   static const _magnetometerChannel =
       EventChannel('com.example.flutter_project/magnetometer');

   Stream<List<double>> get magnetometerStream =>
       _magnetometerChannel.receiveBroadcastStream()
           .map((event) => (event as List).cast<double>());
   ```
