import 'dart:async';
import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/utils/utils.dart';
import '../../../../model/app_limit_model.dart';
import '../../../../model/app_usage_info_model.dart';
import '../../../../model/monitor_settings_model.dart';
import '../../local/db_helper/child_database.dart';
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

  // cài đặt giám sát trên thiết bị của trẻ bằng firebase
  Future<void> monitorSettingChildDevice() async {
    final DatabaseReference reference = FirebaseDatabase.instance.ref();

    reference.child('monitorSettingsModel').onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data != null) {
        final model = MonitorSettingsModel.fromMap(data);
        // cài đặt thiết bị của trẻ trong native
        if (Platform.isIOS) NativeCommunicator().monitorSettingChannel(model);
      }
    }, onError: (error) {
      throw error;
    });
  }

  // Lấy thông tin cài đặt thiết bị trên firebase
  Future<MonitorSettingsModel> getMonitorSettingInfo() async {
    try {
      final DatabaseReference reference = FirebaseDatabase.instance.ref();
      final snapshot = await reference.child('monitorSettingsModel').once();
      final data = snapshot.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        return MonitorSettingsModel.fromMap(data);
      } else {
        throw 'Chưa có yêu cầu cài đặt từ thiết bị phụ huynh';
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
        await reference
            .child('appListChild')
            .child(Utils().sanitizeKey(app.packageName))
            .set(app.toMap());
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
        'time': DateTime.now().toIso8601String(),
      };
      if (event == 'cài đặt') {
        map['appName'] = appName;
        map['appIcon'] = appIcon;
        reference
            .child('appListChild')
            .child(Utils().sanitizeKey(packageName))
            .update({
          'packageName': packageName,
          'name': appName,
          'icon': appIcon,
        });
      }
      await reference.child('appInstalled').set(map);
    } catch (e) {
      rethrow;
    }
  }

  // gửi vị trí của trẻ lên firebase
  Future<void> sendLocation(Position position) async {
    final DatabaseReference reference = FirebaseDatabase.instance.ref();
    await reference.child('childLocation').set({
      'latitude': position.latitude,
      'longitude': position.longitude,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  // lấy danh sách ứng dụng bị giới hạn trên firebase
  Future<void> getAppLimit() async {
    try {
      final DatabaseReference reference = FirebaseDatabase.instance.ref();
      reference.child('listAppLimit').onValue.listen((value) {
        if (value.snapshot.exists) {
          final data = value.snapshot.value as Map<dynamic, dynamic>;
          List<AppLimitModel> listApp = [];
          data.forEach((key, value) {
            listApp
                .add(AppLimitModel.fromMap(Map<String, dynamic>.from(value)));
          });
          final lisAppName = listApp.map((app) => app.appName).toList();
          ChildDatabase().insertBlockedApps(lisAppName);
        } else {
          throw 'Chưa có ứng dụng bị giới hạn';
        }
      });
    } catch (e) {
      rethrow;
    }
  }

  // Lấy danh sách trang web bị giới hạn từ firebase
  void getBlockedWebsites() {
    DatabaseReference reference = FirebaseDatabase.instance.ref('listWebBlock');
    reference.onValue.listen((event) {
      final snapshot = event.snapshot;
      if (snapshot.exists) {
        List<String> blockedWebsites = (snapshot.value as Map<dynamic, dynamic>)
            .values
            .cast<String>()
            .toList();
        ChildDatabase().insertWebBlock(blockedWebsites);
      }
    }, onError: (error) {});
  }
}
