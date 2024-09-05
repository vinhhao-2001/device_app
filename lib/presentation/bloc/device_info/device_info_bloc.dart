import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/api/firebase/parent_firebase_api.dart';
import '../../../model/device_info_model.dart';

part 'device_info_event.dart';
part 'device_info_state.dart';

class DeviceInfoBloc extends Bloc<DeviceInfoEvent, DeviceInfoState> {
  DeviceInfoBloc() : super(const DeviceInfoState()) {
    on<RequestChildDeviceEvent>(_onRequestEvent);
    on<FetchDeviceInfoEvent>(_onFetchDeviceInfoEvent);
  }
  Future<void> _onRequestEvent(
      RequestChildDeviceEvent event, Emitter<DeviceInfoState> emit) async {
    // gửi yêu cầu và chuyển trạng thái loading
    try {
      await ParentFirebaseApi().requestChildDeviceInfo();
    } catch (e) {
      emit(state.copyWith(message: e.toString()));
    }
  }

  Future<void> _onFetchDeviceInfoEvent(
      FetchDeviceInfoEvent event, Emitter<DeviceInfoState> emit) async {
    // Lấy dữ liệu và hiển thị
    try {
      DeviceInfoModel model = await ParentFirebaseApi().getDeviceInfo();
      emit(state.copyWith(model: model));
    } catch (e) {
      emit(state.copyWith(message: e.toString()));
    }
  }
}
