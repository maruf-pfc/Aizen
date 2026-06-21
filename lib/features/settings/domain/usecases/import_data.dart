import '../../../../core/error/failures.dart';
import '../repositories/settings_repository.dart';

class ImportData {
  final SettingsRepository repository;

  const ImportData(this.repository);

  Future<(Failure?, void)> call(String jsonString) {
    return repository.importData(jsonString);
  }
}
