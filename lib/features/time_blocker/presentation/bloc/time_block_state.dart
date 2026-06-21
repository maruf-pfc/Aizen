import 'package:equatable/equatable.dart';
import '../../domain/entities/time_block.dart';

enum TimeBlockStatus { initial, loading, success, failure }

class TimeBlockState extends Equatable {
  final TimeBlockStatus status;
  final DateTime selectedDay;
  final List<TimeBlock> blocks;
  final String? errorMessage;

  const TimeBlockState({
    this.status = TimeBlockStatus.initial,
    required this.selectedDay,
    this.blocks = const [],
    this.errorMessage,
  });

  /// Returns the block currently containing [now], or null.
  TimeBlock? get activeNow {
    final now = DateTime.now();
    for (final b in blocks) {
      if (b.isNow(now)) return b;
    }
    return null;
  }

  /// Returns true if [hour] is covered by any existing block.
  bool isHourClaimed(int hour) {
    return blocks.any((b) => hour >= b.startHour && hour < b.endHour);
  }

  /// Returns the block that contains [hour], or null.
  TimeBlock? blockAt(int hour) {
    for (final b in blocks) {
      if (hour >= b.startHour && hour < b.endHour) return b;
    }
    return null;
  }

  /// Total hours claimed today.
  int get claimedHours =>
      blocks.fold(0, (sum, b) => sum + b.durationHours);

  TimeBlockState copyWith({
    TimeBlockStatus? status,
    DateTime? selectedDay,
    List<TimeBlock>? blocks,
    String? errorMessage,
  }) {
    return TimeBlockState(
      status: status ?? this.status,
      selectedDay: selectedDay ?? this.selectedDay,
      blocks: blocks ?? this.blocks,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, selectedDay, blocks, errorMessage];
}
