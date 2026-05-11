# Architecture Overview

## What is "Architecture" in Software?

Architecture is how we **organize** our code into folders, files, and layers. A good architecture makes code:
- **Easy to read** — new team members understand what each file does
- **Easy to change** — modifying one feature doesn't break another
- **Easy to test** — each piece can be tested independently

## Architecture Used: Clean Feature-Based Architecture

We chose a **feature-based** architecture with **clean separation of concerns**. This means:
1. Code is grouped by **feature** (what it does), not by **type** (what it is).
2. Each feature is split into **layers** with clear responsibilities.

### Why Feature-Based and Not Type-Based?

**Type-based** (❌ what we avoided):
```
lib/
├── models/         ← ALL models from every feature go here
├── screens/        ← ALL screens from every feature go here
├── cubits/         ← ALL cubits from every feature go here
└── services/       ← ALL services from every feature go here
```

**Feature-based** (✅ what we use):
```
lib/
├── features/
│   └── swing/           ← Everything for the Swing feature lives together
│       ├── models/
│       ├── presentation/
│       ├── logic/
│       └── services/
```

**Why is feature-based better?**
- When you work on the "swing" feature, all related files are in one folder.
- If you add a "history" feature later, you create `features/history/` with the same sub-folders — no existing code is touched.
- Deleting a feature is as simple as deleting its folder.

---

## Project Folder Structure

```
lib/
├── main.dart                              ← App entry point
│
├── core/                                  ← Shared infrastructure
│   ├── constants/
│   │   └── app_constants.dart             ← Physics values, sensor config, UI sizes
│   ├── theme/
│   │   └── app_theme.dart                 ← Colors, fonts, component styles
│   └── router/
│       └── app_router.dart                ← Screen navigation routes
│
├── features/                              ← Feature modules
│   └── swing/
│       ├── models/
│       │   └── swing_data.dart            ← Data class for one sensor reading
│       ├── services/
│       │   └── sensor_service.dart        ← Reads from phone hardware sensors
│       ├── logic/
│       │   ├── swing_cubit.dart           ← State management brain
│       │   └── swing_state.dart           ← All possible UI states
│       └── presentation/
│           └── screens/
│               └── swing_screen.dart      ← The main UI screen
│
└── shared/                                ← Reusable widgets
    └── widgets/
        ├── metric_card.dart               ← Card: icon + value + unit
        └── status_badge.dart              ← Pill badge: Ready/Recording/Stopped
```

---

## The Three Main Folders

### 1. `core/` — Shared App Infrastructure

Contains things that are **not specific to any feature** but are used by the entire app:

| Folder | Purpose | Example |
|--------|---------|---------|
| `constants/` | Fixed values used everywhere | Racket mass = 0.3 kg |
| `theme/` | Visual styling (colors, fonts) | Primary color = forest green |
| `router/` | Navigation route definitions | `/` → SwingScreen |

### 2. `features/` — Feature Modules

Each feature is a **self-contained module** with four layers:

| Layer | Responsibility | Knows About |
|-------|---------------|-------------|
| `models/` | Define the shape of data | Nothing (pure data) |
| `services/` | Get data from external sources (sensors) | Models |
| `logic/` | Manage state, connect service to UI | Models + Services |
| `presentation/` | Display data, receive user input | Logic + Models |

**Key rule:** Each layer only knows about the layers **below** it, never above.

```
presentation/  ──→  logic/  ──→  services/  ──→  models/
  (UI)           (Cubit)      (Sensors)       (Data)
```

### 3. `shared/` — Reusable Widgets

Widgets that are **used by multiple features**. In our app:
- `MetricCard` — displays a measurement with icon, value, and unit
- `StatusBadge` — a pill-shaped label showing the current status

---

## Design Decisions Explained

### Why Cubit and Not Full Bloc?

| Cubit | Bloc |
|-------|------|
| Call methods directly: `cubit.start()` | Send event objects: `bloc.add(StartEvent())` |
| Simpler to understand | More boilerplate code |
| Good for straightforward logic | Better for complex event-driven logic |

**Our choice:** Cubit — because our logic is simple (start → record → stop → reset) and this is an educational project.

### Why Sealed Classes for State?

```dart
sealed class SwingState {}

class SwingInitial extends SwingState {}
class SwingRecording extends SwingState { final SwingData data; }
class SwingStopped extends SwingState { final SwingData data; }
```

The `sealed` keyword tells Dart: "These are the **only** possible states." This means:
- The compiler **forces** you to handle every state in `switch` expressions.
- You can never accidentally forget a state — Dart will show an error.
- It documents all possible states in one file.

### Why a Separate SensorService?

Instead of reading sensors directly inside the Cubit, we created a separate `SensorService`. This is called **Separation of Concerns**:

- **SensorService** answers: "How do I read data from hardware?"
- **SwingCubit** answers: "What state should the UI be in?"

If we ever change the sensor library (e.g., replace `sensors_plus` with another package), we only modify `SensorService` — the Cubit and UI are untouched.

---

## How It All Connects

```
┌─────────────────────────────────────────────────────┐
│                    main.dart                        │
│  Creates BlocProvider → SwingCubit(SensorService)   │
│  Creates MaterialApp with theme and routes          │
└──────────────────────┬──────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────┐
│                  SwingScreen (UI)                    │
│  BlocBuilder listens to SwingCubit                  │
│  Shows MetricCards + StatusBadge + Action Buttons    │
│  Calls cubit.startRecording() / stopRecording()     │
└──────────────────────┬──────────────────────────────┘
                       │ calls methods
                       ▼
┌─────────────────────────────────────────────────────┐
│                   SwingCubit                        │
│  Listens to SensorService stream                    │
│  Emits SwingState (Initial / Recording / Stopped)   │
└──────────────────────┬──────────────────────────────┘
                       │ subscribes to stream
                       ▼
┌─────────────────────────────────────────────────────┐
│                 SensorService                       │
│  Reads accelerometer + gyroscope                    │
│  Calculates acceleration, force, rotation           │
│  Emits Stream<SwingData>                            │
└─────────────────────────────────────────────────────┘
```

---

## Summary

| Principle | How We Apply It |
|-----------|----------------|
| **Single Responsibility** | Each file/class has one job |
| **Separation of Concerns** | Service ≠ State ≠ UI |
| **Dependency Injection** | SensorService is passed into the Cubit |
| **Feature Isolation** | All swing code lives in `features/swing/` |
| **Reusability** | Shared widgets in `shared/widgets/` |
