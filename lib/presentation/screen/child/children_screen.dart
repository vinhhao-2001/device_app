import 'package:device_app/core/utils/local_notification.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../data/api/firebase/child_firebase_api.dart';
import '../../../data/api/native/native_communicator.dart';
import '../../../model/monitor_settings_model.dart';
import 'children_monitor_screen.dart';

const installRemoveChannel = MethodChannel('app_installed_channel');

class ChildrenScreen extends StatefulWidget {
  final String userType;
  const ChildrenScreen({super.key, required this.userType});

  @override
  State<ChildrenScreen> createState() => _ChildrenScreenState();
}

class _ChildrenScreenState extends State<ChildrenScreen> {
  MonitorSettingsModel modelView = MonitorSettingsModel(
      autoDateAndTime: false,
      lockAccounts: false,
      lockPasscode: false,
      denySiri: false,
      denyInAppPurchases: false,
      requirePasswordForPurchases: false,
      denyExplicitContent: true,
      denyMultiplayerGaming: false,
      denyMusicService: false,
      denyAddingFriends: false);
  @override
  void initState() {
    super.initState();
    // giám sát thiết bị
    ChildFirebaseApi().monitorSettingChildDevice(modelView);
    // thông tin thiết bị
    ChildFirebaseApi().sendDeviceInfo();
    installRemoveChannel.setMethodCallHandler(_handleAppInstall);
    requestNotificationPermission();
  }

  Future<void> _handleAppInstall(MethodCall call) async {
    switch (call.method) {
      case 'appInstalled':
        final event = call.arguments['event'];
        final appName = call.arguments['appName'];
        ChildFirebaseApi().sendNotificationAppInstalled(event, appName);
        break;
      default:
        throw MissingPluginException('Not implemented');
    }
  }

  Future<void> requestNotificationPermission() async {
    var status = await Permission.notification.status;
    if (status.isDenied) {
      // Nếu quyền chưa được cấp, yêu cầu quyền
      await Permission.notification.request();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.userType,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                LocalNotification().showNotification('a', 'b');
              },
              child: const Text('Ứng dụng bị giới hạn'),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => ChildrenMonitorScreen(model: modelView)),
                );
              },
              child: const Text('Nội dung được phép'),
            ),
            const SizedBox(height: 30),
            TextButton(
              onPressed: () async {
                await NativeCommunicator().usageStatsChannel();
              },
              child: const Text('Gửi thời gian sử dụng thiết bị'),
            ),
          ],
        ),
      ),
    );
  }
}
