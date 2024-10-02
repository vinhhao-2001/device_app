import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/api/remote/firebase/parent_firebase_api.dart';

part 'web_blocked_event.dart';
part 'web_blocked_state.dart';

class WebBlockedBloc extends Bloc<WebBlockedEvent, WebBlockedState> {
  WebBlockedBloc() : super(WebBlockedState()) {
    on<FetchWebBlockedEvent>((event, emit) async {
      try {
        final listWebBlocked = await ParentFirebaseApi().getBlockedWebsites();
        emit(state.copyWith(listWebBlocked: listWebBlocked));
      } catch (e) {
        emit(state.copyWith(error: e.toString()));
      }
    });
    on<SendWebBlockedEvent>((event, emit) async {
      try {
        await ParentFirebaseApi().sendWebBlocked(event.webBlocked);
        emit(state.copyWith(
            listWebBlocked: [...state.listWebBlocked, event.webBlocked]));
      } catch (e) {
        emit(state.copyWith(error: e.toString()));
      }
    });
  }
}
