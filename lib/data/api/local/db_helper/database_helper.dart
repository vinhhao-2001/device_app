import 'package:shared_preferences/shared_preferences.dart';

import '../../../../model/app_usage_info_model.dart';

class DatabaseHelper {
  Future<void> insertAppList(List<AppUsageInfoModel> appList) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    for (var app in appList) {
      await preferences.setString(app.packageName, app.name);
    }
  }

  Future<String> getAppList(String packageName) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? appName = preferences.getString(packageName);
    if (appName != null) {
      return appName;
    } else {
      throw 'Không tìm thấy ứng dụng';
    }
  }
}
