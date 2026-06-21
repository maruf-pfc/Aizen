import '../../../../core/error/failures.dart';

class NavigationFailure extends Failure {
  const NavigationFailure(super.message);
}

class ModuleNotFoundFailure extends NavigationFailure {
  const ModuleNotFoundFailure(super.message);
}
