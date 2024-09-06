import 'dart:async';

import 'package:firebase_database/firebase_database.dart';

import '../../../model/app_usage_info_model.dart';
import '../../../model/device_info_model.dart';
import '../../../model/monitor_settings_model.dart';

class ParentFirebaseApi {
  // yêu cầu lấy thông tin thiết bị của phụ huynh
  Future<void> requestChildDeviceInfo() async {
    final DatabaseReference reference = FirebaseDatabase.instance.ref();

    // Gửi yêu cầu đến máy con
    await reference.child('request').set({
      'time': DateTime.now().toIso8601String(),
    });

    // Sử dụng Completer để chờ thông tin từ máy con
    Completer<void> completer = Completer<void>();

    // Lắng nghe sự thay đổi trên 'sent'
    final StreamSubscription<DatabaseEvent> subscription =
        reference.child('sent').onValue.listen((event) {
      if (event.snapshot.value == true && !completer.isCompleted) {
        reference.child('sent').set(false);
        completer.complete();
      }
    });
    await completer.future;
    await subscription.cancel();
  }

  // gửi các cài đặt thiết bị của trẻ lên firebase từ phụ huynh
  Future<void> sendMonitorSettingModel(MonitorSettingsModel model) async {
    final DatabaseReference databaseReference =
        FirebaseDatabase.instance.ref().child("monitorSettingsModel");
    await databaseReference.set(model.toMap());
  }

  // phụ huynh lấy thông tin thiết bị của trẻ
  Future<DeviceInfoModel> getDeviceInfo() async {
    final DatabaseReference reference =
        FirebaseDatabase.instance.ref().child('deviceInfoModel');
    final snapshot = await reference.once();
    if (snapshot.snapshot.exists) {
      final data = snapshot.snapshot.value as Map<dynamic, dynamic>;
      return DeviceInfoModel.fromMap(Map<String, dynamic>.from(data));
    } else {
      throw 'Chưa có thông tin thiết bị của trẻ';
    }
  }

  // phụ huynh lấy danh sách ứng dụng của trẻ
  Future<List<AppUsageInfoModel>> getAppsInfo() async {
    DatabaseReference reference =
        FirebaseDatabase.instance.ref().child('appListChild');
    final snapshot = await reference.get();
    if (snapshot.exists) {
      List<AppUsageInfoModel> appList = [];
      final Map<dynamic, dynamic> appsMap =
          snapshot.value as Map<dynamic, dynamic>;
      appsMap.forEach((key, value) {
        appList
            .add(AppUsageInfoModel.fromMap(Map<String, dynamic>.from(value)));
      });
      return appList;
    } else {
      throw 'Chưa có danh sách ứng dụng của trẻ';
    }
  }
}
