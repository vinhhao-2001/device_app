import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/utils/local_notification.dart';
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
  MonitorSettingsModel? modelView;
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    // Giám sát thiết bị
    modelView = await ChildFirebaseApi().monitorSettingChildDevice();
    // Thông tin thiết bị
    await ChildFirebaseApi().sendDeviceInfo();
    // Lắng nghe ứng dụng cài đặt hoặc gỡ bỏ
    installRemoveChannel.setMethodCallHandler(_handleAppInstall);
    await requestNotificationPermission();
  }

  Future<void> _handleAppInstall(MethodCall call) async {
    switch (call.method) {
      case 'appInstalled':
        final event = call.arguments['event'];
        final appName = call.arguments['appName'];
        ChildFirebaseApi().sendNotificationAppInstalled(event, appName);
        LocalNotification().showNotification(event, appName);
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
      backgroundColor: Colors.lightBlue[50],
      appBar: AppBar(
        title: const Text(
          'Children App',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
        ),
        backgroundColor: Colors.blueAccent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Thêm hình ảnh minh họa
            Image.asset(
              'assets/images/icon_notification.png',
              height: 150,
            ),
            const SizedBox(height: 20),
            // Thông tin userType
            Text(
              'Welcome, ${widget.userType}!',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            // Tạo các nút trong Card để đẹp hơn
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 5,
              color: Colors.pink.shade100,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity, // Đảm bảo Card chiếm hết chiều rộng
                  child: ListView(
                    shrinkWrap: true, // Tránh chiếm quá nhiều không gian
                    children: [
                      // Nút "Ứng dụng bị giới hạn"
                      ListTile(
                        title: const Text(
                          'Ứng dụng bị giới hạn',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                        tileColor: Colors.orangeAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        onTap: () async {
                          await NativeCommunicator().appLimitChannel();
                        },
                      ),
                      const SizedBox(height: 10),
                      // Nút "Nội dung được phép"
                      ListTile(
                        title: const Text(
                          'Nội dung được phép',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                        tileColor: Colors.greenAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        onTap: () {
                          if (modelView != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      ChildrenMonitorScreen(model: modelView!)),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 10),
                      // Nút "Gửi thời gian sử dụng thiết bị"
                      ListTile(
                        title: const Text(
                          'Gửi thời gian sử dụng thiết bị',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                        tileColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        onTap: () async {
                          await NativeCommunicator().usageStatsChannel();
                        },
                      ),
                      const SizedBox(height: 10),
                      // Nút "Gửi thông báo ứng dụng cài đặt"
                      ListTile(
                        title: const Text(
                          'Gửi thông báo ứng dụng cài đặt',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                        tileColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        onTap: () {
                          LocalNotification().showNotification('a', 'b');
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
