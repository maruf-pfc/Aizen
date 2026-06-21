import 'package:equatable/equatable.dart';

/// A single claimed block of the 24-hour day. Blocks are aligned to whole
/// hours by convention but the entity supports minute-level granularity.
class TimeBlock extends Equatable {
  final String id;
  final String label;
  final int startHour;   // 0..23
  final int endHour;     // 1..24 (exclusive)
  final String color;    // hex string like '7C4DFF'
  final DateTime createdAt;
  final bool completed;

  const TimeBlock({
    required this.id,
    required this.label,
    required this.startHour,
    required this.endHour,
    required this.color,
    required this.createdAt,
    this.completed = false,
  });

  int get durationHours => endHour - startHour;

  /// True if [now] falls inside this block (hour-precision).
  bool isNow(DateTime now) {
    final h = now.hour;
    return h >= startHour && h < endHour;
  }

  /// Fraction (0..1) of this block that has already elapsed, relative to
  /// [now]. Returns 0 for blocks in the future and 1 for blocks in the past.
  double elapsedFraction(DateTime now) {
    final start = DateTime(now.year, now.month, now.day, startHour);
    final end = DateTime(now.year, now.month, now.day, endHour);
    if (now.isBefore(start)) return 0;
    if (now.isAfter(end)) return 1;
    return now.difference(start).inSeconds / end.difference(start).inSeconds;
  }

  TimeBlock copyWith({
    String? id,
    String? label,
    int? startHour,
    int? endHour,
    String? color,
    DateTime? createdAt,
    bool? completed,
  }) {
    return TimeBlock(
      id: id ?? this.id,
      label: label ?? this.label,
      startHour: startHour ?? this.startHour,
      endHour: endHour ?? this.endHour,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      completed: completed ?? this.completed,
    );
  }

  factory TimeBlock.fromJson(Map<String, dynamic> json) {
    return TimeBlock(
      id: json['id'] as String,
      label: json['label'] as String,
      startHour: (json['startHour'] as num).toInt(),
      endHour: (json['endHour'] as num).toInt(),
      color: json['color'] as String? ?? '7C4DFF',
      createdAt: DateTime.parse(json['createdAt'] as String),
      completed: (json['completed'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'startHour': startHour,
        'endHour': endHour,
        'color': color,
        'createdAt': createdAt.toIso8601String(),
        'completed': completed,
      };

  @override
  List<Object?> get props =>
      [id, label, startHour, endHour, color, createdAt, completed];
}
