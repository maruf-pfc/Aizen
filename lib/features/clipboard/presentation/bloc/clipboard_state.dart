import 'package:equatable/equatable.dart';
import '../../domain/entities/clipboard_item.dart';

enum ClipboardStatus { initial, loading, success, failure }
enum ClipboardFilter { all, link, snippet, plain }

class ClipboardState extends Equatable {
  final ClipboardStatus status;
  final List<ClipboardItem> items;
  final ClipboardFilter filter;
  final String? errorMessage;

  const ClipboardState({
    this.status = ClipboardStatus.initial,
    this.items = const [],
    this.filter = ClipboardFilter.all,
    this.errorMessage,
  });

  List<ClipboardItem> get filtered {
    if (filter == ClipboardFilter.all) return items;
    return items.where((i) => i.kind.name == filter.name).toList();
  }

  int get totalLinks => items.where((i) => i.kind == ClipboardKind.link).length;
  int get totalSnippets =>
      items.where((i) => i.kind == ClipboardKind.snippet).length;
  int get totalPlain => items.where((i) => i.kind == ClipboardKind.plain).length;

  ClipboardState copyWith({
    ClipboardStatus? status,
    List<ClipboardItem>? items,
    ClipboardFilter? filter,
    String? errorMessage,
  }) {
    return ClipboardState(
      status: status ?? this.status,
      items: items ?? this.items,
      filter: filter ?? this.filter,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, items, filter, errorMessage];
}
