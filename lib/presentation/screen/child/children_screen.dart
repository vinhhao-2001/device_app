import 'package:device_app/core/utils/permissions.dart';
import 'package:device_app/data/api/local/db_helper/child_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/api/local/background_service/children_service.dart';
import '../../../data/api/remote/firebase/child_firebase_api.dart';
import '../../../data/api/local/native/native_communicator.dart';
import '../../bloc/child_bloc/monitor_setting/monitor_setting_bloc.dart';
import 'children_device_permissions_screen.dart';
import 'children_monitor_screen.dart';

class ChildrenScreen extends StatefulWidget {
  const ChildrenScreen({super.key});

  @override
  State<ChildrenScreen> createState() => _ChildrenScreenState();
}

class _ChildrenScreenState extends State<ChildrenScreen> {
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    initializeService();
    // Giám sát thiết bị
    await ChildFirebaseApi().monitorSettingChildDevice();
    // Thông tin thiết bị
    ChildFirebaseApi().sendDeviceInfo();
    // Lắng nghe ứng dụng cài đặt hoặc gỡ bỏ
    NativeCommunicator().listenAppInstalled();
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
            Image.asset(
              'assets/images/icon_notification.png',
              height: 150,
            ),
            const SizedBox(height: 20),
            const Text(
              'Welcome,Trẻ!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10,),
            TextButton(onPressed: (){
              NativeCommunicator().startVpnService();
            }, child: Text('Vpn')),
            const SizedBox(height: 30),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 5,
              color: Colors.pink.shade100,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      ListTile(
                        title: const Text(
                          'Ứng dụng bị giới hạn',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                        tileColor: Colors.orangeAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        onTap: () {
                          Permissions().accessibilityPermission();
                          List<String> a = [
                            "com.android.chrome",
                            "com.android.settings",
                          ];
                          ChildDatabase().insertBlockedApps(a);
                        },
                      ),
                      const SizedBox(height: 10),
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => BlocProvider(
                                    create: (context) => MonitorSettingBloc(),
                                    child: const ChildrenMonitorScreen())),
                          );
                        },
                      ),
                      const SizedBox(height: 10),
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
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => const ChildPermissionsScreen()));
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
