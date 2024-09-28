import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/utils/local_notification.dart';
import '../../../../core/utils/utils.dart';
import '../../../../model/app_limit_model.dart';
import '../../../../model/app_usage_info_model.dart';
import '../../../../model/child_location_model.dart';
import '../../../../model/device_info_model.dart';
import '../../../../model/monitor_settings_model.dart';
import '../../local/db_helper/parent_database.dart';

class ParentFirebaseApi {
  // yêu cầu lấy thông tin thiết bị của phụ huynh
  Future<void> requestChildDeviceInfo() async {
    try {
      final DatabaseReference reference = FirebaseDatabase.instance.ref();

      // Gửi yêu cầu đến máy con
      await reference.child('request').set({
        'time': DateTime.now().toIso8601String(),
      });

      Completer<void> completer = Completer<void>();
      // lắng nghe xem trẻ đã gửi dữ liệu lên firebase chưa
      final StreamSubscription<DatabaseEvent> subscription =
          reference.child('sent').onValue.listen((event) {
        if (event.snapshot.value == true && !completer.isCompleted) {
          reference.child('sent').set(false);
          completer.complete();
        }
      });
      await completer.future.timeout(Duration(seconds: 10));
      subscription.cancel();
    } catch (e) {
      if (e is TimeoutException) {
        throw 'Không nhận được phản hồi từ thiết bị của trẻ';
      }
      rethrow;
    }
  }

  // gửi các cài đặt thiết bị của trẻ lên firebase từ phụ huynh
  Future<void> sendMonitorSettingModel(MonitorSettingsModel model) async {
    final DatabaseReference databaseReference =
        FirebaseDatabase.instance.ref().child("monitorSettingsModel");
    await databaseReference.set(model.toMap());
  }

  // phụ huynh lấy thông tin thiết bị của trẻ
  Future<DeviceInfoModel> getDeviceInfo() async {
    try {
      final DatabaseReference reference =
          FirebaseDatabase.instance.ref().child('deviceInfoModel');
      final snapshot = await reference.once().timeout(Duration(seconds: 10));
      if (snapshot.snapshot.exists) {
        final data = snapshot.snapshot.value as Map<dynamic, dynamic>;
        return DeviceInfoModel.fromMap(Map<String, dynamic>.from(data));
      } else {
        throw 'Chưa có thông tin thiết bị của trẻ';
      }
    } catch (e) {
      if (e is TimeoutException) {
        throw 'Không lấy được thông tin thiết bị';
      }
      rethrow;
    }
  }

  // phụ huynh lấy danh sách thời gian sử dụng ứng dụng của trẻ
  Future<List<AppUsageInfoModel>> getUsageAppsInfo() async {
    try {
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
        throw 'Không lấy được thời gian sử dụng ứng dụng của trẻ';
      }
    } catch (e) {
      rethrow;
    }
  }

  // Gửi thông báo khi có thiết bị được cài đặt trên thiết bị của trẻ
  Future<void> listenChildAppInstalled() async {
    try {
      DatabaseReference reference =
          FirebaseDatabase.instance.ref().child('appInstalled');
      reference.onValue.listen((data) async {
        final map = data.snapshot.value as Map<dynamic, dynamic>;
        final event = map['event'];
        final packageName = map['packageName'];
        final time = map['time'];
        if (event == 'cài đặt') {
          final appName = map['appName'];
          final appIcon = map['appIcon'];
          await LocalNotification().installedNotification(event, appName);
          // lưu ứng dụng vào danh sách
          await ParentDatabase()
              .insertAppChildInstallOrRemove(event, appName, appIcon, time);
        } else {
          final app = await getAppName(packageName);
          await LocalNotification().installedNotification(event, app.name);
          await ParentDatabase()
              .insertAppChildInstallOrRemove(event, app.name, app.icon, time);
        }
      });
    } catch (e) {
      rethrow;
    }
  }

  // lấy tên của ứng dụng trên firebase, dùng khi gỡ cài đặt
  Future<AppUsageInfoModel> getAppName(String packageName) async {
    try {
      DatabaseReference reference =
          FirebaseDatabase.instance.ref().child('appListChild');
      DataSnapshot snapshot =
          await reference.child(Utils().sanitizeKey(packageName)).get();
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        return AppUsageInfoModel.fromMap(Map<String, dynamic>.from(data));
      } else {
        throw 'Không tìm thấy ứng dụng';
      }
    } catch (e) {
      rethrow;
    }
  }

  // Lấy thông tin cài đặt thiết bị trên firebase
  Future<MonitorSettingsModel?> getMonitorSettingInfo() async {
    try {
      final DatabaseReference reference = FirebaseDatabase.instance.ref();
      final snapshot = await reference.child('monitorSettingsModel').once();
      final data = snapshot.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        return MonitorSettingsModel.fromMap(data);
      } else {
        return null;
      }
    } catch (e) {
      rethrow;
    }
  }

  // Lấy vị trí của trẻ
  Future<ChildLocationModel> getChildLocation() async {
    try {
      final DatabaseReference reference =
          FirebaseDatabase.instance.ref('childLocation');
      final snapshot = await reference.once().timeout(Duration(seconds: 10));

      if (snapshot.snapshot.exists) {
        Map<dynamic, dynamic> data =
            snapshot.snapshot.value as Map<dynamic, dynamic>;
        final model = ChildLocationModel.fromMap(data);
        Utils().checkChildLocation(model.position);
        return model;
      } else {
        throw 'Không tìm thấy vị trí của trẻ';
      }
    } catch (e) {
      if (e is TimeoutException) {
        throw 'Không lấy được vị trí của trẻ';
      }
      rethrow;
    }
  }

  // Gửi phạm vi an toàn của trẻ lên firebase
  Future<void> sendSafeZoneInfo(List<LatLng> polygonPoints) async {
    DatabaseReference ref = FirebaseDatabase.instance.ref("safeZone");
    List<Map<String, double>> points = polygonPoints.map((point) {
      return {
        'latitude': point.latitude,
        'longitude': point.longitude,
      };
    }).toList();
    await ref.set(points);
  }

  // Gửi danh sách ứng dụng bị giới hạn lên firebase
  Future<void> sendListAppLimit(AppLimitModel model) async {
    DatabaseReference reference = FirebaseDatabase.instance.ref();
    reference
        .child('listAppLimit')
        .child(Utils().sanitizeKey(model.packageName))
        .set(model.toMap());
  }
}
