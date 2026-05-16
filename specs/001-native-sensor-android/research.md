# Research: Native Android Sensor Integration

**Date**: 2026-05-16 | **Branch**: `001-native-sensor-android`

## R1: Flutter ↔ Native Communication Mechanism

**Decision**: Use `EventChannel` for continuous sensor streaming; no `MethodChannel` needed for this feature.

**Rationale**: `EventChannel` is Flutter's built-in mechanism for streaming data from native to Dart via platform channels. It maps directly to Android's callback-based `SensorEventListener`, creating a natural 1:1 correspondence: native sensor events → EventChannel sink → Dart Stream. The sensors_plus package itself uses this same pattern internally.

**Alternatives considered**:
- **MethodChannel with polling**: Rejected — polling introduces latency and wastes CPU. Event-driven is the correct model for sensor data.
- **BasicMessageChannel**: Rejected — designed for ad-hoc bidirectional messaging, not continuous streaming.
- **Pigeon (code-gen)**: Over-engineering for a simple streaming use case with a fixed data shape (3 floats per event).

## R2: Android SensorManager API for Accelerometer (Gravity-Removed)

**Decision**: Use `Sensor.TYPE_LINEAR_ACCELERATION` (type 10) to match the current `userAccelerometerEventStream()` behavior from sensors_plus.

**Rationale**: The current app uses `userAccelerometerEventStream()` which explicitly removes gravity. Android's `TYPE_LINEAR_ACCELERATION` sensor provides the same gravity-free linear acceleration. Using `TYPE_ACCELEROMETER` would include gravitational force (~9.8 m/s²), breaking swing detection thresholds and force calculations.

**Alternatives considered**:
- `Sensor.TYPE_ACCELEROMETER` (type 1): Rejected — includes gravity component, would require manual high-pass filtering to match current behavior.
- Custom software sensor fusion: Rejected — unnecessary complexity; `TYPE_LINEAR_ACCELERATION` is a hardware/fused sensor available on all modern devices.

## R3: Sensor Sampling Rate Configuration

**Decision**: Use `SensorManager.SENSOR_DELAY_GAME` as the default, with the ability to pass a custom interval in microseconds matching the app's configured 50ms (20 Hz).

**Rationale**: Android's `registerListener()` accepts a sampling period in microseconds. The app's current interval of 50ms = 50,000 μs. `SENSOR_DELAY_GAME` (~20ms) is faster than needed but the OS will downsample. Passing the exact desired interval (50,000 μs) gives the framework the best hint for power management.

**Alternatives considered**:
- `SENSOR_DELAY_FASTEST`: Rejected — unnecessary power consumption for 20 Hz use case.
- `SENSOR_DELAY_NORMAL`: Rejected — ~200ms intervals are too slow for real-time swing detection.

## R4: EventChannel Data Encoding Format

**Decision**: Transmit sensor events as a `List<Double>` of 3 elements `[x, y, z]` via the EventChannel sink.

**Rationale**: Flutter's platform channel codecs natively handle `List<Double>` with zero-copy semantics. This is the simplest possible encoding — no serialization overhead, no JSON parsing, no protobuf. The Dart side receives a `List<dynamic>` that can be cast to doubles directly.

**Alternatives considered**:
- `Map<String, Double>`: Rejected — key lookup adds overhead for a fixed 3-element structure.
- JSON string: Rejected — serialization/deserialization adds ~10× overhead compared to native codec.
- ByteBuffer/protobuf: Rejected — over-engineering for 3 floats at 20 Hz.

## R5: Lifecycle Management Strategy

**Decision**: Use `EventChannel.StreamHandler` callbacks (`onListen` / `onCancel`) as the primary lifecycle mechanism. Sensor listeners are registered in `onListen` and unregistered in `onCancel`. No activity lifecycle observer is needed.

**Rationale**: When the Dart stream subscription is cancelled (via `StreamSubscription.cancel()`), Flutter automatically calls `onCancel` on the native `StreamHandler`, which triggers sensor unregistration. This creates a clean, stream-driven lifecycle: Dart controls when sensors are active by subscribing/unsubscribing to the stream.

The Flutter engine already handles activity lifecycle (pause/resume) and stops event delivery when the activity is not visible. Adding a separate `ActivityLifecycleCallbacks` observer would add complexity without measurable benefit.

**Alternatives considered**:
- `LifecycleEventObserver` on Activity: Rejected — adds a second lifecycle management path that must be synchronized with EventChannel state.
- `WidgetsBindingObserver` on Dart side: Rejected — the existing `SwingCubit.close()` → `SensorService.dispose()` chain already handles cleanup.

## R6: Channel Naming Convention

**Decision**: Use the following EventChannel names:
- `com.example.flutter_project/accelerometer` — for linear acceleration (gravity-removed)
- `com.example.flutter_project/gyroscope` — for gyroscope rotation rate

**Rationale**: Using the application's package name as a prefix follows the Flutter platform channels best practice to avoid naming collisions. One channel per sensor type allows independent subscription/unsubscription, matching the current architecture where accelerometer and gyroscope are consumed independently.

## R7: Error Handling for Missing Sensors

**Decision**: Send an error through the EventChannel sink with code `SENSOR_UNAVAILABLE` if `SensorManager.getDefaultSensor()` returns null.

**Rationale**: Some low-end Android devices lack gyroscopes. Rather than crashing, the native layer should report the error via the EventChannel's error mechanism (`eventSink.error()`). The Dart side can then handle this gracefully — continuing with accelerometer-only data or showing a user message.

## R8: Kotlin Code Architecture (Native Side)

**Decision**: Create one Kotlin file per sensor handler, plus the `MainActivity` as the registration point:
- `SensorStreamHandler.kt` — reusable base handler class for any sensor type
- `MainActivity.kt` — registers EventChannels with their respective handlers

**Rationale**: A reusable `SensorStreamHandler` class that accepts a sensor type as a constructor parameter enables the P3 extensibility goal — adding a new sensor requires only one new EventChannel registration line in `MainActivity`, not a new handler class.

**Alternatives considered**:
- One monolithic handler for all sensors: Rejected — violates single responsibility, harder to extend.
- Separate handler classes per sensor: Rejected — leads to code duplication since the logic (register listener, relay events, unregister) is identical for all 3-axis sensors.
