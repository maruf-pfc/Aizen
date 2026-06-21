import '../../../../core/error/failures.dart';
import '../entities/global_settings.dart';

abstract class SettingsRepository {
  Future<(Failure?, GlobalSettings?)> getSettings();
  Future<(Failure?, void)> saveSettings(GlobalSettings settings);
  Future<(Failure?, void)> clearCache();
  Future<(Failure?, void)> optimizeDatabase();
  Future<(Failure?, String?)> exportData();
  Future<(Failure?, void)> importData(String jsonString);
}
