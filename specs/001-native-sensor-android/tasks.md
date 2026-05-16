# Tasks: Native Android Sensor Integration

**Input**: Design documents from `specs/001-native-sensor-android/`

**Prerequisites**: plan.md (required), spec.md (required), research.md, data-model.md, contracts/

**Tests**: No test tasks — not explicitly requested in the feature specification. Manual on-device validation per quickstart.md.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

- **Flutter/Dart**: `lib/` at repository root
- **Android Native**: `android/app/src/main/kotlin/com/example/flutter_project/`
- **Project config**: repository root (`pubspec.yaml`)

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Remove the old dependency and prepare the project for native sensor integration

- [x] T001 Remove `sensors_plus` dependency from `pubspec.yaml` and its comment block
- [x] T002 Run `flutter pub get` to regenerate `pubspec.lock` without sensors_plus

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Create the native Android sensor infrastructure that all user stories depend on

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [x] T003 Create `SensorStreamHandler.kt` in `android/app/src/main/kotlin/com/example/flutter_project/SensorStreamHandler.kt` — a reusable Kotlin class implementing `EventChannel.StreamHandler` and `SensorEventListener`. Constructor accepts `Context`, `sensorType: Int`, `samplingPeriodUs: Int`. `onListen()` obtains `SensorManager`, gets default sensor, registers listener; sends `SENSOR_UNAVAILABLE` error if sensor is null. `onCancel()` unregisters listener and nullifies sink. `onSensorChanged()` sends `listOf(event.values[0].toDouble(), event.values[1].toDouble(), event.values[2].toDouble())` to the event sink. `onAccuracyChanged()` is a no-op.
- [x] T004 Modify `MainActivity.kt` in `android/app/src/main/kotlin/com/example/flutter_project/MainActivity.kt` — override `configureFlutterEngine()` to register two `EventChannel` instances: `com.example.flutter_project/accelerometer` with `SensorStreamHandler(this, Sensor.TYPE_LINEAR_ACCELERATION, 50000)` and `com.example.flutter_project/gyroscope` with `SensorStreamHandler(this, Sensor.TYPE_GYROSCOPE, 50000)`.

**Checkpoint**: ✅ Native sensor layer is in place — EventChannels are registered and ready to stream data

---

## Phase 3: User Story 1 - Real-Time Swing Sensor Data (Priority: P1) 🎯 MVP

**Goal**: Replace sensors_plus streams in the Flutter SensorService with native EventChannel streams so the existing UI continues to display real-time swing data identically.

**Independent Test**: Launch app on Android device, start recording, perform tennis swing — verify acceleration, force, rotation, and swing detection all update in real time.

### Implementation for User Story 1

- [x] T005 [US1] Modify `sensor_service.dart` in `lib/features/swing/services/sensor_service.dart` — remove `import 'package:sensors_plus/sensors_plus.dart'`; add `import 'package:flutter/services.dart'`; add two static `EventChannel` constants: `_accelChannel = EventChannel('com.example.flutter_project/accelerometer')` and `_gyroChannel = EventChannel('com.example.flutter_project/gyroscope')`.
- [x] T006 [US1] Update `startListening()` in `lib/features/swing/services/sensor_service.dart` — replace `userAccelerometerEventStream(samplingPeriod: interval).listen(...)` with `_accelChannel.receiveBroadcastStream().listen((event) { final data = event as List; _accelX = (data[0] as num).toDouble(); _accelY = (data[1] as num).toDouble(); _accelZ = (data[2] as num).toDouble(); _emitSwingData(); })`. Replace `gyroscopeEventStream(samplingPeriod: interval).listen(...)` with `_gyroChannel.receiveBroadcastStream().listen((event) { final data = event as List; _gyroX = (data[0] as num).toDouble(); _gyroY = (data[1] as num).toDouble(); _gyroZ = (data[2] as num).toDouble(); ... })` preserving the existing rotation accumulation logic. Remove the `interval` variable since the sampling rate is now configured on the native side.

**Checkpoint**: ✅ App builds and displays real-time sensor data via native channels — fully functional MVP

---

## Phase 4: User Story 2 - Sensor Lifecycle Management (Priority: P2)

**Goal**: Verify and ensure that sensor listeners are properly registered on stream start and unregistered on stream cancel, app background, or activity destruction.

**Independent Test**: Start recording, stop recording — verify (via logs) that native listeners are unregistered. Background the app with active sensors — verify listeners are released.

### Implementation for User Story 2

