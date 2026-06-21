import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/time_block_local_data_source.dart';
import '../../domain/entities/time_block.dart';
import 'time_block_event.dart';
import 'time_block_state.dart';

class TimeBlockBloc extends Bloc<TimeBlockEvent, TimeBlockState> {
  final TimeBlockLocalDataSource _dataSource;

  TimeBlockBloc({required TimeBlockLocalDataSource dataSource})
      : _dataSource = dataSource,
        super(TimeBlockState(selectedDay: _today())) {
    on<LoadDayEvent>(_onLoadDay);
    on<ChangeSelectedDayEvent>(_onChangeDay);
    on<ClaimHoursEvent>(_onClaimHours);
    on<UpdateBlockEvent>(_onUpdateBlock);
    on<DeleteBlockEvent>(_onDeleteBlock);
    on<ToggleBlockCompletedEvent>(_onToggleCompleted);
    on<ClearDayEvent>(_onClearDay);
  }

  static DateTime _today() {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  Future<void> _onLoadDay(LoadDayEvent e, Emitter<TimeBlockState> emit) async {
    emit(state.copyWith(
      status: TimeBlockStatus.loading,
      selectedDay: e.day,
    ));
    final blocks = _dataSource.loadDay(e.day);
    emit(state.copyWith(
      status: TimeBlockStatus.success,
      blocks: blocks,
    ));
  }

  Future<void> _onChangeDay(
      ChangeSelectedDayEvent e, Emitter<TimeBlockState> emit) async {
    final day = DateTime(e.day.year, e.day.month, e.day.day);
    emit(state.copyWith(selectedDay: day, status: TimeBlockStatus.loading));
    final blocks = _dataSource.loadDay(day);
    emit(state.copyWith(status: TimeBlockStatus.success, blocks: blocks));
  }

  Future<void> _onClaimHours(
      ClaimHoursEvent e, Emitter<TimeBlockState> emit) async {
    if (e.startHour < 0 || e.startHour > 23 ||
        e.endHour < 1 || e.endHour > 24 ||
        e.endHour <= e.startHour) {
      emit(state.copyWith(
        status: TimeBlockStatus.failure,
        errorMessage: 'Invalid time range',
      ));
      return;
    }
    // Reject overlaps with existing blocks.
    for (final b in state.blocks) {
      final overlaps = !(e.endHour <= b.startHour || e.startHour >= b.endHour);
      if (overlaps) {
        emit(state.copyWith(
          status: TimeBlockStatus.failure,
          errorMessage: 'Overlaps with "${b.label}" (${_hour(b.startHour)}-${_hour(b.endHour)})',
        ));
        return;
      }
    }
    final block = TimeBlock(
      id: _uuid(),
      label: e.label,
      startHour: e.startHour,
      endHour: e.endHour,
      color: e.color,
      createdAt: DateTime.now(),
    );
    final updated = [...state.blocks, block]..sort((a, b) =>
        a.startHour.compareTo(b.startHour));
    await _dataSource.saveDay(state.selectedDay, updated);
    emit(state.copyWith(status: TimeBlockStatus.success, blocks: updated));
  }

  Future<void> _onUpdateBlock(
      UpdateBlockEvent e, Emitter<TimeBlockState> emit) async {
    final updated = state.blocks.map((b) {
      if (b.id == e.id) {
        return b.copyWith(
          label: e.label ?? b.label,
          color: e.color ?? b.color,
        );
      }
      return b;
    }).toList();
    await _dataSource.saveDay(state.selectedDay, updated);
    emit(state.copyWith(status: TimeBlockStatus.success, blocks: updated));
  }

  Future<void> _onDeleteBlock(
      DeleteBlockEvent e, Emitter<TimeBlockState> emit) async {
    final updated = state.blocks.where((b) => b.id != e.id).toList();
    await _dataSource.saveDay(state.selectedDay, updated);
    emit(state.copyWith(status: TimeBlockStatus.success, blocks: updated));
  }

  Future<void> _onToggleCompleted(
      ToggleBlockCompletedEvent e, Emitter<TimeBlockState> emit) async {
    final updated = state.blocks.map((b) {
      if (b.id == e.id) return b.copyWith(completed: !b.completed);
      return b;
    }).toList();
    await _dataSource.saveDay(state.selectedDay, updated);
    emit(state.copyWith(status: TimeBlockStatus.success, blocks: updated));
  }

  Future<void> _onClearDay(
      ClearDayEvent e, Emitter<TimeBlockState> emit) async {
    await _dataSource.clearDay(state.selectedDay);
    emit(state.copyWith(status: TimeBlockStatus.success, blocks: const []));
  }

  String _uuid() =>
      'tb_${DateTime.now().microsecondsSinceEpoch}_${state.blocks.length}';

  String _hour(int h) {
    if (h == 24) return '24:00';
    return '${h.toString().padLeft(2, '0')}:00';
  }
}
