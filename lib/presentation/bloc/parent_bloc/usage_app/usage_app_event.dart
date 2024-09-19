part of 'usage_app_bloc.dart';

sealed class UsageAppEvent extends Equatable {
  const UsageAppEvent();
  @override
  List<Object?> get props => [];
}

class FetchUsageAppEvent extends UsageAppEvent {}
