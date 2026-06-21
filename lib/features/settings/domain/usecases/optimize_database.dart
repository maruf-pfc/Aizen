import '../../../../core/error/failures.dart';
import '../repositories/settings_repository.dart';

class OptimizeDatabase {
  final SettingsRepository repository;

  const OptimizeDatabase(this.repository);

  Future<(Failure?, void)> call() {
    return repository.optimizeDatabase();
  }
}
