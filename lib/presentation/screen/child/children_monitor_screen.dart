import 'package:device_app/model/monitor_settings_model.dart';
import 'package:flutter/material.dart';

class ChildrenMonitorScreen extends StatefulWidget {
  final MonitorSettingsModel model;
  const ChildrenMonitorScreen({super.key, required this.model});

  @override
  State<ChildrenMonitorScreen> createState() => _ChildrenMonitorScreenState();
}

class _ChildrenMonitorScreenState extends State<ChildrenMonitorScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cài đặt giám sát"),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 20),
        child: Table(
          columnWidths: const {
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(1),
          },
          children: [
            _buildRow(
              "Khoá thay đổi ngày giờ",
              widget.model.autoDateAndTime == true ? 'Có' : 'Không',
            ),
            _buildRow(
              "Khoá tài khoản",
              widget.model.lockAccounts == true ? 'Có' : 'Không',
            ),
            _buildRow(
              "Khoá mật mã",
              widget.model.lockPasscode == true ? 'Có' : 'Không',
            ),
            _buildRow(
              "Sử dụng Siri",
              widget.model.denySiri == true ? 'Chặn' : 'Cho phép',
            ),
            _buildRow(
              "Cho phép mua hàng trong ứng dụng",
              widget.model.denyInAppPurchases == true ? 'Chặn' : 'Cho phép',
            ),
            _buildRow(
              "Xếp hạng của ứng dụng",
              widget.model.maximumRating.toString(),
            ),
            _buildRow(
              "Yêu cầu mật khẩu khi mua hàng",
              widget.model.requirePasswordForPurchases == true ? 'Có' : 'Không',
            ),
            _buildRow(
              "Nội dung người lớn",
              widget.model.denyExplicitContent == true ? 'Chặn' : 'Cho phép',
            ),
            _buildRow(
              "Cho phép chơi game nhiều người chơi",
              widget.model.denyMultiplayerGaming == true ? 'Chặn' : 'Cho phép',
            ),
            _buildRow(
              "Cho phép kết bạn trong Game Center",
              widget.model.denyAddingFriends == true ? 'Chặn' : 'Cho phép',
            ),
            _buildRow(
              "Dịch vụ âm nhạc",
              widget.model.denyMusicService == true ? 'Chặn' : 'Cho phép',
            ),
          ],
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
