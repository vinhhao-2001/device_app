part of 'usage_app_bloc.dart';

class UsageAppState extends Equatable {
  final List<AppUsageInfoModel> listAppUsage;
  final String error;
  const UsageAppState({
    this.listAppUsage = const [],
    this.error = '',
  });
  UsageAppState copyWith({
    List<AppUsageInfoModel>? listAppUsage,
    String? error,
  }) {
    return UsageAppState(
      listAppUsage: listAppUsage ?? this.listAppUsage,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [listAppUsage, error];
}
