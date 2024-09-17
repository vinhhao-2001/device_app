import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'history_app_event.dart';
part 'history_app_state.dart';

class HistoryAppBloc extends Bloc<HistoryAppEvent, HistoryAppState> {
  HistoryAppBloc() : super(const HistoryAppState()) {
    on<HistoryAppEvent>((event, emit) {});
  }
}
