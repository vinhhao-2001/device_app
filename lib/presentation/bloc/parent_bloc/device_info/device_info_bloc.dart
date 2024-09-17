import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/api/remote/firebase/parent_firebase_api.dart';
import '../../../../model/device_info_model.dart';

part 'device_info_event.dart';
part 'device_info_state.dart';

class DeviceInfoBloc extends Bloc<DeviceInfoEvent, DeviceInfoState> {
  DeviceInfoBloc() : super(const DeviceInfoState()) {
    on<DeviceInfoEvent>((event, emit) async {
      try {
        await ParentFirebaseApi().requestChildDeviceInfo();
        final model = await ParentFirebaseApi().getDeviceInfo();
        emit(state.copyWith(model: model));
      } catch (e) {
        emit(state.copyWith(message: e.toString()));
      }
    });
  }
}
