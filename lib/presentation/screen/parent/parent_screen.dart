import 'package:flutter/material.dart';

import '../../../data/api/remote/firebase/parent_firebase_api.dart';
import '../../../data/api/local/native/native_communicator.dart';
import 'child_apps_screen.dart';
import 'device_state_screen.dart';
import 'monitor_settings_screen.dart';

class ParentScreen extends StatefulWidget {
  const ParentScreen({super.key});

  @override
  State<ParentScreen> createState() => _ParentScreenState();
}

class _ParentScreenState extends State<ParentScreen> {
  @override
  void initState() {
    super.initState();
    ParentFirebaseApi().listenChildAppInstalled();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kiểm soát ứng dụng của trẻ')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () async {
                await NativeCommunicator().appLimitChannel();
              },
              child: const Text('Giới hạn ứng dụng'),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MonitoringSettingsScreen(),
                  ),
                );
              },
              child: const Text('Cài đặt giám sát thiết bị'),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () async {
                await ParentFirebaseApi().requestChildDeviceInfo();
                if (!(context).mounted) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DeviceStateScreen()),
                );
              },
              child: const Text('Xem tình trạng thiết bị của trẻ'),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () async {
                // lấy thời gian sử dụng ứng dụng trên firebase
                final appList = await ParentFirebaseApi().getAppsInfo();
                appList.sort((a, b) => b.usageTime.compareTo(a.usageTime));
                if (!(context).mounted) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => ChildAppsScreen(appList: appList)),
                );
              },
              child: const Text('Xem thời gian sử dụng thiết bị'),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Lịch sử cài đặt ứng dụng của trẻ'),
            )
          ],
        ),
      ),
    );
  }
}
