import '../../../../core/error/failures.dart';
import '../repositories/settings_repository.dart';

class ClearCache {
  final SettingsRepository repository;

  const ClearCache(this.repository);

  Future<(Failure?, void)> call() {
    return repository.clearCache();
  }
}
