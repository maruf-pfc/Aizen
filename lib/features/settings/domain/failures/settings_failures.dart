import '../../../../core/error/failures.dart';

class SettingsFailure extends Failure {
  const SettingsFailure(super.message);
}

class CacheClearFailure extends SettingsFailure {
  const CacheClearFailure(super.message);
}

class DatabaseOptimizationFailure extends SettingsFailure {
  const DatabaseOptimizationFailure(super.message);
}

class ExportImportFailure extends SettingsFailure {
  const ExportImportFailure(super.message);
}
