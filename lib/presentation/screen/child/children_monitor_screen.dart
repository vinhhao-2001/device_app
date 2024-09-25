import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/child_bloc/monitor_setting/monitor_setting_bloc.dart';

class ChildrenMonitorScreen extends StatefulWidget {
  const ChildrenMonitorScreen({super.key});

  @override
  State<ChildrenMonitorScreen> createState() => _ChildrenMonitorScreenState();
}

class _ChildrenMonitorScreenState extends State<ChildrenMonitorScreen> {
  late MonitorSettingBloc bloc;
  @override
  void initState() {
    super.initState();
    bloc = context.read<MonitorSettingBloc>();
    bloc.add(const FetchMonitorSettingEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cài đặt giám sát"),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 20),
        child: BlocBuilder<MonitorSettingBloc, MonitorSettingState>(
          buildWhen: (previous, current) => previous.model != current.model || previous.error != current.error,
          builder: (context, state) {
            if (state.model != null) {
              return Table(
                columnWidths: const {
                  0: FlexColumnWidth(2),
                  1: FlexColumnWidth(1),
                },
                children: [
                  _buildRow(
                    "Khoá thay đổi ngày giờ",
                    state.model!.autoDateAndTime == true ? 'Có' : 'Không',
                  ),
                  _buildRow(
                    "Khoá tài khoản",
                    state.model!.lockAccounts == true ? 'Có' : 'Không',
                  ),
                  _buildRow(
                    "Khoá mật mã",
                    state.model!.lockPasscode == true ? 'Có' : 'Không',
                  ),
                  _buildRow(
                    "Sử dụng Siri",
                    state.model!.denySiri == true ? 'Chặn' : 'Cho phép',
                  ),
                  _buildRow(
                    "Cho phép mua hàng trong ứng dụng",
                    state.model!.denyInAppPurchases == true
                        ? 'Chặn'
                        : 'Cho phép',
                  ),
                  _buildRow(
                    "Xếp hạng của ứng dụng",
                    {
                          0: 'Không',
                          9: '9+',
                          12: '12+',
                          17: '17+',
                        }[state.model!.maximumRating] ??
                        'Tất cả',
                  ),
                  _buildRow(
                    "Yêu cầu mật khẩu khi mua hàng",
                    state.model!.requirePasswordForPurchases == true
                        ? 'Có'
                        : 'Không',
                  ),
                  _buildRow(
                    "Nội dung người lớn",
                    state.model!.denyExplicitContent == true
                        ? 'Chặn'
                        : 'Cho phép',
                  ),
                  _buildRow(
                    "Cho phép chơi game nhiều người chơi",
                    state.model!.denyMultiplayerGaming == true
                        ? 'Chặn'
                        : 'Cho phép',
                  ),
                  _buildRow(
                    "Cho phép kết bạn trong Game Center",
                    state.model!.denyAddingFriends == true
                        ? 'Chặn'
                        : 'Cho phép',
                  ),
                  _buildRow(
                    "Dịch vụ âm nhạc",
                    state.model!.denyMusicService == true ? 'Chặn' : 'Cho phép',
                  ),
                ],
              );
            } else if (state.error.isNotEmpty) {
              Navigator.of(context).pop();
              return Center(
                child: Text(state.error),
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
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
