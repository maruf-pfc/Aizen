import 'package:equatable/equatable.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadSettingsEvent extends SettingsEvent {
  const LoadSettingsEvent();
}

class UpdateThemeModeEvent extends SettingsEvent {
  final String themeMode;

  const UpdateThemeModeEvent(this.themeMode);

  @override
  List<Object?> get props => [themeMode];
}

class TogglePermissionEvent extends SettingsEvent {
  final String permissionType; // 'usageStats' or 'systemOverlay'

  const TogglePermissionEvent(this.permissionType);

  @override
  List<Object?> get props => [permissionType];
}

class TriggerClearCacheEvent extends SettingsEvent {
  const TriggerClearCacheEvent();
}

class TriggerOptimizeDbEvent extends SettingsEvent {
  const TriggerOptimizeDbEvent();
}

class TriggerExportDataEvent extends SettingsEvent {
  const TriggerExportDataEvent();
}

class TriggerImportDataEvent extends SettingsEvent {
  final String jsonString;

  const TriggerImportDataEvent(this.jsonString);

  @override
  List<Object?> get props => [jsonString];
}
