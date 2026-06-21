import 'package:equatable/equatable.dart';
import '../../domain/entities/global_settings.dart';

enum SettingsStatus { initial, loading, success, failure }

class SettingsState extends Equatable {
  final SettingsStatus status;
  final GlobalSettings settings;
  final String? message;
  final String? errorMessage;

  const SettingsState({
    this.status = SettingsStatus.initial,
    this.settings = const GlobalSettings(),
    this.message,
    this.errorMessage,
  });

  SettingsState copyWith({
    SettingsStatus? status,
    GlobalSettings? settings,
    String? message,
    String? errorMessage,
  }) {
    return SettingsState(
      status: status ?? this.status,
      settings: settings ?? this.settings,
      message: message ?? this.message,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, settings, message, errorMessage];
}
