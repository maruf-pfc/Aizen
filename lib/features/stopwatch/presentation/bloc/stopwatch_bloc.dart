import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import '../../domain/entities/lap.dart';
import '../../domain/entities/stopwatch_state.dart';
import '../../domain/usecases/clear_stopwatch_data.dart';
import '../../domain/usecases/get_laps.dart';
import '../../domain/usecases/get_stopwatch_state.dart';
import '../../domain/usecases/save_laps.dart';
import '../../domain/usecases/save_stopwatch_state.dart';
import 'stopwatch_event.dart';
import 'stopwatch_state.dart';

class StopwatchBloc extends Bloc<StopwatchEvent, StopwatchState> {
  final GetStopwatchState getStopwatchState;
  final SaveStopwatchState saveStopwatchState;
  final GetLaps getLaps;
  final SaveLaps saveLaps;
  final ClearStopwatchData clearStopwatchData;

  static const _channel = MethodChannel('com.aizen.app/hardware_bridge');

  StopwatchBloc({
    required this.getStopwatchState,
    required this.saveStopwatchState,
    required this.getLaps,
    required this.saveLaps,
    required this.clearStopwatchData,
  }) : super(const StopwatchState()) {
    on<LoadStopwatchDataEvent>(_onLoadStopwatchData);
    on<StartStopwatchEvent>(_onStartStopwatch);
    on<PauseStopwatchEvent>(_onPauseStopwatch);
    on<ResetStopwatchEvent>(_onResetStopwatch);
    on<AddLapEvent>(_onAddLap);

    // Register native callback listener
    try {
      _channel.setMethodCallHandler((call) async {
        if (call.method == 'onStopwatchAction') {
          add(const LoadStopwatchDataEvent());
        }
      });
    } catch (_) {
      // Ignored in unit test context where ServicesBinding is not initialized
    }
  }

  Future<void> _onLoadStopwatchData(
    LoadStopwatchDataEvent event,
    Emitter<StopwatchState> emit,
  ) async {
    emit(state.copyWith(status: StopwatchStatus.loading));

    final (stateFailure, savedState) = await getStopwatchState();
    final (lapsFailure, savedLaps) = await getLaps();

    if (stateFailure != null || lapsFailure != null) {
      emit(state.copyWith(
        status: StopwatchStatus.failure,
        errorMessage: stateFailure?.message ?? lapsFailure?.message,
      ));
      return;
    }

    final laps = savedLaps ?? const [];

    if (savedState != null) {
      StopwatchStatus status = StopwatchStatus.paused;
      if (savedState.isRunning) {
        status = StopwatchStatus.running;
      } else if (savedState.elapsedTime == Duration.zero) {
        status = StopwatchStatus.initial;
      }

      emit(state.copyWith(
        status: status,
        elapsedTime: savedState.elapsedTime,
        startTime: () => savedState.startTime,
        laps: laps,
      ));
    } else {
      emit(state.copyWith(
        status: StopwatchStatus.initial,
        elapsedTime: Duration.zero,
        startTime: () => null,
        laps: laps,
      ));
    }
  }

  Future<void> _onStartStopwatch(
    StartStopwatchEvent event,
    Emitter<StopwatchState> emit,
  ) async {
    if (state.status == StopwatchStatus.running) return;

    final now = DateTime.now();
    final newState = state.copyWith(
      status: StopwatchStatus.running,
      startTime: () => now,
    );

    emit(newState);

    await saveStopwatchState(StopwatchStateEntity(
      elapsedTime: state.elapsedTime,
      isRunning: true,
      startTime: now,
    ));

    try {
      await _channel.invokeMethod('startStopwatchService', {
        'isRunning': true,
        'elapsedTimeMs': state.elapsedTime.inMilliseconds,
      });
    } catch (_) {}
  }

  Future<void> _onPauseStopwatch(
    PauseStopwatchEvent event,
    Emitter<StopwatchState> emit,
  ) async {
    if (state.status != StopwatchStatus.running) return;

    final now = DateTime.now();
    final elapsedSession = now.difference(state.startTime!);
    final totalElapsed = state.elapsedTime + elapsedSession;

    final newState = state.copyWith(
      status: StopwatchStatus.paused,
      elapsedTime: totalElapsed,
      startTime: () => null,
    );

    emit(newState);

    await saveStopwatchState(StopwatchStateEntity(
      elapsedTime: totalElapsed,
      isRunning: false,
      startTime: null,
    ));

    try {
      await _channel.invokeMethod('startStopwatchService', {
        'isRunning': false,
        'elapsedTimeMs': totalElapsed.inMilliseconds,
      });
    } catch (_) {}
  }

  Future<void> _onResetStopwatch(
    ResetStopwatchEvent event,
    Emitter<StopwatchState> emit,
  ) async {
    emit(const StopwatchState(status: StopwatchStatus.initial));
    await clearStopwatchData();
    try {
      await _channel.invokeMethod('stopStopwatchService');
    } catch (_) {}
  }

  Future<void> _onAddLap(
    AddLapEvent event,
    Emitter<StopwatchState> emit,
  ) async {
    if (state.status == StopwatchStatus.initial) return;

    final now = DateTime.now();
    Duration currentTotalTime;
    DateTime? newStartTime;
    Duration newBaseElapsedTime;

    if (state.status == StopwatchStatus.running && state.startTime != null) {
      final sessionDiff = now.difference(state.startTime!);
      currentTotalTime = state.elapsedTime + sessionDiff;
      newStartTime = now;
      newBaseElapsedTime = currentTotalTime;
    } else {
      currentTotalTime = state.elapsedTime;
      newStartTime = null;
      newBaseElapsedTime = state.elapsedTime;
    }

    final Duration lapTime;
    if (state.laps.isEmpty) {
      lapTime = currentTotalTime;
    } else {
      lapTime = currentTotalTime - state.laps.last.cumulativeTime;
    }

    final newLap = Lap(
      index: state.laps.length + 1,
      lapTime: lapTime,
      cumulativeTime: currentTotalTime,
    );

    final updatedLaps = List<Lap>.from(state.laps)..add(newLap);

    final newState = state.copyWith(
      laps: updatedLaps,
      elapsedTime: newBaseElapsedTime,
      startTime: () => newStartTime,
    );

    emit(newState);

    await saveLaps(updatedLaps);
    await saveStopwatchState(StopwatchStateEntity(
      elapsedTime: newBaseElapsedTime,
      isRunning: state.status == StopwatchStatus.running,
      startTime: newStartTime,
    ));

    try {
      await _channel.invokeMethod('startStopwatchService', {
        'isRunning': state.status == StopwatchStatus.running,
        'elapsedTimeMs': newBaseElapsedTime.inMilliseconds,
      });
    } catch (_) {}
  }
}
