import 'package:equatable/equatable.dart';

class Lap extends Equatable {
  final int index;
  final Duration lapTime;
  final Duration cumulativeTime;

  const Lap({
    required this.index,
    required this.lapTime,
    required this.cumulativeTime,
  });

  @override
  List<Object?> get props => [index, lapTime, cumulativeTime];
}
