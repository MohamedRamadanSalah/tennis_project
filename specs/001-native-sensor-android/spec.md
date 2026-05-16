# Feature Specification: Native Android Sensor Integration

**Feature Branch**: `001-native-sensor-android`

**Created**: 2026-05-16

**Status**: Draft

**Input**: User description: "Replace the sensors_plus Flutter package with a native Android implementation using Kotlin. The application currently reads accelerometer and gyroscope sensor data using the sensors_plus package. The new implementation should use native Android SensorManager APIs in Kotlin, access Accelerometer and Gyroscope sensors directly, stream real-time sensor values from Kotlin to Flutter, use EventChannel for continuous sensor streaming, keep Flutter UI unchanged as much as possible, create a clean architecture separation between Flutter layer and native Android layer, support proper lifecycle management, handle sensor listener registration and unregistration safely, minimize latency for real-time motion detection, and be structured for future extension with additional sensors."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Real-Time Swing Sensor Data (Priority: P1)

As a user performing a tennis swing, I continue to see the same real-time accelerometer and gyroscope data displayed on screen as before, with no visible change in behavior or responsiveness — but sensor readings now originate from the native Android layer instead of the sensors_plus package.

**Why this priority**: This is the core value of the feature — the existing swing analysis must continue to work identically after the migration. If sensor data stops flowing or becomes noticeably different, the entire application is broken.

**Independent Test**: Can be fully tested by opening the app on an Android device, starting a recording session, performing a tennis swing, and verifying that acceleration magnitude, force, rotation angle, and swing detection indicators all update in real time exactly as they did with the sensors_plus implementation.

**Acceptance Scenarios**:

1. **Given** the app is launched on an Android device, **When** I start a recording session and move the phone, **Then** the UI displays live accelerometer (x, y, z) values and computed acceleration magnitude, updating at the configured sample rate.
2. **Given** a recording session is active, **When** I rotate the phone, **Then** the UI displays live gyroscope (x, y, z) values and the accumulated rotation angle updates smoothly.
3. **Given** a recording session is active, **When** I perform a tennis swing motion above the detection threshold, **Then** the swing detected indicator activates and peak force / peak acceleration values are tracked correctly.

---

### User Story 2 - Sensor Lifecycle Management (Priority: P2)

As a user, when I navigate away from the swing screen, close the app, or stop a recording session, the app properly releases sensor resources on the native side — preventing battery drain, memory leaks, or stale sensor registrations.

**Why this priority**: Without correct lifecycle management, the native sensor listeners could remain active indefinitely after the user stops or backgrounds the app, causing significant battery drain and potentially degrading device performance.

**Independent Test**: Can be tested by starting a recording, stopping it, and verifying (via debug logs or system monitoring) that native sensor listeners are unregistered. Repeat with backgrounding/killing the app.

**Acceptance Scenarios**:

1. **Given** a recording session is active, **When** I stop the recording, **Then** native sensor listeners are unregistered and no further sensor events are delivered.
2. **Given** the app is in the foreground with active sensors, **When** the app is moved to the background or destroyed, **Then** native sensor listeners are released cleanly.
3. **Given** sensors were previously stopped, **When** I start a new recording session, **Then** fresh sensor listeners are registered and data flows again without errors.

---

### User Story 3 - Future Sensor Extension (Priority: P3)

As a developer extending the application, I can add support for additional sensor types (e.g., magnetometer, barometer) by following the same pattern used for accelerometer and gyroscope, without modifying the existing sensor channels or Flutter UI code for existing sensors.

**Why this priority**: The tennis analysis app may evolve to use additional sensors for more advanced analysis. A well-structured native layer makes future work significantly easier.

**Independent Test**: Can be tested by reviewing the native code architecture and verifying that adding a new sensor type requires only adding a new EventChannel handler and corresponding Dart stream — without touching accelerometer or gyroscope code.

**Acceptance Scenarios**:

1. **Given** the native sensor layer is implemented, **When** a developer reviews the code architecture, **Then** each sensor type is isolated in its own channel handler, making it clear how to add a new sensor.
2. **Given** a developer wants to add magnetometer support, **When** they follow the existing pattern, **Then** they can add the new sensor without modifying the accelerometer or gyroscope implementation code.

---

### Edge Cases

- What happens when the device does not have a gyroscope sensor (e.g., low-end devices)?
- What happens if the sensor sampling rate cannot be met by the hardware?
- How does the system handle rapid start/stop/start cycles of sensor listening?
- What happens if the EventChannel stream is cancelled unexpectedly from the Flutter side?
- How does the system behave if the native activity is recreated (e.g., configuration change)?

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST stream accelerometer data (x, y, z axes) from the native Android layer to the Flutter layer using EventChannel.
- **FR-002**: The system MUST stream gyroscope data (x, y, z axes) from the native Android layer to the Flutter layer using EventChannel.
- **FR-003**: The system MUST provide user accelerometer data (gravity removed) to match the current behavior of sensors_plus's `userAccelerometerEventStream`.
- **FR-004**: The system MUST support a configurable sensor sampling interval, defaulting to the current application setting (50 ms / 20 Hz).
- **FR-005**: The system MUST register native sensor listeners when the Flutter side starts listening to the EventChannel stream.
- **FR-006**: The system MUST unregister native sensor listeners when the Flutter side cancels the EventChannel stream or when the activity lifecycle transitions to a stopped state.
- **FR-007**: The system MUST deliver sensor data with minimal latency suitable for real-time tennis swing detection.
- **FR-008**: The Flutter UI layer MUST remain functionally unchanged — the existing SensorService, SwingCubit, and UI widgets must continue to work with only the data source changing.
- **FR-009**: The system MUST handle the case where a requested sensor is unavailable on the device by sending an error through the EventChannel.
- **FR-010**: The sensors_plus package dependency MUST be removed from the project after migration.

### Key Entities

- **SensorReading**: Represents a single timestamped reading from a hardware sensor, consisting of three axis values (x, y, z).
- **SensorChannel**: A named communication pathway between the native Android layer and the Flutter layer for a specific sensor type.
- **SensorConfiguration**: Settings controlling sensor behavior, including sampling interval and sensor type selection.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users experience no perceptible difference in sensor data quality or responsiveness compared to the previous implementation.
- **SC-002**: Sensor data delivery latency from hardware to UI is within 10 ms of the previous sensors_plus implementation.
- **SC-003**: No sensor listener leaks — all native listeners are released within 1 second of the Flutter stream being cancelled or the activity being stopped.
- **SC-004**: The sensors_plus dependency is fully removed from the project with zero remaining references in application code.
- **SC-005**: Adding a new sensor type requires no modifications to existing sensor channel implementations.
- **SC-006**: The application builds and runs successfully on Android devices running API level 21 and above.

## Assumptions

- The application targets Android only for this feature; iOS support via native implementation is out of scope.
- The existing Flutter UI and state management (Cubit) architecture will be preserved — only the data source layer changes.
- The device running the app has at least an accelerometer sensor; gyroscope availability may vary.
- The existing SensorService class will be refactored to consume native EventChannel streams instead of sensors_plus streams, maintaining its public API contract.
- The project already uses a FlutterActivity-based MainActivity that can be extended to register platform channels.
- Standard Android SensorManager APIs provide sufficient accuracy and sampling rate for tennis swing detection at 20 Hz.
