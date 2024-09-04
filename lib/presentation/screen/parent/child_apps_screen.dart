import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../model/app_usage_info_model.dart';

class ChildAppsScreen extends StatefulWidget {
  final List<AppUsageInfoModel> appList;
  const ChildAppsScreen({super.key, required this.appList});

  @override
  State<ChildAppsScreen> createState() => _ChildAppsScreenState();
}

class _ChildAppsScreenState extends State<ChildAppsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Installed Apps'),
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
                  subtitle: Text(formatUsageTime(app.usageTime)),
                );
              },
            ),
    );
  }

  String formatUsageTime(int millis) {
    Duration duration = Duration(milliseconds: millis);
    int hours = duration.inHours;
    int minutes = duration.inMinutes.remainder(60);
    int seconds = duration.inSeconds.remainder(60);

    List<String> parts = [];

    if (hours > 0) {
      parts.add("$hours giờ");
    }
    if (minutes > 0) {
      parts.add("$minutes phút");
    }
    parts.add("$seconds giây");

    return parts.join(" ");
  }
}
