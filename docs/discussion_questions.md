# Discussion Questions & Answers

Prepared answers for university viva / project discussion.

---

## 1. Architecture & Design

### Q: Why did you choose feature-based architecture instead of type-based?

**A:** Feature-based groups all related files (model, service, logic, UI) inside one folder per feature. This makes the codebase easier to navigate — when working on the "swing" feature, everything is in `features/swing/`. It also improves scalability: adding a "history" feature means creating `features/history/` without touching existing code. In contrast, type-based architecture scatters one feature across multiple folders (all models in `/models`, all screens in `/screens`), making it harder to trace feature-specific code.

### Q: Why did you use Cubit instead of full Bloc?

**A:** Cubit is a simplified version of Bloc. With Cubit, you call methods directly (`cubit.startRecording()`), while Bloc requires creating event classes (`bloc.add(StartRecordingEvent())`). Since our app has only three simple actions (start, stop, reset), Cubit reduces boilerplate without sacrificing functionality. For a more complex app with many event types or event transformations, full Bloc would be more appropriate.

### Q: What is a sealed class and why did you use it for states?

**A:** A `sealed` class restricts which subclasses can extend it — only classes in the same file are allowed. We used it for `SwingState` so that Dart knows all possible states at compile time. This means `switch` expressions must handle every state, and the compiler gives an error if one is missing. It prevents bugs where a new state is added but the UI forgets to handle it.

### Q: How does dependency injection work in your project?

**A:** The `SwingCubit` receives its `SensorService` through its constructor instead of creating it internally. This is constructor-based dependency injection. It provides two benefits: (1) the Cubit doesn't need to know how to create a SensorService, and (2) during testing, we can pass in a mock SensorService that returns fake data, so we can test the Cubit without real phone sensors.

---

## 2. Sensors & Physics

### Q: Why did you use `userAccelerometerEventStream` instead of `accelerometerEventStream`?

**A:** The standard `accelerometerEventStream` includes gravitational acceleration (~9.8 m/s²), which means the phone reports acceleration even when sitting still on a table. `userAccelerometerEventStream` subtracts gravity, giving us only the acceleration caused by the user's hand movement. This is what we need to measure swing intensity.

### Q: How do you calculate the total acceleration from three axis values?

**A:** We compute the Euclidean magnitude: `a = √(x² + y² + z²)`. This combines the three directional components into a single scalar value representing the overall intensity of movement, regardless of direction. It's the 3D equivalent of the Pythagorean theorem.

### Q: Explain the force calculation (F = m × a).

**A:** Newton's Second Law states that force equals mass times acceleration. In our app:
- **m** = 0.300 kg (default tennis racket mass, stored in `app_constants.dart`)
- **a** = acceleration magnitude from the accelerometer

For example, if acceleration is 9.06 m/s², then F = 0.300 × 9.06 = 2.72 Newtons.

### Q: How do you calculate rotation angle from the gyroscope?

**A:** The gyroscope gives angular velocity in radians/second, not angle. We integrate over time:
1. Calculate angular speed: `ω = √(gyroX² + gyroY² + gyroZ²)`
2. Multiply by time interval: `Δθ = ω × Δt`
3. Convert radians to degrees: `Δθ_degrees = Δθ × (180/π)`
4. Accumulate: `total_angle += Δθ_degrees`

This is numerical integration using the rectangle method.

### Q: What is sensor drift and how does it affect your app?

**A:** Gyroscope readings have small errors in each measurement. Because we accumulate rotation over time, these errors compound — the reported angle slowly drifts away from the true angle. For short recordings (a few seconds), this is negligible. For longer recordings, the drift becomes noticeable. Production apps solve this with sensor fusion (combining gyroscope with accelerometer data using algorithms like a Kalman filter).

---

## 3. State Management

### Q: What are the three states in your app and when does each occur?

**A:**

| State | When | Contains |
|-------|------|----------|
| `SwingInitial` | App just opened, or after reset | No data |
| `SwingRecording` | User pressed "Start Recording" | Live `SwingData` |
| `SwingStopped` | User pressed "Stop Recording" | Final `SwingData` |

### Q: How does the UI react to state changes?

**A:** The `SwingScreen` uses a `BlocBuilder` widget that listens to the `SwingCubit`. Whenever the Cubit emits a new state, BlocBuilder rebuilds its child widget tree. Inside the builder, Dart's `switch` expression checks the state type and renders the appropriate UI: different badge colors, button labels, and metric values for each state.

### Q: What is the difference between `BlocBuilder` and `BlocListener`?

**A:** `BlocBuilder` rebuilds the UI whenever the state changes — it's for visual updates. `BlocListener` triggers a one-time side effect (like showing a snackbar or navigating) without rebuilding the UI. We use `BlocBuilder` because we want the UI to visually reflect every state change.

---

## 4. Flutter & Dart Concepts

### Q: Why did you lock the screen to portrait mode?

**A:** Since the user holds the phone like a tennis racket to simulate a swing, rotating to landscape would disrupt the experience and the sensor axis alignment. We lock to portrait in `main.dart` using `SystemChrome.setPreferredOrientations`.

### Q: What does `StreamController.broadcast()` do and why did you use it?

**A:** A regular `StreamController` allows only one listener. A `broadcast` controller allows multiple listeners. We used broadcast so that both the Cubit and potentially unit tests can listen to the sensor data stream simultaneously.

### Q: Why is `SwingData` immutable (all fields are `final`)?

**A:** Immutability means once a `SwingData` object is created, it cannot be changed. This is important in state management because:
1. It prevents accidental modifications to shared state.
2. Each state emission is a brand new object, making state changes clear and traceable.
3. Dart and Flutter can optimize rebuilds when they know objects don't mutate.

### Q: What does `BlocProvider` do in `main.dart`?

**A:** `BlocProvider` creates a `SwingCubit` instance and makes it available to the entire widget tree below it via Flutter's `InheritedWidget` mechanism. Any descendant widget can access the Cubit using `context.read<SwingCubit>()`. When the provider is removed from the tree, it automatically disposes the Cubit.

---

## 5. Project Decisions

### Q: Why is this app fully offline?

**A:** The app reads sensor data from the phone's hardware, performs calculations locally, and displays results on screen. No external API, database, or internet connection is needed. This makes the app simpler, faster, more private, and usable anywhere — including areas with no internet.

### Q: What would you add if you had more time?

**A:**
1. **Swing history** — save past swings to local storage (using SQLite or Hive)
2. **Charts** — visualize acceleration over time using `fl_chart`
3. **Adjustable mass** — let users input their racket's actual mass
4. **Swing classification** — detect forehand vs. backhand using ML
5. **Sensor calibration** — zero out sensors before recording
6. **Dark mode** — add a dark theme toggle

### Q: Why didn't you use a database?

**A:** The current version analyzes swings in real-time without saving history. Adding a database would increase complexity without serving the core educational purpose. However, the architecture supports it easily — we would add a `repository/` layer inside `features/swing/` that saves `SwingData` to local storage.

### Q: How would you test this app?

**A:**
- **Unit tests:** Test `SwingCubit` with a mocked `SensorService` that emits predefined `SwingData` values
- **Widget tests:** Verify that the UI shows correct values for each state
- **Integration tests:** Run on a physical device and verify sensor readings appear
- **Manual testing:** Shake the phone and confirm the values change in real-time
