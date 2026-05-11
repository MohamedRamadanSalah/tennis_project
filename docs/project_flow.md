# Application Flow

## Overview

This document explains **what happens** when the user opens the app and performs a tennis swing analysis, step by step. It traces the flow of data from the moment the app starts to the moment the user sees results on screen.

---

## 1. App Startup Flow

When the user taps the app icon, here is what happens:

```
User taps app icon
       │
       ▼
┌──────────────────────────────────────────────┐
│  main() function in main.dart executes       │
│                                              │
│  1. WidgetsFlutterBinding.ensureInitialized() │
│     → Prepares the Flutter engine            │
│                                              │
│  2. SystemChrome.setPreferredOrientations()   │
│     → Locks screen to portrait mode          │
│                                              │
│  3. runApp(TennisSwingAnalyzerApp())          │
│     → Starts the widget tree                 │
└──────────────────┬───────────────────────────┘
                   │
                   ▼
┌──────────────────────────────────────────────┐
│  TennisSwingAnalyzerApp widget builds        │
│                                              │
│  1. BlocProvider creates:                     │
│     → SensorService instance                 │
│     → SwingCubit instance (receives service) │
│                                              │
│  2. MaterialApp configures:                   │
│     → App theme (colors, fonts)              │
│     → Initial route → SwingScreen            │
└──────────────────┬───────────────────────────┘
                   │
                   ▼
┌──────────────────────────────────────────────┐
│  SwingScreen renders                         │
│                                              │
│  Initial state: SwingInitial                 │
│  → Status badge shows "Ready" (blue)         │
│  → All metric cards show 0.00               │
│  → Button shows "Start Recording"            │
└──────────────────────────────────────────────┘
```

---

## 2. Recording Flow (User Presses "Start Recording")

```
User taps "Start Recording"
       │
       ▼
┌───────────────────────────────────────────────────────┐
│  SwingScreen calls cubit.startRecording()             │
└──────────────────────┬────────────────────────────────┘
                       │
                       ▼
┌───────────────────────────────────────────────────────┐
│  SwingCubit.startRecording()                          │
│                                                       │
│  1. Calls _sensorService.startListening()             │
│     → Activates accelerometer subscription            │
│     → Activates gyroscope subscription                │
│                                                       │
│  2. Subscribes to _sensorService.swingDataStream      │
│     → Every new SwingData triggers an emit            │
└──────────────────────┬────────────────────────────────┘
                       │
                       ▼
┌───────────────────────────────────────────────────────┐
│  SensorService starts listening                       │
│                                                       │
│  Every 50ms (20 times per second):                    │
│                                                       │
│  Accelerometer fires → updates _accelX, Y, Z          │
│       │                                               │
│       ├─→ acceleration = √(x² + y² + z²)             │
│       ├─→ force = mass × acceleration                 │
│       └─→ Emits SwingData on the stream               │
│                                                       │
│  Gyroscope fires → updates _gyroX, Y, Z               │
│       │                                               │
│       └─→ Accumulates rotation angle                  │
└──────────────────────┬────────────────────────────────┘
                       │ SwingData arrives
                       ▼
┌───────────────────────────────────────────────────────┐
│  SwingCubit receives SwingData                        │
│                                                       │
│  Emits: SwingRecording(data: swingData)               │
└──────────────────────┬────────────────────────────────┘
                       │ state changes
                       ▼
┌───────────────────────────────────────────────────────┐
│  BlocBuilder in SwingScreen detects new state         │
│                                                       │
│  UI rebuilds:                                         │
│  → Status badge: "Recording" (red, pulsing dot)       │
│  → Acceleration card: live value in m/s²              │
│  → Force card: live value in Newtons                  │
│  → Rotation card: live value in degrees               │
│  → Button changes to: "Stop Recording" (red)          │
└───────────────────────────────────────────────────────┘
```

---

## 3. Stop Flow (User Presses "Stop Recording")

```
User taps "Stop Recording"
       │
       ▼
┌───────────────────────────────────────────────────────┐
│  SwingScreen calls cubit.stopRecording()              │
└──────────────────────┬────────────────────────────────┘
                       │
                       ▼
┌───────────────────────────────────────────────────────┐
│  SwingCubit.stopRecording()                           │
│                                                       │
│  1. Cancels stream subscription (stops listening)     │
│  2. Calls _sensorService.stopListening()              │
│     → Cancels accelerometer subscription              │
│     → Cancels gyroscope subscription                  │
│  3. Emits: SwingStopped(data: lastRecordedData)       │
└──────────────────────┬────────────────────────────────┘
                       │ state changes
                       ▼
┌───────────────────────────────────────────────────────┐
│  UI rebuilds:                                         │
│  → Status badge: "Stopped" (orange)                   │
│  → Metric cards: frozen at last recorded values       │
│  → Button changes to: "New Swing" (green)             │
└───────────────────────────────────────────────────────┘
```

---

## 4. Reset Flow (User Presses "New Swing")

```
User taps "New Swing"
       │
       ▼
┌───────────────────────────────────────────────────────┐
│  SwingScreen calls cubit.reset()                      │
└──────────────────────┬────────────────────────────────┘
                       │
                       ▼
┌───────────────────────────────────────────────────────┐
│  SwingCubit.reset()                                   │
│                                                       │
│  1. Cancels any active subscription                   │
│  2. Calls _sensorService.stopListening()              │
│  3. Calls _sensorService.reset()                      │
│     → Zeroes out all accumulated values               │
│     → Emits SwingData.empty() on the stream           │
│  4. Emits: SwingInitial()                             │
└──────────────────────┬────────────────────────────────┘
                       │ state changes
                       ▼
┌───────────────────────────────────────────────────────┐
│  UI rebuilds:                                         │
│  → Back to initial state                              │
│  → Status badge: "Ready" (blue)                       │
│  → All metric cards: 0.00                             │
│  → Button: "Start Recording"                          │
└───────────────────────────────────────────────────────┘
```

---

## 5. State Machine Summary

The entire app has only **three states** with **three transitions**:

```
                startRecording()
  ┌──────────┐ ──────────────────→ ┌──────────────┐
  │  Initial  │                    │  Recording    │
  │  (Ready)  │                    │  (Live data)  │
  └──────────┘ ←──────────────────  └──────┬───────┘
       ▲           reset()                 │
       │                                   │ stopRecording()
       │                                   ▼
       │                           ┌──────────────┐
       └────── reset() ───────────│   Stopped     │
                                   │  (Final data) │
                                   └──────────────┘
```

| State | Badge | Cards Show | Button |
|-------|-------|------------|--------|
| `SwingInitial` | 🔵 Ready | All zeros | ▶ Start Recording |
| `SwingRecording` | 🔴 Recording | Live values | ⏹ Stop Recording |
| `SwingStopped` | 🟠 Stopped | Frozen values | 🔄 New Swing |

---

## 6. Data Flow Summary (One Line)

```
Phone Sensors → SensorService → Stream<SwingData> → SwingCubit → SwingState → BlocBuilder → UI
```

This is a **unidirectional data flow**:
- Data flows in **one direction** from sensors to UI.
- User actions flow **back** through method calls to the Cubit.
- The UI **never** reads from sensors directly — it only reads from the Cubit's state.

This makes the app predictable: if you know the current state, you know exactly what the UI looks like.
