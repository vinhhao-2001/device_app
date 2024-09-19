part of 'usage_app_bloc.dart';

class UsageAppState extends Equatable {
  final List<AppUsageInfoModel> model;
  final String error;
  const UsageAppState({
    this.model = const [],
    this.error = '',
  });
  UsageAppState copyWith({
    List<AppUsageInfoModel>? model,
    String? error,
  }) {
    return UsageAppState(
      model: model ?? this.model,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [model, error];
}
