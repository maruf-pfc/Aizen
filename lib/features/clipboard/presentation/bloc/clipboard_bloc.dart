import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/clipboard_local_data_source.dart';
import '../../domain/entities/clipboard_item.dart';
import '../../domain/services/clipboard_classifier.dart';
import 'clipboard_event.dart';
import 'clipboard_state.dart';

class ClipboardBloc extends Bloc<ClipboardEvent, ClipboardState> {
  final ClipboardLocalDataSource _dataSource;
  final ClipboardClassifier _classifier;
  final Future<String?> Function()? _systemClipboardReader;

  ClipboardBloc({
    required ClipboardLocalDataSource dataSource,
    ClipboardClassifier classifier = const ClipboardClassifier(),
    Future<String?> Function()? systemClipboardReader,
  })  : _dataSource = dataSource,
        _classifier = classifier,
        _systemClipboardReader = systemClipboardReader,
        super(const ClipboardState()) {
    on<LoadClipboardEvent>(_onLoad);
    on<PushClipboardTextEvent>(_onPush);
    on<DeleteClipboardItemEvent>(_onDelete);
    on<TogglePinClipboardItemEvent>(_onTogglePin);
    on<ClearAllClipboardEvent>(_onClearAll);
    on<ChangeClipboardFilterEvent>(_onChangeFilter);
  }

  Future<void> _onLoad(LoadClipboardEvent e, Emitter<ClipboardState> emit) async {
    emit(state.copyWith(status: ClipboardStatus.loading));
    try {
      final items = _dataSource.loadAll();
      // Sort: pinned first, then by copiedAt desc.
      items.sort((a, b) {
        if (a.pinned != b.pinned) return a.pinned ? -1 : 1;
        return b.copiedAt.compareTo(a.copiedAt);
      });
      emit(state.copyWith(status: ClipboardStatus.success, items: items));
    } catch (e) {
      emit(state.copyWith(
        status: ClipboardStatus.failure,
        errorMessage: 'Failed to load clipboard vault: $e',
      ));
    }
  }

  Future<void> _onPush(PushClipboardTextEvent e, Emitter<ClipboardState> emit) async {
    final text = e.text.trim();
    if (text.isEmpty) return;
    final item = ClipboardItem(
      id: _uuid(),
      content: text,
      kind: _classifier.classify(text),
      copiedAt: DateTime.now(),
    );
    final updated = _dataSource.pushAndTrim(item);
    // Re-sort
    updated.sort((a, b) {
      if (a.pinned != b.pinned) return a.pinned ? -1 : 1;
      return b.copiedAt.compareTo(a.copiedAt);
    });
    await _dataSource.saveAll(updated);
    emit(state.copyWith(status: ClipboardStatus.success, items: updated));
  }

  Future<void> _onDelete(
      DeleteClipboardItemEvent e, Emitter<ClipboardState> emit) async {
    final updated = state.items.where((i) => i.id != e.id).toList();
    await _dataSource.saveAll(updated);
    emit(state.copyWith(status: ClipboardStatus.success, items: updated));
  }

  Future<void> _onTogglePin(
      TogglePinClipboardItemEvent e, Emitter<ClipboardState> emit) async {
    final updated = state.items.map((i) {
      if (i.id == e.id) return i.copyWith(pinned: !i.pinned);
      return i;
    }).toList();
    updated.sort((a, b) {
      if (a.pinned != b.pinned) return a.pinned ? -1 : 1;
      return b.copiedAt.compareTo(a.copiedAt);
    });
    await _dataSource.saveAll(updated);
    emit(state.copyWith(status: ClipboardStatus.success, items: updated));
  }

  Future<void> _onClearAll(
      ClearAllClipboardEvent e, Emitter<ClipboardState> emit) async {
    final pinned = state.items.where((i) => i.pinned).toList();
    await _dataSource.saveAll(pinned);
    emit(state.copyWith(
      status: ClipboardStatus.success,
      items: pinned,
    ));
  }

  void _onChangeFilter(
      ChangeClipboardFilterEvent e, Emitter<ClipboardState> emit) {
    emit(state.copyWith(filter: e.filter));
  }

  /// Pull the latest text from the OS clipboard and push it into the vault.
  /// Called by the page when the user taps the "Capture" button.
  Future<void> captureFromSystemClipboard() async {
    try {
      final reader = _systemClipboardReader;
      String? text;
      if (reader != null) {
        text = await reader();
      } else {
        final data = await Clipboard.getData('text/plain');
        text = data?.text;
      }
      if (text != null && text.trim().isNotEmpty) {
        add(PushClipboardTextEvent(text));
      }
    } catch (_) {
      // Swallow clipboard read errors silently — best-effort capture.
    }
  }

  String _uuid() {
    return 'clip_${DateTime.now().microsecondsSinceEpoch}_${state.items.length}';
  }
}
