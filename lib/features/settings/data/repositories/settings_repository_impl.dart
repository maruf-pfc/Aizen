import '../../../../core/error/failures.dart';
import '../../domain/entities/global_settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/failures/settings_failures.dart';
import '../datasources/settings_local_data_source.dart';
import '../models/global_settings_model.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDataSource localDataSource;

  SettingsRepositoryImpl({required this.localDataSource});

  @override
  Future<(Failure?, GlobalSettings?)> getSettings() async {
    try {
      final settings = await localDataSource.getSettings();
      return (null, settings);
    } catch (e) {
      return (SettingsFailure(e.toString()), null);
    }
  }

  @override
  Future<(Failure?, void)> saveSettings(GlobalSettings settings) async {
    try {
      final model = GlobalSettingsModel.fromEntity(settings);
      await localDataSource.saveSettings(model);
      return (null, null);
    } catch (e) {
      return (SettingsFailure(e.toString()), null);
    }
  }

  @override
  Future<(Failure?, void)> clearCache() async {
    try {
      await localDataSource.clearCache();
      return (null, null);
    } catch (e) {
      return (CacheClearFailure(e.toString()), null);
    }
  }

  @override
  Future<(Failure?, void)> optimizeDatabase() async {
    try {
      await localDataSource.optimizeDatabase();
      return (null, null);
    } catch (e) {
      return (DatabaseOptimizationFailure(e.toString()), null);
    }
  }

  @override
  Future<(Failure?, String?)> exportData() async {
    try {
      final jsonString = await localDataSource.exportData();
      return (null, jsonString);
    } catch (e) {
      return (ExportImportFailure(e.toString()), null);
    }
  }

  @override
  Future<(Failure?, void)> importData(String jsonString) async {
    try {
      await localDataSource.importData(jsonString);
      return (null, null);
    } catch (e) {
      return (ExportImportFailure(e.toString()), null);
    }
  }
}
