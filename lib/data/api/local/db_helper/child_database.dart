import 'package:shared_preferences/shared_preferences.dart';

class ChildDatabase {
  // Lưu danh sách ứng dụng bị chặn trong máy của trẻ
  Future<void> insertBlockedApps(List<String> listPackageName) async {
    SharedPreferences rf = await SharedPreferences.getInstance();
    final listApp = listPackageName.join('+');
    rf.setString('listBlockedApps', listApp);
  }

  // Lưu danh sách web bị chặn trong máy của trẻ
  Future<void> insertWebBlock(List<String> listWebBlocked) async {
    SharedPreferences rf = await SharedPreferences.getInstance();
    final list = listWebBlocked.join('+');
    rf.setString('listWebBlocked', list);
  }
}
