import 'package:equatable/equatable.dart';
import 'tag.dart';

class NlpParsedResult extends Equatable {
  final String title;
  final DateTime? dueDate;
  final int priority;
  final List<Tag> tags;

  const NlpParsedResult({
    required this.title,
    this.dueDate,
    this.priority = 4,
    this.tags = const [],
  });

  @override
  List<Object?> get props => [title, dueDate, priority, tags];
}