- [x] T007 [US2] Add lifecycle logging to `SensorStreamHandler.kt` in `android/app/src/main/kotlin/com/example/flutter_project/SensorStreamHandler.kt` — add `Log.d` calls in `onListen()` (sensor registered), `onCancel()` (sensor unregistered), and `onSensorChanged()` (first event only, to avoid log spam) to enable verification of proper lifecycle management.
- [x] T008 [US2] Verify lifecycle correctness in `sensor_service.dart` in `lib/features/swing/services/sensor_service.dart` — ensure `stopListening()` cancels both stream subscriptions (which triggers native `onCancel()` and sensor unregistration). Ensure `dispose()` calls `stopListening()` then closes the `_swingDataController`. No code changes expected if Phase 3 was implemented correctly — this task is a review/verification step.

**Checkpoint**: ✅ Sensor lifecycle is verifiably correct — no listener leaks on stop, background, or destroy

---

## Phase 5: User Story 3 - Future Sensor Extension (Priority: P3)

**Goal**: Ensure the architecture is structured so adding a new sensor type requires only adding a new EventChannel registration in `MainActivity.kt` and a new stream in `sensor_service.dart` — with zero changes to existing sensor code.

**Independent Test**: Review code architecture — verify each sensor is isolated in its own channel handler and adding magnetometer would require only new registration + stream.

### Implementation for User Story 3

- [x] T009 [US3] Verify extensibility of `SensorStreamHandler.kt` in `android/app/src/main/kotlin/com/example/flutter_project/SensorStreamHandler.kt` — confirm the class is fully parameterized by `sensorType` and `samplingPeriodUs` so no code changes are needed to support a new sensor type. No code changes expected — this is a review/verification task.
- [x] T010 [US3] Add extensibility documentation comment in `MainActivity.kt` in `android/app/src/main/kotlin/com/example/flutter_project/MainActivity.kt` — add a code comment showing the pattern for adding a new sensor (e.g., magnetometer example).

**Checkpoint**: ✅ Architecture review confirms extensibility — adding a new sensor requires only 2 additions (1 native + 1 Dart), no modifications

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Final cleanup and validation

- [x] T011 [P] Verify no remaining `sensors_plus` references in application code by searching the entire `lib/` directory and `pubspec.yaml`
- [x] T012 [P] Update documentation comments in `sensor_service.dart` in `lib/features/swing/services/sensor_service.dart` — update the file header comment to reflect that sensor data now comes from native Android EventChannels instead of sensors_plus
- [x] T013 Run `flutter pub get` and verify the project builds cleanly with `flutter build apk --debug`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion — BLOCKS all user stories
- **User Story 1 (Phase 3)**: Depends on Foundational phase (T003, T004 complete)
- **User Story 2 (Phase 4)**: Depends on User Story 1 completion (needs working sensor streams to verify lifecycle)
- **User Story 3 (Phase 5)**: Depends on Foundational phase only (architecture review); can run in parallel with US1/US2
- **Polish (Phase 6)**: Depends on all user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational (Phase 2) — No dependencies on other stories
- **User Story 2 (P2)**: Depends on User Story 1 — needs working streams to verify lifecycle behavior
- **User Story 3 (P3)**: Can start after Foundational (Phase 2) — architecture review is independent of stream functionality

### Within Each User Story

- Models/infrastructure before services
- Core implementation before integration
- Story complete before moving to next priority

### Parallel Opportunities

- T001 and T003 affect different files — but T003 depends on T001 conceptually (build must work)
- T011 and T012 are fully parallelizable (different files, read-only vs documentation)
- US3 (T009, T010) can run in parallel with US1 (T005, T006) since they touch different concerns

---

## Parallel Example: User Story 1

```
# These tasks are sequential (same file):
Task T005: Add EventChannel constants to sensor_service.dart
Task T006: Update startListening() in sensor_service.dart
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (T001-T002)
2. Complete Phase 2: Foundational (T003-T004)
3. Complete Phase 3: User Story 1 (T005-T006)
4. **STOP and VALIDATE**: Test on Android device — all swing metrics display correctly
5. Deploy/demo if ready

### Incremental Delivery

1. Complete Setup + Foundational → Native layer ready
2. Add User Story 1 → Test on device → MVP complete
3. Add User Story 2 → Verify lifecycle via logs → Battery-safe
4. Add User Story 3 → Architecture review → Extensible
5. Polish → Clean code, documentation, final build verification

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- All 13 tasks, 4 files touched (1 new, 3 modified)
- No test tasks included — validation is manual on-device per quickstart.md
- Commit after each phase completion
- Stop at any checkpoint to validate story independently
