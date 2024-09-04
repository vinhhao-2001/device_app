import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../data/api/firebase/parent_firebase_api.dart';
import '../../../model/monitor_settings_model.dart';

class MonitoringSettingsScreen extends StatefulWidget {
  const MonitoringSettingsScreen({super.key});

  @override
  State<MonitoringSettingsScreen> createState() =>
      _MonitoringSettingsScreenState();
}

class _MonitoringSettingsScreenState extends State<MonitoringSettingsScreen> {
  MonitorSettingsModel model = MonitorSettingsModel(
    autoDateAndTime: true,
    lockAccounts: false,
    lockPasscode: false,
    denySiri: false,
    denyInAppPurchases: false,
    requirePasswordForPurchases: false,
    denyExplicitContent: false,
    denyMultiplayerGaming: false,
    denyMusicService: false,
    denyAddingFriends: false,
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cài đặt giám sát"),
        actions: [
          TextButton(
            onPressed: () {
              ParentFirebaseApi().sendMonitorSettingModel(model);
            },
            child: const Text(
              "Xong",
              style: TextStyle(color: Colors.black, fontSize: 18),
            ),
          ),
        ],
      ),
      body: Padding(
          padding:
              const EdgeInsets.only(left: 8, right: 8, top: 20, bottom: 20),
          child: SingleChildScrollView(
            child: Table(
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(1),
              },
              children: [
                _buildRow(
                  "Khoá thay đổi ngày giờ",
                  DropdownButton<bool>(
                    value: model.autoDateAndTime,
                    items: const [
                      DropdownMenuItem(value: true, child: Text("Có")),
                      DropdownMenuItem(value: false, child: Text("Không")),
                    ],
                    onChanged: (value) {
                      setState(() {
                        model.autoDateAndTime = value!;
                      });
                    },
                  ),
                ),
                _buildRow(
                  "Khoá tài khoản",
                  DropdownButton<bool>(
                    value: model.lockAccounts,
                    items: const [
                      DropdownMenuItem(value: true, child: Text("Có")),
                      DropdownMenuItem(value: false, child: Text("Không")),
                    ],
                    onChanged: (value) {
                      setState(() {
                        model.lockAccounts = value!;
                      });
                    },
                  ),
                ),
                _buildRow(
                  "Khoá mật mã",
                  DropdownButton<bool>(
                    value: model.lockPasscode,
                    items: const [
                      DropdownMenuItem(value: true, child: Text("Có")),
                      DropdownMenuItem(value: false, child: Text("Không")),
                    ],
                    onChanged: (value) {
                      setState(() {
                        model.lockPasscode = value!;
                      });
                    },
                  ),
                ),
                _buildRow(
                  "Sử dụng Siri",
                  DropdownButton<bool>(
                    value: model.denySiri,
                    items: const [
                      DropdownMenuItem(value: false, child: Text("Cho phép")),
                      DropdownMenuItem(value: true, child: Text("Chặn")),
                    ],
                    onChanged: (value) {
                      setState(() {
                        model.denySiri = value!;
                      });
                    },
                  ),
                ),
                _buildRow(
                  "Cho phép mua hàng trong ứng dụng",
                  DropdownButton<bool>(
                    value: model.denyInAppPurchases,
                    items: const [
                      DropdownMenuItem(value: false, child: Text("Cho phép")),
                      DropdownMenuItem(value: true, child: Text("Chặn")),
                    ],
                    onChanged: (value) {
                      setState(() {
                        model.denyInAppPurchases = value!;
                      });
                    },
                  ),
                ),
                _buildRow(
                  "Xếp hạng của ứng dụng",
                  Platform.isIOS
                      ? CupertinoTextField(
                          keyboardType: TextInputType.number,
                          placeholder: '0 - 1000',
                          onChanged: (value) {
                            setState(() {
                              model.maximumRating = int.tryParse(value) ?? 1000;
                            });
                          },
                        )
                      : TextField(
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: '0 - 1000',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            setState(() {
                              model.maximumRating = int.tryParse(value) ?? 1000;
                            });
                          },
                        ),
                ),
                _buildRow(
                  "Yêu cầu mật khẩu khi mua hàng",
                  DropdownButton<bool>(
                    value: model.requirePasswordForPurchases,
                    items: const [
                      DropdownMenuItem(value: true, child: Text("Có")),
                      DropdownMenuItem(value: false, child: Text("Không")),
                    ],
                    onChanged: (value) {
                      setState(() {
                        model.requirePasswordForPurchases = value!;
                      });
                    },
                  ),
                ),
                _buildRow(
                  "Nội dung người lớn",
                  DropdownButton<bool>(
                    value: model.denyExplicitContent,
                    items: const [
                      DropdownMenuItem(value: true, child: Text("Chặn")),
                      DropdownMenuItem(value: false, child: Text("Cho phép")),
                    ],
                    onChanged: (value) {
                      setState(() {
                        model.denyExplicitContent = value!;
                      });
                    },
                  ),
                ),
                _buildRow(
                  "Cho phép chơi game nhiều người chơi",
                  DropdownButton<bool>(
                    value: model.denyMultiplayerGaming,
                    items: const [
                      DropdownMenuItem(value: false, child: Text("Cho phép")),
                      DropdownMenuItem(value: true, child: Text("Chặn")),
                    ],
                    onChanged: (value) {
                      setState(() {
                        model.denyMultiplayerGaming = value!;
                      });
                    },
                  ),
                ),
                _buildRow(
                  "Cho phép thêm bạn bè trong Game Center",
                  DropdownButton<bool>(
                    value: model.denyAddingFriends,
                    items: const [
                      DropdownMenuItem(value: true, child: Text("Không")),
                      DropdownMenuItem(value: false, child: Text("Có")),
                    ],
                    onChanged: (value) {
                      setState(() {
                        model.denyAddingFriends = value!;
                      });
                    },
                  ),
                ),
                _buildRow(
                  "Dịch vụ âm nhạc",
                  DropdownButton<bool>(
                    value: model.denyMusicService,
                    items: const [
                      DropdownMenuItem(value: false, child: Text("Cho phép")),
                      DropdownMenuItem(value: true, child: Text("Không")),
                    ],
                    onChanged: (value) {
                      setState(() {
                        model.denyMusicService = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
          )),
    );
  }

  TableRow _buildRow(String title, Widget control) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(title, style: const TextStyle(fontSize: 16)),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: control,
        ),
      ],
    );
  }
}
