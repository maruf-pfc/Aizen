import '../../domain/entities/lap.dart';

class LapModel extends Lap {
  const LapModel({
    required super.index,
    required super.lapTime,
    required super.cumulativeTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'index': index,
      'lapTimeMs': lapTime.inMilliseconds,
      'cumulativeTimeMs': cumulativeTime.inMilliseconds,
    };
  }

  factory LapModel.fromJson(Map<String, dynamic> json) {
    return LapModel(
      index: json['index'] as int,
      lapTime: Duration(milliseconds: json['lapTimeMs'] as int),
      cumulativeTime: Duration(milliseconds: json['cumulativeTimeMs'] as int),
    );
  }

  factory LapModel.fromEntity(Lap entity) {
    return LapModel(
      index: entity.index,
      lapTime: entity.lapTime,
      cumulativeTime: entity.cumulativeTime,
    );
  }
}
