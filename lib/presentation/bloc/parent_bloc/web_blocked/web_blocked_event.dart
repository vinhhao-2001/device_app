part of 'web_blocked_bloc.dart';

sealed class WebBlockedEvent extends Equatable {
  const WebBlockedEvent();
  @override
  List<Object?> get props => [];
}

class FetchWebBlockedEvent extends WebBlockedEvent {}

class SendWebBlockedEvent extends WebBlockedEvent {
  final String webBlocked;

  const SendWebBlockedEvent(this.webBlocked);
}
