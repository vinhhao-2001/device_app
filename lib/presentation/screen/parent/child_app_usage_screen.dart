import 'dart:convert';

import 'package:device_app/data/api/remote/firebase/parent_firebase_api.dart';
import 'package:device_app/model/app_limit_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_text.dart';
import '../../../core/utils/utils.dart';
import '../../../model/app_usage_info_model.dart';
import '../../bloc/parent_bloc/usage_app/usage_app_bloc.dart';

class ChildAppUsageScreen extends StatefulWidget {
  const ChildAppUsageScreen({super.key});

  @override
  State<ChildAppUsageScreen> createState() => _ChildAppUsageScreenState();
}

class _ChildAppUsageScreenState extends State<ChildAppUsageScreen> {
  late UsageAppBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = context.read<UsageAppBloc>();
    bloc.add(FetchUsageAppEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppText.childAppUsageAppBar),
      ),
      body: BlocBuilder<UsageAppBloc, UsageAppState>(
        builder: (context, state) {
          if (state.listAppUsage.isNotEmpty) {
            return _buildUsageData(state);
          } else if (state.error.isNotEmpty) {
            return Center(child: Text(state.error));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Widget _buildUsageData(UsageAppState state) {
    int totalUsageTime = state.listAppUsage.fold(0, (sum, app) => sum + app.usageTime);
    List<PieChartSectionData> sections =
        _buildPieChartSections(state.listAppUsage, totalUsageTime);

    return Column(
      children: [
        _buildPieChart(totalUsageTime, sections),
        Expanded(
          child: ListView.builder(
            itemCount: state.listAppUsage.length,
            itemBuilder: (context, index) =>
                _buildAppListTile(state.listAppUsage[index]),
          ),
        ),
      ],
    );
  }

  List<PieChartSectionData> _buildPieChartSections(
      List<AppUsageInfoModel> apps, int totalUsageTime) {
    List<PieChartSectionData> sections = [];
    int otherUsageTime = 0;

    for (var app in apps..sort((a, b) => b.usageTime.compareTo(a.usageTime))) {
      double percentage = (app.usageTime / totalUsageTime) * 100;
      if (percentage > 10) {
        sections.add(PieChartSectionData(
          value: app.usageTime.toDouble(),
          color: Colors.primaries[sections.length % Colors.primaries.length],
          title: app.name,
        ));
      } else {
        otherUsageTime += app.usageTime;
      }
    }

    if (otherUsageTime > 0) {
      sections.add(PieChartSectionData(
        value: otherUsageTime.toDouble(),
        color: Colors.grey,
        title: AppText.other,
      ));
    }

    return sections;
  }

  Widget _buildPieChart(
      int totalUsageTime, List<PieChartSectionData> sections) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            height: 250,
            child: PieChart(
              PieChartData(
                sections: sections,
                centerSpaceRadius: 90,
                borderData: FlBorderData(show: false),
                startDegreeOffset: -90,
              ),
            ),
          ),
          Text(
            Utils().formatUsageTime(totalUsageTime),
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildAppListTile(AppUsageInfoModel app) {
    return ListTile(
      leading: Image.memory(
        base64Decode(app.icon),
        width: 30,
        height: 30,
      ),
      title: Text(app.name),
      subtitle: Text(Utils().formatUsageTime(app.usageTime)),
      trailing: const Icon(Icons.hourglass_empty),
      onTap: () =>
          showCustomDialog(context, app.packageName, app.name, app.icon),
    );
  }

  void showCustomDialog(BuildContext context, String packageName,
      String appName, String appIcon) {
    int selectedHour = 0;
    int selectedMinute = 0;
    bool isTimePickerVisible = false;
    AppLimitModel model = AppLimitModel(
        appName: appName,
        appIcon: appIcon,
        timeLimit: 0,
        packageName: packageName);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              contentPadding: const EdgeInsets.all(10),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header with app icon and name
                  Column(
                    children: [
                      Image.memory(
                        base64Decode(appIcon),
                        height: 30,
                        width: 30,
                      ),
                      Text(appName),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildActionButton(Icons.block, 'Chặn', () {
                        model = AppLimitModel(
                          appName: appName,
                          appIcon: appIcon,
                          timeLimit: 1440,
                          packageName: packageName,
                        );
                        if (isTimePickerVisible) {
                          setState(() {
                            isTimePickerVisible = false;
                          });
                        }
                      }),
                      _buildActionButton(Icons.hourglass_bottom, 'Đặt giới hạn',
                          () {
                        setState(() {
                          isTimePickerVisible = !isTimePickerVisible;
                        });
                      }),
                    ],
                  ),
                  // Time picker
                  if (isTimePickerVisible)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: CupertinoPicker(
                            scrollController: FixedExtentScrollController(
                                initialItem: selectedHour),
                            looping: true,
                            itemExtent: 32.0,
                            onSelectedItemChanged: (int value) =>
                                setState(() => selectedHour = value),
                            children: List<Widget>.generate(
                                24,
                                (int index) =>
                                    Center(child: Text(index.toString()))),
                          ),
                        ),
                        const Text('Giờ'),
                        const Text(':'),
                        Expanded(
                          child: CupertinoPicker(
                            scrollController: FixedExtentScrollController(
                                initialItem: selectedMinute),
                            looping: true,
                            itemExtent: 32.0,
                            onSelectedItemChanged: (int value) =>
                                setState(() => selectedMinute = value),
                            children: List<Widget>.generate(
                                60,
                                (int index) => Center(
                                    child: Text(
                                        index.toString().padLeft(2, '0')))),
                          ),
                        ),
                        const Text('Phút'),
                      ],
                    ),
                  const SizedBox(height: 20),
                  // Dialog buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Huỷ',
                            style: TextStyle(color: Colors.black)),
                      ),
                      TextButton(
                        onPressed: () {
                          if (isTimePickerVisible) {
                            model.timeLimit =
                                selectedHour * 60 + selectedMinute;
                          }
                          if (model.timeLimit != 0) {
                            ParentFirebaseApi().sendAppLimit(model);
                            Navigator.of(context).pop();
                          }
                        },
                        child: const Text('Xong',
                            style: TextStyle(color: Colors.black)),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildActionButton(
      IconData icon, String label, VoidCallback onPressed) {
    return Column(
      children: [
        IconButton(icon: Icon(icon), onPressed: onPressed),
        Text(label),
      ],
    );
  }
}
