# Implementation Plan: Native Android Sensor Integration

**Branch**: `001-native-sensor-android` | **Date**: 2026-05-16 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/001-native-sensor-android/spec.md`

## Summary

Replace the `sensors_plus` Flutter package with native Android Kotlin code that reads accelerometer and gyroscope sensor data using Android's `SensorManager` API. Data is streamed to Flutter via `EventChannel` platform channels. The existing Flutter UI, Cubit state management, and SensorService public API remain unchanged — only the data source layer is swapped from package-based streams to native EventChannel streams.

## Technical Context

**Language/Version**: Dart 3.11+ (Flutter), Kotlin (Android native)

**Primary Dependencies**: Flutter SDK, Android SensorManager API, flutter_bloc 9.1.1

**Storage**: N/A (real-time streaming only, no persistence)

**Testing**: Manual on-device testing (sensor data requires real hardware)

**Target Platform**: Android API 21+ (Flutter's default minSdk)

**Project Type**: Mobile app (Flutter + native Android)

**Performance Goals**: ≤10ms additional latency vs sensors_plus; 20 Hz sensor sampling rate

**Constraints**: Offline-capable (sensors are local hardware); minimal battery impact

**Scale/Scope**: 2 sensor types, 2 EventChannels, 3 modified files, 1 new file

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

The project constitution is using placeholder content (not yet configured with project-specific principles). No gates to enforce.

**Post-Phase 1 re-check**: No violations. The design follows the project's existing architecture patterns:
- Clean layer separation (Service → Cubit → UI)
- Minimal file changes (2 modified, 1 new in native layer)
- No new dependencies added
- One dependency removed (sensors_plus)

## Project Structure

### Documentation (this feature)

```text
specs/001-native-sensor-android/
├── plan.md              # This file
├── spec.md              # Feature specification
├── research.md          # Phase 0: Technical decisions
├── data-model.md        # Phase 1: Data model
├── quickstart.md        # Phase 1: Developer quickstart
├── contracts/
│   └── event-channels.md  # Phase 1: Platform channel contracts
├── checklists/
│   └── requirements.md    # Spec quality checklist
└── tasks.md             # Phase 2: Task breakdown (via /speckit-tasks)
```

### Source Code (repository root)

```text
android/app/src/main/kotlin/com/example/flutter_project/
├── MainActivity.kt             # [MODIFY] Register EventChannels
└── SensorStreamHandler.kt      # [NEW] Reusable native sensor handler

lib/
├── features/swing/services/
│   └── sensor_service.dart     # [MODIFY] Replace sensors_plus with EventChannel streams
└── (all other files unchanged)

pubspec.yaml                    # [MODIFY] Remove sensors_plus dependency
```

**Structure Decision**: The project follows Flutter's standard mobile app structure with feature-based organization. The native Android layer lives in the standard Kotlin source directory under the app's package. Only 4 files are touched (1 new, 3 modified), keeping the change surface minimal.

## Detailed Changes

### 1. [NEW] `SensorStreamHandler.kt`

**Location**: `android/app/src/main/kotlin/com/example/flutter_project/SensorStreamHandler.kt`

A reusable Kotlin class implementing `EventChannel.StreamHandler` and `SensorEventListener`:

- **Constructor**: Accepts `Context`, `sensorType: Int`, `samplingPeriodUs: Int`
- **`onListen()`**: Gets `SensorManager`, obtains default sensor for the given type, registers listener with the specified sampling period. If sensor is null, sends `SENSOR_UNAVAILABLE` error via `eventSink.error()`.
- **`onCancel()`**: Unregisters the sensor listener and nullifies the event sink.
- **`onSensorChanged()`**: Sends `listOf(event.values[0].toDouble(), event.values[1].toDouble(), event.values[2].toDouble())` to the event sink.
- **`onAccuracyChanged()`**: No-op (not needed for this use case).

### 2. [MODIFY] `MainActivity.kt`

**Location**: `android/app/src/main/kotlin/com/example/flutter_project/MainActivity.kt`

Override `configureFlutterEngine()` to register two EventChannels:

```kotlin
override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    val messenger = flutterEngine.dartExecutor.binaryMessenger
    val intervalUs = 50000 // 50ms in microseconds

    EventChannel(messenger, "com.example.flutter_project/accelerometer")
        .setStreamHandler(SensorStreamHandler(this, Sensor.TYPE_LINEAR_ACCELERATION, intervalUs))

    EventChannel(messenger, "com.example.flutter_project/gyroscope")
        .setStreamHandler(SensorStreamHandler(this, Sensor.TYPE_GYROSCOPE, intervalUs))
}
```

### 3. [MODIFY] `sensor_service.dart`

**Location**: `lib/features/swing/services/sensor_service.dart`

Changes:
- **Remove**: `import 'package:sensors_plus/sensors_plus.dart';`
- **Add**: `import 'package:flutter/services.dart';` (for `EventChannel`)
- **Add**: Two static `EventChannel` constants for accelerometer and gyroscope
- **Replace** `userAccelerometerEventStream()` with `_accelChannel.receiveBroadcastStream()`, mapping events from `List<dynamic>` to individual x/y/z values
- **Replace** `gyroscopeEventStream()` with `_gyroChannel.receiveBroadcastStream()`, mapping events similarly
- **Preserve**: All public API methods (`startListening()`, `stopListening()`, `reset()`, `dispose()`, `swingDataStream`, `setRacketMass()`, `racketMass`)
- **Preserve**: All computation logic (magnitude, force, rotation accumulation, peak tracking, swing detection)

### 4. [MODIFY] `pubspec.yaml`

- **Remove**: `sensors_plus: ^7.0.0` and its comment block
- Lock file will be regenerated on next `flutter pub get`

## Complexity Tracking

No complexity violations to justify — the design is minimal and follows existing patterns.
