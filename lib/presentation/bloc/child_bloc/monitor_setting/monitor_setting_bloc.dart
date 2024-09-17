import 'package:device_app/data/api/remote/firebase/child_firebase_api.dart';
import 'package:device_app/model/monitor_settings_model.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'monitor_setting_event.dart';
part 'monitor_setting_state.dart';

class MonitorSettingBloc
    extends Bloc<MonitorSettingEvent, MonitorSettingState> {
  MonitorSettingBloc() : super(const MonitorSettingState()) {
    on<FetchMonitorSettingEvent>((event, emit) async {
      try {
        // Lấy dữ liệu từ firebase
        final model = await ChildFirebaseApi().getMonitorSettingInfo();
        emit(state.copyWith(model: model));
      } catch (e) {
        emit(state.copyWith(error: e.toString()));
      }
    });
    on<UpdateMonitorSettingEvent>((event, emit) async {
      emit(state.copyWith(model: event.model));
    });
  }
}
