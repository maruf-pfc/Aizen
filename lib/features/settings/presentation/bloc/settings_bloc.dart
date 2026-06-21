import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/global_settings.dart';
import '../../domain/usecases/get_settings.dart';
import '../../domain/usecases/save_settings.dart';
import '../../domain/usecases/clear_cache.dart';
import '../../domain/usecases/optimize_database.dart';
import '../../domain/usecases/export_data.dart';
import '../../domain/usecases/import_data.dart';
import '../../../../core/services/focus_bridge_service.dart';
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
    
    final bridge = FocusBridgeService();
    final usageGranted = await bridge.checkUsagePermission();
    final overlayGranted = await bridge.checkOverlayPermission();

    if (res.$1 != null) {
      emit(state.copyWith(
        status: SettingsStatus.failure,
        errorMessage: res.$1!.message,
      ));
    } else {
      final baseSettings = res.$2 ?? const GlobalSettings();
      final updated = baseSettings.copyWith(
        usageStatsGranted: usageGranted,
        systemOverlayGranted: overlayGranted,
      );
      emit(state.copyWith(
        status: SettingsStatus.success,
        settings: updated,
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
    final bridge = FocusBridgeService();
    final GlobalSettings updated;
    
    if (event.permissionType == 'usageStats') {
      final granted = await bridge.checkUsagePermission();
      updated = state.settings.copyWith(usageStatsGranted: granted);
    } else {
      final granted = await bridge.checkOverlayPermission();
      updated = state.settings.copyWith(systemOverlayGranted: granted);
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
        message: 'Permission status verified',
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
