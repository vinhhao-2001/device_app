import 'package:shared_preferences/shared_preferences.dart';

class ChildDatabase {
  // Lưu danh sách ứng dụng bị chặn trong máy của trẻ
  Future<void> insertBlockedApps(List<String> listPackageName) async {
    SharedPreferences rf = await SharedPreferences.getInstance();
    rf.setStringList('listBlockedApps', listPackageName);
  }
}
