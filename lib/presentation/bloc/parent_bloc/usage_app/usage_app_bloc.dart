import 'package:device_app/data/api/remote/firebase/parent_firebase_api.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../model/app_usage_info_model.dart';

part 'usage_app_event.dart';
part 'usage_app_state.dart';

class UsageAppBloc extends Bloc<UsageAppEvent, UsageAppState> {
  UsageAppBloc() : super(const UsageAppState()) {
    on<FetchUsageAppEvent>((event, emit) async {
      try {
        final usageList = await ParentFirebaseApi().getUsageAppsInfo();
        usageList.sort((a, b) => b.usageTime.compareTo(a.usageTime));
        emit(state.copyWith(listAppUsage: usageList));
      } catch (e) {
        emit(state.copyWith(error: e.toString()));
      }
    });
  }
}
