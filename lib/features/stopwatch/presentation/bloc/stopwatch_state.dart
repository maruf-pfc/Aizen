import 'package:equatable/equatable.dart';
import '../../domain/entities/lap.dart';

enum StopwatchStatus { initial, loading, paused, running, failure }

class StopwatchState extends Equatable {
  final StopwatchStatus status;
  final Duration elapsedTime;
  final DateTime? startTime;
  final List<Lap> laps;
  final String? errorMessage;

  const StopwatchState({
    this.status = StopwatchStatus.initial,
    this.elapsedTime = Duration.zero,
    this.startTime,
    this.laps = const [],
    this.errorMessage,
  });

  bool get isRunning => status == StopwatchStatus.running;

  Duration get currentDuration {
    if (status == StopwatchStatus.running && startTime != null) {
      return elapsedTime + DateTime.now().difference(startTime!);
    }
    return elapsedTime;
  }

  StopwatchState copyWith({
    StopwatchStatus? status,
    Duration? elapsedTime,
    DateTime? Function()? startTime,
    List<Lap>? laps,
    String? errorMessage,
  }) {
    return StopwatchState(
      status: status ?? this.status,
      elapsedTime: elapsedTime ?? this.elapsedTime,
      startTime: startTime != null ? startTime() : this.startTime,
      laps: laps ?? this.laps,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, elapsedTime, startTime, laps, errorMessage];
}
