import '../models/swing_data.dart';


sealed class SwingState {
  const SwingState();
}


class SwingInitial extends SwingState {
  const SwingInitial();
}


class SwingRecording extends SwingState {

  final SwingData data;

  const SwingRecording({required this.data});
}


class SwingStopped extends SwingState {

  final SwingData data;

  const SwingStopped({required this.data});
}
