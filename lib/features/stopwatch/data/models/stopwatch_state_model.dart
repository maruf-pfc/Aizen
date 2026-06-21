import '../../domain/entities/stopwatch_state.dart';

class StopwatchStateModel extends StopwatchStateEntity {
  const StopwatchStateModel({
    required super.elapsedTime,
    required super.isRunning,
    super.startTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'elapsedTimeMs': elapsedTime.inMilliseconds,
      'isRunning': isRunning,
      'startTimeIso': startTime?.toIso8601String(),
    };
  }

  factory StopwatchStateModel.fromJson(Map<String, dynamic> json) {
    final startTimeStr = json['startTimeIso'] as String?;
    return StopwatchStateModel(
      elapsedTime: Duration(milliseconds: json['elapsedTimeMs'] as int),
      isRunning: json['isRunning'] as bool,
      startTime: startTimeStr != null ? DateTime.parse(startTimeStr) : null,
    );
  }

  factory StopwatchStateModel.fromEntity(StopwatchStateEntity entity) {
    return StopwatchStateModel(
      elapsedTime: entity.elapsedTime,
      isRunning: entity.isRunning,
      startTime: entity.startTime,
    );
  }
}
