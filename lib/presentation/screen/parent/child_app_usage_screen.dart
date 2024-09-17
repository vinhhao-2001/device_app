import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../core/utils/utils.dart';
import '../../../model/app_usage_info_model.dart';

class ChildAppUsageScreen extends StatefulWidget {
  final List<AppUsageInfoModel> appList;
  const ChildAppUsageScreen({super.key, required this.appList});

  @override
  State<ChildAppUsageScreen> createState() => _ChildAppUsageScreenState();
}

class _ChildAppUsageScreenState extends State<ChildAppUsageScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thời gian sử dụng ứng dụng của trẻ'),
      ),
      body: widget.appList.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: widget.appList.length,
              itemBuilder: (context, index) {
                final app = widget.appList[index];
                return ListTile(
                  leading: Image.memory(base64Decode(app.icon),
                      width: 40, height: 40),
                  title: Text(app.name),
                  subtitle: Text(Utils().formatUsageTime(app.usageTime)),
                );
              },
            ),
    );
  }
}
