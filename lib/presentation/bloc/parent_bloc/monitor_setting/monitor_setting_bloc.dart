import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/api/remote/firebase/parent_firebase_api.dart';
import '../../../../model/monitor_settings_model.dart';

part 'monitor_setting_event.dart';
part 'monitor_setting_state.dart';

class MonitorSettingBloc
    extends Bloc<MonitorSettingEvent, MonitorSettingState> {
  MonitorSettingBloc() : super(const MonitorSettingState()) {
    on<FetchMonitorSettingEvent>((event, emit) async {
      try {
        // Lấy dữ liệu từ firebase
        final model = await ParentFirebaseApi().getMonitorSettingInfo();
        if (model != null) {
          emit(state.copyWith(model: model));
        } else {
          final modelEmpty = MonitorSettingsModel(
              autoDateAndTime: false,
              lockAccounts: false,
              lockPasscode: false,
              denySiri: false,
              denyInAppPurchases: false,
              maximumRating: 1000,
              requirePasswordForPurchases: false,
              denyExplicitContent: true,
              denyMultiplayerGaming: false,
              denyMusicService: false,
              denyAddingFriends: false);
          emit(state.copyWith(model: modelEmpty));
        }
      } catch (e) {
        emit(state.copyWith(error: e.toString()));
      }
    });
    on<UpdateMonitorSettingEvent>((event, emit) async {
      emit(state.copyWith(model: event.model));
    });
  }
}
