import 'package:equatable/equatable.dart';

abstract class TimeBlockEvent extends Equatable {
  const TimeBlockEvent();
  @override
  List<Object?> get props => [];
}

class LoadDayEvent extends TimeBlockEvent {
  final DateTime day;
  const LoadDayEvent(this.day);

  @override
  List<Object?> get props => [day];
}

class ChangeSelectedDayEvent extends TimeBlockEvent {
  final DateTime day;
  const ChangeSelectedDayEvent(this.day);

  @override
  List<Object?> get props => [day];
}

class ClaimHoursEvent extends TimeBlockEvent {
  final int startHour;
  final int endHour;
  final String label;
  final String color;
  const ClaimHoursEvent({
    required this.startHour,
    required this.endHour,
    required this.label,
    required this.color,
  });

  @override
  List<Object?> get props => [startHour, endHour, label, color];
}

class UpdateBlockEvent extends TimeBlockEvent {
  final String id;
  final String? label;
  final String? color;
  const UpdateBlockEvent({required this.id, this.label, this.color});

  @override
  List<Object?> get props => [id, label, color];
}

class DeleteBlockEvent extends TimeBlockEvent {
  final String id;
  const DeleteBlockEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class ToggleBlockCompletedEvent extends TimeBlockEvent {
  final String id;
  const ToggleBlockCompletedEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class ClearDayEvent extends TimeBlockEvent {
  const ClearDayEvent();
}
