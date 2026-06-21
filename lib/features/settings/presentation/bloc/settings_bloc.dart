import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/global_settings.dart';
import '../../domain/usecases/get_settings.dart';
import '../../domain/usecases/save_settings.dart';
import '../../domain/usecases/clear_cache.dart';
import '../../domain/usecases/optimize_database.dart';
import '../../domain/usecases/export_data.dart';
import '../../domain/usecases/import_data.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final GetSettings getSettings;
  final SaveSettings saveSettings;
  final ClearCache clearCache;
  final OptimizeDatabase optimizeDatabase;
  final ExportData exportData;
  final ImportData importData;

  SettingsBloc({
    required this.getSettings,
    required this.saveSettings,
    required this.clearCache,
    required this.optimizeDatabase,
    required this.exportData,
    required this.importData,
  }) : super(const SettingsState()) {
    on<LoadSettingsEvent>(_onLoadSettings);
    on<UpdateThemeModeEvent>(_onUpdateThemeMode);
    on<TogglePermissionEvent>(_onTogglePermission);
    on<TriggerClearCacheEvent>(_onTriggerClearCache);
    on<TriggerOptimizeDbEvent>(_onTriggerOptimizeDb);
    on<TriggerExportDataEvent>(_onTriggerExportData);
    on<TriggerImportDataEvent>(_onTriggerImportData);
  }

  Future<void> _onLoadSettings(
    LoadSettingsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(status: SettingsStatus.loading));
    final res = await getSettings();
    if (res.$1 != null) {
      emit(state.copyWith(
        status: SettingsStatus.failure,
        errorMessage: res.$1!.message,
      ));
    } else {
      emit(state.copyWith(
        status: SettingsStatus.success,
        settings: res.$2 ?? const GlobalSettings(),
      ));
    }
  }

  Future<void> _onUpdateThemeMode(
    UpdateThemeModeEvent event,
    Emitter<SettingsState> emit,
  ) async {
    final updated = state.settings.copyWith(themeMode: event.themeMode);
    final res = await saveSettings(updated);
    if (res.$1 != null) {
      emit(state.copyWith(
        status: SettingsStatus.failure,
        errorMessage: res.$1!.message,
      ));
    } else {
      emit(state.copyWith(
        status: SettingsStatus.success,
        settings: updated,
        message: 'Theme updated to ${event.themeMode}',
      ));
    }
  }

  Future<void> _onTogglePermission(
    TogglePermissionEvent event,
    Emitter<SettingsState> emit,
  ) async {
    final GlobalSettings updated;
    if (event.permissionType == 'usageStats') {
      updated = state.settings.copyWith(
        usageStatsGranted: !state.settings.usageStatsGranted,
      );
    } else {
      updated = state.settings.copyWith(
        systemOverlayGranted: !state.settings.systemOverlayGranted,
      );
    }

    final res = await saveSettings(updated);
    if (res.$1 != null) {
      emit(state.copyWith(
        status: SettingsStatus.failure,
        errorMessage: res.$1!.message,
      ));
    } else {
      emit(state.copyWith(
        status: SettingsStatus.success,
        settings: updated,
        message: 'Permission diagnostics updated',
      ));
    }
  }

  Future<void> _onTriggerClearCache(
    TriggerClearCacheEvent event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(status: SettingsStatus.loading));
    final res = await clearCache();
    if (res.$1 != null) {
      emit(state.copyWith(
        status: SettingsStatus.failure,
        errorMessage: res.$1!.message,
      ));
    } else {
      emit(state.copyWith(
        status: SettingsStatus.success,
        message: 'Temporary app cache cleared successfully',
      ));
    }
  }

  Future<void> _onTriggerOptimizeDb(
    TriggerOptimizeDbEvent event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(status: SettingsStatus.loading));
    final res = await optimizeDatabase();
    if (res.$1 != null) {
      emit(state.copyWith(
        status: SettingsStatus.failure,
        errorMessage: res.$1!.message,
      ));
    } else {
      emit(state.copyWith(
        status: SettingsStatus.success,
        message: 'Database compacted and memory structures optimized',
      ));
    }
  }

  Future<void> _onTriggerExportData(
    TriggerExportDataEvent event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(status: SettingsStatus.loading));
    final res = await exportData();
    if (res.$1 != null) {
      emit(state.copyWith(
        status: SettingsStatus.failure,
        errorMessage: res.$1!.message,
      ));
    } else {
      emit(state.copyWith(
        status: SettingsStatus.success,
        message: 'Data exported successfully: ${res.$2}',
      ));
    }
  }

  Future<void> _onTriggerImportData(
    TriggerImportDataEvent event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(status: SettingsStatus.loading));
    final res = await importData(event.jsonString);
    if (res.$1 != null) {
      emit(state.copyWith(
        status: SettingsStatus.failure,
        errorMessage: res.$1!.message,
      ));
    } else {
      final reloadRes = await getSettings();
      emit(state.copyWith(
        status: SettingsStatus.success,
        settings: reloadRes.$2 ?? const GlobalSettings(),
        message: 'Data imported and settings restored successfully',
      ));
    }
  }
}
