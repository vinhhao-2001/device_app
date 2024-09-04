part of 'device_info_bloc.dart';

sealed class DeviceInfoEvent extends Equatable {
  const DeviceInfoEvent();
  @override
  List<Object?> get props => [];
}

class RequestChildDeviceEvent extends DeviceInfoEvent {
  const RequestChildDeviceEvent();
  @override
  List<Object?> get props => [];
}

class FetchDeviceInfoEvent extends DeviceInfoEvent {
  const FetchDeviceInfoEvent();
  @override
  List<Object?> get props => [];
}
