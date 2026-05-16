package com.example.flutter_project

import android.content.Context
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.util.Log
import io.flutter.plugin.common.EventChannel

/**
 * SensorStreamHandler
 * ===================
 * A reusable [EventChannel.StreamHandler] that bridges any 3-axis Android
 * hardware sensor (accelerometer, gyroscope, magnetometer, …) to a Flutter
 * EventChannel stream.
 *
 * Architecture
 * ------------
 * - One instance per sensor type, created in [MainActivity.configureFlutterEngine].
 * - Sensor registration happens in [onListen] — exactly when Flutter subscribes.
 * - Sensor unregistration happens in [onCancel] — exactly when Flutter cancels.
 * - This ensures there are zero listener leaks: the native sensor is active only
 *   while Dart is actively listening to the EventChannel stream.
 *
 * Extension
 * ---------
 * To expose a new sensor, create a new EventChannel in MainActivity and pass
 * the desired [Sensor.TYPE_*] constant to this constructor. No changes to this
 * class are needed.
 *
 * @param context          Android context (used to obtain the SensorManager).
 * @param sensorType       One of the [Sensor.TYPE_*] constants, e.g.
 *                         [Sensor.TYPE_LINEAR_ACCELERATION] or [Sensor.TYPE_GYROSCOPE].
 * @param samplingPeriodUs Desired sampling period in **microseconds**. The OS
 *                         will honour this as a hint; actual delivery may vary.
 *                         Example: 50 ms = 50_000 µs.
 */
class SensorStreamHandler(
    private val context: Context,
    private val sensorType: Int,
    private val samplingPeriodUs: Int,
) : EventChannel.StreamHandler, SensorEventListener {

    companion object {
        private const val TAG = "SensorStreamHandler"
        private const val ERROR_SENSOR_UNAVAILABLE = "SENSOR_UNAVAILABLE"
    }

    // Held while Flutter is subscribed; null otherwise.
    private var eventSink: EventChannel.EventSink? = null

    // Lazy reference to SensorManager — obtained once per onListen call.
    private var sensorManager: SensorManager? = null

    // Flag to limit first-event logging (avoids log spam at 20 Hz).
    private var firstEventLogged = false

    // ── EventChannel.StreamHandler ────────────────────────────────────────────

    /**
     * Called by Flutter when the Dart side subscribes to the EventChannel stream
     * (e.g. via [EventChannel.receiveBroadcastStream().listen(...)]).
     *
     * Registers the sensor listener. If the requested sensor is not available on
     * this device, an error is sent through the sink instead of crashing.
     */
    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
        firstEventLogged = false

        sensorManager = context.getSystemService(Context.SENSOR_SERVICE) as SensorManager
        val sensor = sensorManager?.getDefaultSensor(sensorType)

        if (sensor == null) {
            val message = "Sensor type $sensorType is not available on this device."
            Log.w(TAG, "[$sensorType] $message")
            eventSink?.error(ERROR_SENSOR_UNAVAILABLE, message, null)
            return
        }

        sensorManager?.registerListener(this, sensor, samplingPeriodUs)
        Log.d(TAG, "[$sensorType] Sensor listener registered (period=${samplingPeriodUs}µs).")
    }

    /**
     * Called by Flutter when the Dart-side subscription is cancelled
     * (e.g. [StreamSubscription.cancel()] or stream disposal).
     *
     * Unregisters the sensor listener immediately so no further events are
     * delivered and the hardware can return to its idle power state.
     */
    override fun onCancel(arguments: Any?) {
        sensorManager?.unregisterListener(this)
        sensorManager = null
        eventSink = null
        Log.d(TAG, "[$sensorType] Sensor listener unregistered.")
    }

    // ── SensorEventListener ───────────────────────────────────────────────────

    /**
     * Called by the Android sensor framework whenever a new sensor reading is
     * ready. The three axis values are forwarded to Flutter as a [List<Double>].
     *
     * Wire format: [x, y, z]
     *   - Accelerometer (TYPE_LINEAR_ACCELERATION): m/s², gravity removed.
     *   - Gyroscope     (TYPE_GYROSCOPE)           : rad/s, angular velocity.
     */
    override fun onSensorChanged(event: SensorEvent?) {
        val sink = eventSink ?: return
        val values = event?.values ?: return

        // Log only the very first event to confirm data is flowing.
        if (!firstEventLogged) {
            Log.d(TAG, "[$sensorType] First event: x=${values[0]}, y=${values[1]}, z=${values[2]}")
            firstEventLogged = true
        }

        sink.success(
            listOf(
                values[0].toDouble(),
                values[1].toDouble(),
                values[2].toDouble(),
            )
        )
    }

    /**
     * Called when the sensor accuracy changes. Not used for this feature, but
     * required by [SensorEventListener].
     */
    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {
        // No-op — accuracy changes do not affect swing analysis.
    }
}
