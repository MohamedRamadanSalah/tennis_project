import '../models/swing_data.dart';

/// ============================================================
/// SwingState
/// ============================================================
/// Represents every possible state the Swing feature can be in.
///
/// WHY sealed classes?
/// - `sealed` means ONLY the subclasses listed in this file can
///   extend SwingState. This lets Dart's switch/when expressions
///   guarantee you handle every case — no surprises at runtime.
/// - Each subclass carries exactly the data relevant to that state.
///
/// STATE DIAGRAM:
///   SwingInitial  →  SwingRecording  →  SwingStopped
///        ↑                                    │
///        └────────────── (reset) ─────────────┘
/// ============================================================

sealed class SwingState {
  const SwingState();
}

/// The starting state — sensors are idle, no data yet.
class SwingInitial extends SwingState {
  const SwingInitial();
}

/// Sensors are active and data is streaming in.
class SwingRecording extends SwingState {
  /// The latest sensor reading.
  final SwingData data;

  const SwingRecording({required this.data});
}

/// The user stopped recording. We keep the last reading so the
/// UI can still display the final results.
class SwingStopped extends SwingState {
  /// The final sensor reading captured before stopping.
  final SwingData data;

  const SwingStopped({required this.data});
}
