import 'package:equatable/equatable.dart';

abstract class StopwatchEvent extends Equatable {
  const StopwatchEvent();

  @override
  List<Object?> get props => [];
}

class LoadStopwatchDataEvent extends StopwatchEvent {
  const LoadStopwatchDataEvent();
}

class StartStopwatchEvent extends StopwatchEvent {
  const StartStopwatchEvent();
}

class PauseStopwatchEvent extends StopwatchEvent {
  const PauseStopwatchEvent();
}

class ResetStopwatchEvent extends StopwatchEvent {
  const ResetStopwatchEvent();
}

class AddLapEvent extends StopwatchEvent {
  const AddLapEvent();
}
