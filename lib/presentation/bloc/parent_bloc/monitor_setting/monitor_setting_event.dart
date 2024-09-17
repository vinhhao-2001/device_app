part of 'monitor_setting_bloc.dart';

sealed class MonitorSettingEvent extends Equatable {
  const MonitorSettingEvent();

  @override
  List<Object?> get props => [];
}

class FetchMonitorSettingEvent extends MonitorSettingEvent {
  const FetchMonitorSettingEvent();

  @override
  List<Object?> get props => [];
}

class UpdateMonitorSettingEvent extends MonitorSettingEvent {
  final MonitorSettingsModel? model;

  const UpdateMonitorSettingEvent({
    required this.model,
  });

  @override
  List<Object?> get props => [model];
}
