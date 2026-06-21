import 'package:equatable/equatable.dart';
import 'app_blocker_state.dart';

abstract class AppBlockerEvent extends Equatable {
  const AppBlockerEvent();
  @override
  List<Object?> get props => [];
}

class TogglePackageBlockedEvent extends AppBlockerEvent {
  final String packageName;
  const TogglePackageBlockedEvent(this.packageName);

  @override
  List<Object?> get props => [packageName];
}

class SetBlockedPackagesEvent extends AppBlockerEvent {
  final Set<String> packages;
  const SetBlockedPackagesEvent(this.packages);

  @override
  List<Object?> get props => [packages];
}

class ChangeThresholdModeEvent extends AppBlockerEvent {
  final ThresholdMode mode;
  const ChangeThresholdModeEvent(this.mode);

  @override
  List<Object?> get props => [mode];
}

class UpdateDailyThresholdEvent extends AppBlockerEvent {
  final int minutes;
  const UpdateDailyThresholdEvent(this.minutes);

  @override
  List<Object?> get props => [minutes];
}

class UpdateWindowStartHourEvent extends AppBlockerEvent {
  final int hour;
  const UpdateWindowStartHourEvent(this.hour);

  @override
  List<Object?> get props => [hour];
}

class UpdateWindowEndHourEvent extends AppBlockerEvent {
  final int hour;
  const UpdateWindowEndHourEvent(this.hour);

  @override
  List<Object?> get props => [hour];
}
