import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/device_info/device_info_bloc.dart';

class DeviceStateScreen extends StatefulWidget {
  const DeviceStateScreen({super.key});

  @override
  State<DeviceStateScreen> createState() => _DeviceStateScreenState();
}

class _DeviceStateScreenState extends State<DeviceStateScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DeviceInfoBloc()..add(const FetchDeviceInfoEvent()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Thông tin thiết bị của trẻ'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: BlocBuilder<DeviceInfoBloc, DeviceInfoState>(
            buildWhen: (a, b) => a.model != b.model,
            builder: (context, state) {
              if (state.model == null && state.message.isEmpty) {
                return Container();
              } else {
                return Table(
                  columnWidths: const {
                    0: FlexColumnWidth(2),
                    1: FlexColumnWidth(1),
                  },
                  children: [
                    _buildRow(
                      'Tên thiết bị',
                      state.model!.deviceName,
                    ),
                    _buildRow(
                      'Dung lượng Pin',
                      state.model!.batteryLevel,
                    ),
                    _buildRow(
                      'Độ sáng màn hình',
                      state.model!.screenBrightness,
                    ),
                    _buildRow(
                      'Mức âm lượng',
                      state.model!.volume,
                    )
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }

  TableRow _buildRow(String title, String value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(title, style: const TextStyle(fontSize: 16)),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(value, style: const TextStyle(fontSize: 16)),
        ),
      ],
    );
  }
}
