import '../../../../core/error/failures.dart';
import '../repositories/settings_repository.dart';

class ExportData {
  final SettingsRepository repository;

  const ExportData(this.repository);

  Future<(Failure?, String?)> call() {
    return repository.exportData();
  }
}
