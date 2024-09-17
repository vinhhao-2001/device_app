import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DatabaseHelper {
  // parent: Lưu vào danh sách ứng dụng được cài đặt, gỡ bỏ
  Future<void> insertAppChildInstallOrRemove(
      String event, String appName, String appIcon, String time) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      List<String>? appList =
          preferences.getStringList('appListInstalled') ?? [];
      Map<String, String> appData = {
        'event': event,
        'appName': appName,
        'appIcon': appIcon,
        'time': time,
      };
      String appDataJson = jsonEncode(appData);

      appList.add(appDataJson);
      await preferences.setStringList('appListInstalled', appList);
    } catch (e) {
      rethrow;
    }
  }

  // parent: Lấy dữ liệu từ danh sách ứng dụng
  Future<List<Map<String, String>>> getAppChildInstallOrRemove() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    List<String>? appList = preferences.getStringList('appListInstalled') ?? [];

    // Chuyển đổi chuỗi JSON thành Map
    List<Map<String, String>> result = appList
        .map((json) => Map<String, String>.from(jsonDecode(json)))
        .toList();
    return result;
  }
}
