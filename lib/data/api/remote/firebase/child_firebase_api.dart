import 'dart:async';
import 'dart:io';

import 'package:firebase_database/firebase_database.dart';

import '../../../../model/app_usage_info_model.dart';
import '../../../../model/monitor_settings_model.dart';
import '../../local/native/native_communicator.dart';

class ChildFirebaseApi {
  // trẻ gửi thông tin thiết bị lên firebase
  Future<void> sendDeviceInfo() async {
    final DatabaseReference reference = FirebaseDatabase.instance.ref();

    reference.child('request').onValue.listen((event) async {
      final deviceInfo = await NativeCommunicator().deviceInfoChannel();
      reference.child('deviceInfoModel').set(deviceInfo.toMap());
      await reference.child('sent').set(true);
    });
  }

  // cài đặt giám sát trên thiết bị của trẻ
  Future<MonitorSettingsModel?> monitorSettingChildDevice() async {
    try {
      final DatabaseReference reference = FirebaseDatabase.instance.ref();
      final snapshot = await reference.child('monitorSettingsModel').once();

      final data = snapshot.snapshot.value as Map<dynamic, dynamic>?;

      if (data != null && data.isNotEmpty) {
        final model = MonitorSettingsModel.fromMap(data);
        // cài đặt thiết bị của trẻ trong native
        if (Platform.isIOS) NativeCommunicator().monitorSettingChannel(model);
        return model;
      } else {
        return null;
      }
    } catch (e) {
      rethrow;
    }
  }

  // gửi danh sách các ứng dụng lên firebase
  Future<void> sendAppListChildDevice(List<AppUsageInfoModel> appList) async {
    try {
      final DatabaseReference reference = FirebaseDatabase.instance.ref();

      for (var app in appList) {
        await reference.child('appListChild').child(app.name).set(app.toMap());
      }
    } catch (e) {
      rethrow;
    }
  }

  // gửi thông tin ứng dụng bị gỡ hoặc cài đặt lên firebase
  Future<void> sendAppInstalled(String event, String packageName,
      {String? appName, String? appIcon}) async {
    try {
      final DatabaseReference reference = FirebaseDatabase.instance.ref();
      Map<String, dynamic> map = {
        'event': event,
        'packageName': packageName,
      };
      if (event == 'cài đặt') {
        map['appName'] = appName;
        map['appIcon'] = appIcon;
      }
      await reference.child('appInstalled').set(map);
    } catch (e) {
      rethrow;
    }
  }
}
