part of 'web_blocked_bloc.dart';

class WebBlockedState extends Equatable {
  final List<String> listWebBlocked;
  final String error;
  const WebBlockedState({
    this.listWebBlocked = const [],
    this.error = '',
  });
  WebBlockedState copyWith({
    List<String>? listWebBlocked,
    String? error,
  }) {
    return WebBlockedState(
      listWebBlocked: listWebBlocked ?? this.listWebBlocked,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [listWebBlocked, error];
}
