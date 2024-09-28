import 'dart:convert';
import 'package:flutter/material.dart';

import '../../../core/utils/utils.dart';
import '../../../data/api/local/db_helper/parent_database.dart';

class HistoryInstallAppScreen extends StatefulWidget {
  const HistoryInstallAppScreen({super.key});

  @override
  State<HistoryInstallAppScreen> createState() =>
      _HistoryInstallAppScreenState();
}

class _HistoryInstallAppScreenState extends State<HistoryInstallAppScreen> {
  List<Map<String, String>> appList = [];

  @override
  void initState() {
    super.initState();
    _loadAppList();
  }

  // lấy danh sách ứng dụng được cài đặt hoặc gỡ bỏ
  Future<void> _loadAppList() async {
    ParentDatabase databaseHelper = ParentDatabase();
    List<Map<String, String>> data =
        await databaseHelper.getAppChildInstallOrRemove();
    final Set<String> seen = {};
    final List<Map<String, String>> uniqueData = [];
    // do mỗi lần vào app sẽ có dữ liệu được lưu vào
    for (var item in data) {
      final uniqueKey = '${item['appName']}-${item['event']}-${item['time']}';
      if (!seen.contains(uniqueKey)) {
        seen.add(uniqueKey);
        uniqueData.add(item);
      }
    }
    uniqueData.sort((a, b) =>
        DateTime.parse(b['time']!).compareTo(DateTime.parse(a['time']!)));

    setState(() {
      appList = uniqueData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách ứng dụng'),
      ),
      body: appList.isEmpty
          ? const Center(child: Text('Chưa có ứng dụng nào.'))
          : ListView.builder(
              itemCount: appList.length,
              itemBuilder: (context, index) {
                final item = appList[index];
                final event = item['event'] ?? '';
                final appName = item['appName'] ?? '';
                final time = item['time'] ?? '';
                final appIcon = item['appIcon'] ?? '';

                return ListTile(
                  leading: Image.memory(base64Decode(appIcon)),
                  title: Text('$appName đã được $event'),
                  subtitle: Text(Utils().formatTime(time)),
                );
              },
            ),
    );
  }
}
