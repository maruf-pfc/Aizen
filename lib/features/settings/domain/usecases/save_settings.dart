import '../../../../core/error/failures.dart';
import '../entities/global_settings.dart';
import '../repositories/settings_repository.dart';

class SaveSettings {
  final SettingsRepository repository;

  const SaveSettings(this.repository);

  Future<(Failure?, void)> call(GlobalSettings settings) {
    return repository.saveSettings(settings);
  }
}
