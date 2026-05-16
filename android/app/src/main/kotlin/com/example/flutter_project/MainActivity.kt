package com.example.flutter_project

import android.hardware.Sensor
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel

/**
 * MainActivity
 * ============
 * Entry point for the Flutter/Android application.
 *
 * Platform Channels registered here
 * ----------------------------------
 * Two [EventChannel]s are registered to stream native sensor data to Flutter:
 *
 *   • com.example.flutter_project/accelerometer
 *       Sensor.TYPE_LINEAR_ACCELERATION — linear acceleration with gravity removed.
 *       Matches the previous sensors_plus userAccelerometerEventStream() behaviour.
 *
 *   • com.example.flutter_project/gyroscope
 *       Sensor.TYPE_GYROSCOPE — angular velocity in rad/s around each axis.
 *
 * Sampling rate: 50,000 µs (50 ms / 20 Hz) — same as the previous sensors_plus
 * configuration defined in AppConstants.sensorIntervalMs.
 *
 * Extensibility
 * -------------
 * To add a new sensor (e.g. magnetometer), register one more EventChannel:
 *
 *     EventChannel(messenger, "com.example.flutter_project/magnetometer")
 *         .setStreamHandler(
 *             SensorStreamHandler(this, Sensor.TYPE_MAGNETIC_FIELD, SAMPLING_PERIOD_US)
 *         )
 *
 * Then expose a matching Stream<List<double>> on the Dart side via EventChannel.
 * No modifications to SensorStreamHandler or existing channels are needed.
 */
class MainActivity : FlutterActivity() {

    companion object {
        /** Sampling period in microseconds: 50 ms = 50,000 µs = 20 Hz. */
        private const val SAMPLING_PERIOD_US = 50_000

        // Channel names must match those used in sensor_service.dart.
        private const val ACCELEROMETER_CHANNEL = "com.example.flutter_project/accelerometer"
        private const val GYROSCOPE_CHANNEL = "com.example.flutter_project/gyroscope"
    }

    /**
     * Called by the Flutter engine once it has been created and attached to this
     * activity. This is the correct place to register platform channels.
     */
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val messenger = flutterEngine.dartExecutor.binaryMessenger

        // ── Accelerometer (gravity-removed linear acceleration) ──────────────
        EventChannel(messenger, ACCELEROMETER_CHANNEL)
            .setStreamHandler(
                SensorStreamHandler(
                    context = this,
                    sensorType = Sensor.TYPE_LINEAR_ACCELERATION,
                    samplingPeriodUs = SAMPLING_PERIOD_US,
                )
            )

        // ── Gyroscope (angular velocity) ──────────────────────────────────────
        EventChannel(messenger, GYROSCOPE_CHANNEL)
            .setStreamHandler(
                SensorStreamHandler(
                    context = this,
                    sensorType = Sensor.TYPE_GYROSCOPE,
                    samplingPeriodUs = SAMPLING_PERIOD_US,
                )
            )

        // ── Extension pattern (US3) ───────────────────────────────────────────
        // To add a new sensor, copy the block below, uncomment it, and choose
        // the appropriate Sensor.TYPE_* constant. Then expose a matching
        // EventChannel stream on the Dart side in sensor_service.dart.
        // No changes to SensorStreamHandler are needed.
        //
        // Example: Magnetometer
        //
        // EventChannel(messenger, "com.example.flutter_project/magnetometer")
        //     .setStreamHandler(
        //         SensorStreamHandler(
        //             context = this,
        //             sensorType = Sensor.TYPE_MAGNETIC_FIELD,
        //             samplingPeriodUs = SAMPLING_PERIOD_US,
        //         )
        //     )
    }
}
