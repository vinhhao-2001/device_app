import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
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
          if (state.model.isNotEmpty) {
            int totalUsageTime =
                state.model.fold(0, (sum, app) => sum + app.usageTime);

            List<AppUsageInfoModel> sortedApps = List.from(state.model)
              ..sort((a, b) => b.usageTime.compareTo(a.usageTime));

            List<PieChartSectionData> sections = [];
            int otherUsageTime = 0;

            for (var app in sortedApps) {
              double percentage = (app.usageTime / totalUsageTime) * 100;
              if (percentage > 10) {
                sections.add(PieChartSectionData(
                  value: app.usageTime.toDouble(),
                  color: Colors
                      .primaries[sections.length % Colors.primaries.length],
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

            return Column(
              children: [
                Padding(
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
                      // Center text for total usage time
                      Text(
                        Utils().formatUsageTime(totalUsageTime),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
                // List of applications
                Expanded(
                  child: ListView.builder(
                    itemCount: state.model.length,
                    itemBuilder: (context, index) {
                      final app = state.model[index];
                      return ListTile(
                        leading: Image.memory(
                          base64Decode(app.icon),
                          width: 30,
                          height: 30,
                        ),
                        title: Text(app.name),
                        subtitle: Text(Utils().formatUsageTime(app.usageTime)),
                        trailing: const Icon(Icons.hourglass_bottom),
                        onTap: () {},
                      );
                    },
                  ),
                ),
              ],
            );
          } else if (state.error.isNotEmpty) {
            return Center(
              child: Text(
                state.error,
              ),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
