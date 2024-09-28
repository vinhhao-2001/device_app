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
}
