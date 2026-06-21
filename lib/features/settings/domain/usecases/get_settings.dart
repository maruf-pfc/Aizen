import '../../../../core/error/failures.dart';
import '../entities/global_settings.dart';
import '../repositories/settings_repository.dart';

class GetSettings {
  final SettingsRepository repository;

  const GetSettings(this.repository);

  Future<(Failure?, GlobalSettings?)> call() {
    return repository.getSettings();
  }
}
