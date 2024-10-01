import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/asset_constants.dart';
import '../../../core/utils/permissions.dart';
import '../../../data/api/local/background_service/parent_service.dart';
import '../../../data/api/local/native/native_communicator.dart';
import '../../bloc/parent_bloc/device_info/device_info_bloc.dart';
import '../../bloc/parent_bloc/monitor_setting/monitor_setting_bloc.dart';
import '../../bloc/parent_bloc/usage_app/usage_app_bloc.dart';
import 'child_app_usage_screen.dart';
import 'child_location_screen.dart';
import 'device_state_screen.dart';
import 'history_install_app_screen.dart';
import 'ios/monitor_settings_screen.dart';

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
      backgroundColor: Colors.lightBlue[50], // Background color
      appBar: AppBar(
        leading: IconButton(onPressed: () {}, icon: const Icon(Icons.menu)),
        title: const Center(child: Text('Device App')),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {},
          ),
        ],
      ),

      body: Column(
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage: AssetImage(AssetConstants.iconChild),
                ),
                SizedBox(width: 10),
                Text(
                  'Trẻ', // Replace with child's name
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10), // Space between Row and Buttons
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Platform.isIOS
                    ? _buildElevatedButton(
                        context,
                        'Giới hạn ứng dụng',
                        Icons.apps,
                        onPressed: () async {
                          await NativeCommunicator().appLimitChannel();
                        },
                      )
                    : SizedBox.shrink(),
                Platform.isIOS
                    ? _buildElevatedButton(
                        context,
                        'Cài đặt thiết bị',
                        Icons.settings,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BlocProvider(
                                create: (context) => MonitorSettingBloc(),
                                child: const MonitoringSettingsScreen(),
                              ),
                            ),
                          );
                        },
                      )
                    : SizedBox.shrink(),
                _buildElevatedButton(
                  context,
                  'Xem tình trạng thiết bị của trẻ',
                  Icons.device_hub,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider(
                          create: (context) => DeviceInfoBloc(),
                          child: const DeviceStateScreen(),
                        ),
                      ),
                    );
                  },
                ),
                _buildElevatedButton(
                  context,
                  'Thời gian sử dụng ứng dụng',
                  Icons.access_time,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider(
                          create: (context) => UsageAppBloc(),
                          child: const ChildAppUsageScreen(),
                        ),
                      ),
                    );
                  },
                ),
                _buildElevatedButton(
                  context,
                  'Lịch sử cài đặt ứng dụng của trẻ',
                  Icons.history,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const HistoryInstallAppScreen(),
                      ),
                    );
                  },
                ),
                _buildElevatedButton(
                  context,
                  'Xem vị trí của trẻ',
                  Icons.location_on,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ChildLocationScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildElevatedButton(BuildContext context, String label, IconData icon,
      {required void Function() onPressed}) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: onPressed,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(icon, size: 30),
              const SizedBox(width: 20),
              Text(
                label,
                style: const TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }
}
