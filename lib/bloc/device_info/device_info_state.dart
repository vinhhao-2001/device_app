part of 'device_info_bloc.dart';

class DeviceInfoState extends Equatable {
  final DeviceInfoModel? model;
  final String message;

  const DeviceInfoState({
    this.model,
    this.message = '',
  });

  DeviceInfoState copyWith({
    final DeviceInfoModel? model,
    final String? request,
    final String? message,
  }) {
    return DeviceInfoState(
      model: model ?? this.model,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [];
}
