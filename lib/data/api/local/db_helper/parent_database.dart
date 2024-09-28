import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ParentDatabase {
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

  // parent: Lấy danh sách ứng dụng được cài đặt hoặc gỡ bỏ
  Future<List<Map<String, String>>> getAppChildInstallOrRemove() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    List<String>? appList = preferences.getStringList('appListInstalled') ?? [];

    // Chuyển đổi chuỗi JSON thành Map
    List<Map<String, String>> result = appList
        .map((json) => Map<String, String>.from(jsonDecode(json)))
        .toList();
    return result;
  }

  //parent: Lưu vùng an toàn của trẻ
  Future<void> insertSafeZone(List<LatLng> polygonPoints) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    List<String> points = polygonPoints.map((point) {
      return '${point.latitude},${point.longitude}';
    }).toList();

    await preferences.setStringList('points', points);
  }

  //parent: Lấy vùng an toàn của trẻ
  Future<List<LatLng>> getSafeZone() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    List<String>? pointStrings = preferences.getStringList('points');

    if (pointStrings != null) {
      return pointStrings.map((pointString) {
        final coordinates = pointString.split(',');
        return LatLng(
          double.parse(coordinates[0]),
          double.parse(coordinates[1]),
        );
      }).toList();
    } else {
      return [];
    }
  }
}
