part of 'monitor_setting_bloc.dart';

class MonitorSettingState extends Equatable {
  final MonitorSettingsModel? model;
  final String error;

  const MonitorSettingState({
    this.model,
    this.error = '',
  });

  MonitorSettingState copyWith({
    final MonitorSettingsModel? model,
    final String? error,
  }) {
    return MonitorSettingState(
      model: model ?? this.model,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [model, error];
}
