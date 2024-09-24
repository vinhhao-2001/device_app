import 'package:device_app/core/utils/permissions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';

import '../../../data/api/local/background_service/parent_service.dart';
import '../../../data/api/local/native/native_communicator.dart';
import '../../bloc/parent_bloc/device_info/device_info_bloc.dart';
import '../../bloc/parent_bloc/monitor_setting/monitor_setting_bloc.dart';
import '../../bloc/parent_bloc/usage_app/usage_app_bloc.dart';
import 'child_app_usage_screen.dart';
import 'child_location_screen.dart';
import 'device_state_screen.dart';
import 'history_install_app_screen.dart';
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
    _init();
  }

  Future<void> _init() async {
    initializeService();
    await Permissions().notificationPermission();
    await Permissions().locationPermission();
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
                    builder: (context) => BlocProvider(
                        create: (context) => MonitorSettingBloc(),
                        child: const MonitoringSettingsScreen()),
                  ),
                );
              },
              child: const Text('Cài đặt giám sát thiết bị'),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider(
                        create: (context) => DeviceInfoBloc(),
                        child: const DeviceStateScreen()),
                  ),
                );
              },
              child: const Text('Xem tình trạng thiết bị của trẻ'),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => BlocProvider(
                          create: (context) => UsageAppBloc(),
                          child: const ChildAppUsageScreen())),
                );
              },
              child: const Text('Xem thời gian sử dụng thiết bị'),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => const HistoryInstallAppScreen()),
                );
              },
              child: const Text('Lịch sử cài đặt ứng dụng của trẻ'),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const ChildLocationScreen()),
                  );
                },
                child: const Text('Xem vị trí của trẻ')),
          ],
        ),
      ),
    );
  }
}
