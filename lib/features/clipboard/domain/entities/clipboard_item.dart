import 'package:equatable/equatable.dart';

/// A single item cached from the user's clipboard.
class ClipboardItem extends Equatable {
  final String id;
  final String content;
  final ClipboardKind kind;
  final DateTime copiedAt;
  final bool pinned;

  const ClipboardItem({
    required this.id,
    required this.content,
    required this.kind,
    required this.copiedAt,
    this.pinned = false,
  });

  ClipboardItem copyWith({
    String? id,
    String? content,
    ClipboardKind? kind,
    DateTime? copiedAt,
    bool? pinned,
  }) {
    return ClipboardItem(
      id: id ?? this.id,
      content: content ?? this.content,
      kind: kind ?? this.kind,
      copiedAt: copiedAt ?? this.copiedAt,
      pinned: pinned ?? this.pinned,
    );
  }

  factory ClipboardItem.fromJson(Map<String, dynamic> json) {
    return ClipboardItem(
      id: json['id'] as String,
      content: json['content'] as String,
      kind: ClipboardKind.values.byName(json['kind'] as String),
      copiedAt: DateTime.parse(json['copiedAt'] as String),
      pinned: (json['pinned'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'content': content,
        'kind': kind.name,
        'copiedAt': copiedAt.toIso8601String(),
        'pinned': pinned,
      };

  @override
  List<Object?> get props => [id, content, kind, copiedAt, pinned];
}

enum ClipboardKind { link, snippet, plain }
