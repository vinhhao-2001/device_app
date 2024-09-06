import 'dart:convert';

import 'package:flutter/services.dart';

import '../../../../model/app_usage_info_model.dart';
import '../../../../model/device_info_model.dart';
import '../../../../model/monitor_settings_model.dart';
import '../../remote/firebase/child_firebase_api.dart';

class NativeCommunicator {
  // Kiểm tra quyền của phụ huynh
  static const initPlatform = MethodChannel('init_channel');
  // cài đặt giám sát
  static const MethodChannel _monitorChannel =
      MethodChannel('app_monitor_channel');
  // lấy thông tin thiết bị
  static const _deviceInfoChannel = MethodChannel('screen_time');
  // lấy thời gian sử dụng thiết bị android
  static const usageChannel = MethodChannel('app_usage_channel');
  // lắng nghe cài đặt ứng dụng trong android
  static const installRemoveChannel = MethodChannel('app_installed_channel');
  // các channel

  // channel khởi tạo, kiểm tra quyền kiểm soát của phụ huynh
  Future<void> initChannel() async {
    await initPlatform.invokeMethod('init');
  }

  // channel giám sát thiết bị ios
  Future<bool> monitorSettingChannel(MonitorSettingsModel model) async {
    try {
      await _monitorChannel.invokeMethod(
        'appMonitor',
        model.toMap(),
      );
      return true;
    } catch (e) {
      throw ("Lỗi cài đặt giám sát: $e");
    }
  }

  // Lấy thời gian sử dụng trong android
  Future<List<AppUsageInfoModel>> usageStatsChannel() async {
    try {
      final List<dynamic> apps =
          await usageChannel.invokeMethod('getAppUsageInfo');
      final appList = apps
          .map((app) =>
              AppUsageInfoModel.fromJson(Map<String, dynamic>.from(app)))
          .toList();
      ChildFirebaseApi().sendAppListChildDevice(appList);
      return appList;
    } catch (e) {
      rethrow;
    }
  }

  // Lấy thông tin thiết bị ios
  Future<DeviceInfoModel> deviceInfoChannel() async {
    try {
      final result = await _deviceInfoChannel.invokeMethod('deviceInfo');
      return DeviceInfoModel.fromMap(Map<String, dynamic>.from(result));
    } catch (e) {
      throw ('Lỗi lấy dữ liệu thông tin thiết bị: $e');
    }
  }

  Future<void> appLimitChannel() async {
    try {
      await _deviceInfoChannel.invokeMethod('blockApp');
    } catch (e) {
      rethrow;
    }
  }

  // lắng nghe và gửi ứng dụng được cài đặt hoặc gỡ bỏ lên firebase
  Future<void> listenAppInstalled() async {
    installRemoveChannel.setMethodCallHandler((call) async {
      try {
        if (call.method == 'appInstalled') {
          final event = call.arguments['event'];
          final packageName = call.arguments['packageName'];
          if (event == 'install') {
            final appName = call.arguments['appName'];
            final appIcon = base64Encode(
                Uint8List.fromList(call.arguments['appIcon']).cast<int>());
            await ChildFirebaseApi().sendAppInstalled(event, packageName,
                appName: appName, appIcon: appIcon);
          } else {
            await ChildFirebaseApi().sendAppInstalled(event, packageName);
          }
        }
      } catch (e) {
        rethrow;
      }
    });
  }
}
