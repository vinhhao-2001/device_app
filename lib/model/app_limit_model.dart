class AppLimitModel {
  String packageName;
  String appName;
  String appIcon;
  int timeLimit;
  AppLimitModel({
    required this.appName,
    required this.appIcon,
    required this.timeLimit,
    required this.packageName,
  });
  Map<String, dynamic> toMap() {
    return {
      'packageName': packageName,
      'appName': appName,
      'appIcon': appIcon,
      'timeLimit': timeLimit,
    };
  }

  factory AppLimitModel.fromMap(Map<dynamic, dynamic> map) {
    return AppLimitModel(
      packageName: map['packageName'],
      appName: map['appName'],
      appIcon: map['appIcon'],
      timeLimit: map['timeLimit'],
    );
  }
}
