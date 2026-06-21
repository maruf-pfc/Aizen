import 'package:equatable/equatable.dart';

class StopwatchStateEntity extends Equatable {
  final Duration elapsedTime;
  final bool isRunning;
  final DateTime? startTime;

  const StopwatchStateEntity({
    required this.elapsedTime,
    required this.isRunning,
    this.startTime,
  });

  @override
  List<Object?> get props => [elapsedTime, isRunning, startTime];
}
