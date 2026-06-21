import 'package:equatable/equatable.dart';
import '../bloc/clipboard_state.dart';

abstract class ClipboardEvent extends Equatable {
  const ClipboardEvent();
  @override
  List<Object?> get props => [];
}

class LoadClipboardEvent extends ClipboardEvent {
  const LoadClipboardEvent();
}

class PushClipboardTextEvent extends ClipboardEvent {
  final String text;
  const PushClipboardTextEvent(this.text);

  @override
  List<Object?> get props => [text];
}

class DeleteClipboardItemEvent extends ClipboardEvent {
  final String id;
  const DeleteClipboardItemEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class TogglePinClipboardItemEvent extends ClipboardEvent {
  final String id;
  const TogglePinClipboardItemEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class ClearAllClipboardEvent extends ClipboardEvent {
  const ClearAllClipboardEvent();
}

class ChangeClipboardFilterEvent extends ClipboardEvent {
  final ClipboardFilter filter;
  const ChangeClipboardFilterEvent(this.filter);

  @override
  List<Object?> get props => [filter];
}
