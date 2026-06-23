import 'package:flutter_bloc/flutter_bloc.dart';
import 'app_blocker_event.dart';
import 'app_blocker_state.dart';

/// Aizen v1.5.0 — App Blocker threshold/state manager.
///
/// Pure-Dart state container for the Focus Guardian. Decoupled from the
/// SharedPreferences persistence layer so it can be unit-tested in
/// isolation. The page wires up persistence by listening to state changes.
class AppBlockerBloc extends Bloc<AppBlockerEvent, AppBlockerState> {
  AppBlockerBloc([AppBlockerState? initial])
      : super(initial ?? const AppBlockerState()) {
    on<TogglePackageBlockedEvent>(_onTogglePackage);
    on<SetBlockedPackagesEvent>(_onSetBlockedPackages);
    on<ChangeThresholdModeEvent>(_onChangeMode);
    on<UpdateDailyThresholdEvent>(_onUpdateThreshold);
    on<UpdateWindowStartHourEvent>(_onUpdateWindowStart);
    on<UpdateWindowEndHourEvent>(_onUpdateWindowEnd);
  }

  void _onTogglePackage(
      TogglePackageBlockedEvent e, Emitter<AppBlockerState> emit) {
    final next = Set<String>.from(state.blockedPackages);
    if (next.contains(e.packageName)) {
      next.remove(e.packageName);
    } else {
      next.add(e.packageName);
    }
    emit(state.copyWith(blockedPackages: next));
  }

  void _onSetBlockedPackages(
      SetBlockedPackagesEvent e, Emitter<AppBlockerState> emit) {
    emit(state.copyWith(blockedPackages: Set<String>.from(e.packages)));
  }

  void _onChangeMode(
      ChangeThresholdModeEvent e, Emitter<AppBlockerState> emit) {
    emit(state.copyWith(mode: e.mode));
  }

  void _onUpdateThreshold(
      UpdateDailyThresholdEvent e, Emitter<AppBlockerState> emit) {
    if (e.minutes < 0 || e.minutes > 1440) return;
    emit(state.copyWith(dailyThresholdMinutes: e.minutes));
  }

  void _onUpdateWindowStart(
      UpdateWindowStartHourEvent e, Emitter<AppBlockerState> emit) {
    if (e.hour < 0 || e.hour > 23) return;
    emit(state.copyWith(windowStartHour: e.hour));
  }

  void _onUpdateWindowEnd(
      UpdateWindowEndHourEvent e, Emitter<AppBlockerState> emit) {
    if (e.hour < 1 || e.hour > 24) return;
    emit(state.copyWith(windowEndHour: e.hour));
  }
}
