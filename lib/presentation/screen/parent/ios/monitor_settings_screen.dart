import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/api/remote/firebase/parent_firebase_api.dart';
import '../../../../model/monitor_settings_model.dart';
import '../../../bloc/parent_bloc/monitor_setting/monitor_setting_bloc.dart';

class MonitoringSettingsScreen extends StatefulWidget {
  const MonitoringSettingsScreen({super.key});

  @override
  State<MonitoringSettingsScreen> createState() =>
      _MonitoringSettingsScreenState();
}

class _MonitoringSettingsScreenState extends State<MonitoringSettingsScreen> {
  late MonitorSettingsModel model;
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
        title: const Text("Cài đặt thiết bị"),
        actions: [
          TextButton(
            onPressed: () {
              final model = context.read<MonitorSettingBloc>().state.model;
              if (model != null) {
                ParentFirebaseApi().sendMonitorSettingModel(model);
              }
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
            child: BlocBuilder<MonitorSettingBloc, MonitorSettingState>(
              buildWhen: (previous, current) =>
                  previous.model != current.model ||
                  previous.error != current.error,
              builder: (context, state) {
                if (state.model != null) {
                  model = state.model!;
                  return Table(
                    columnWidths: const {
                      0: FlexColumnWidth(2),
                      1: FlexColumnWidth(1),
                    },
                    children: [
                      _buildRow(
                        "Khoá thay đổi ngày giờ",
                        DropdownButton<bool>(
                          value: state.model!.autoDateAndTime,
                          items: const [
                            DropdownMenuItem(value: true, child: Text("Có")),
                            DropdownMenuItem(
                                value: false, child: Text("Không")),
                          ],
                          onChanged: (value) {
                            model = model.copyWith(autoDateAndTime: value);
                            bloc.add(UpdateMonitorSettingEvent(model: model));
                          },
                        ),
                      ),
                      _buildRow(
                        "Khoá tài khoản",
                        DropdownButton<bool>(
                          value: state.model!.lockAccounts,
                          items: const [
                            DropdownMenuItem(value: true, child: Text("Có")),
                            DropdownMenuItem(
                                value: false, child: Text("Không")),
                          ],
                          onChanged: (value) {
                            model = model.copyWith(lockAccounts: value);
                            bloc.add(UpdateMonitorSettingEvent(model: model));
                          },
                        ),
                      ),
                      _buildRow(
                        "Khoá mật mã",
                        DropdownButton<bool>(
                          value: state.model!.lockPasscode,
                          items: const [
                            DropdownMenuItem(value: true, child: Text("Có")),
                            DropdownMenuItem(
                                value: false, child: Text("Không")),
                          ],
                          onChanged: (value) {
                            model = model.copyWith(lockPasscode: value);
                            bloc.add(UpdateMonitorSettingEvent(model: model));
                          },
                        ),
                      ),
                      _buildRow(
                        "Sử dụng Siri",
                        DropdownButton<bool>(
                          value: state.model!.denySiri,
                          items: const [
                            DropdownMenuItem(
                                value: false, child: Text("Cho phép")),
                            DropdownMenuItem(value: true, child: Text("Chặn")),
                          ],
                          onChanged: (value) {
                            model = model.copyWith(denySiri: value);
                            bloc.add(UpdateMonitorSettingEvent(model: model));
                          },
                        ),
                      ),
                      _buildRow(
                        "Cho phép mua hàng trong ứng dụng",
                        DropdownButton<bool>(
                          value: state.model!.denyInAppPurchases,
                          items: const [
                            DropdownMenuItem(
                                value: false, child: Text("Cho phép")),
                            DropdownMenuItem(value: true, child: Text("Chặn")),
                          ],
                          onChanged: (value) {
                            model = model.copyWith(denyInAppPurchases: value);
                            bloc.add(UpdateMonitorSettingEvent(model: model));
                          },
                        ),
                      ),
                      _buildRow(
                        'Xếp hạng của ứng dụng',
                        DropdownButton<int>(
                            value: state.model!.maximumRating,
                            items: const [
                              DropdownMenuItem(value: 0, child: Text('Không')),
                              DropdownMenuItem(value: 100, child: Text('4+')),
                              DropdownMenuItem(value: 200, child: Text('9+')),
                              DropdownMenuItem(value: 300, child: Text('12+')),
                              DropdownMenuItem(value: 600, child: Text('17+')),
                              DropdownMenuItem(
                                  value: 1000, child: Text('Tất cả')),
                            ],
                            onChanged: (value) {
                              model = model.copyWith(maximumRating: value);
                              bloc.add(UpdateMonitorSettingEvent(model: model));
                            }),
                      ),
                      _buildRow(
                        "Yêu cầu mật khẩu khi mua hàng",
                        DropdownButton<bool>(
                          value: state.model!.requirePasswordForPurchases,
                          items: const [
                            DropdownMenuItem(value: true, child: Text("Có")),
                            DropdownMenuItem(
                                value: false, child: Text("Không")),
                          ],
                          onChanged: (value) {
                            model = model.copyWith(
                                requirePasswordForPurchases: value);
                            bloc.add(UpdateMonitorSettingEvent(model: model));
                          },
                        ),
                      ),
                      _buildRow(
                        "Nội dung người lớn",
                        DropdownButton<bool>(
                          value: state.model!.denyExplicitContent,
                          items: const [
                            DropdownMenuItem(value: true, child: Text("Chặn")),
                            DropdownMenuItem(
                                value: false, child: Text("Cho phép")),
                          ],
                          onChanged: (value) {
                            model = model.copyWith(denyExplicitContent: value);
                            bloc.add(UpdateMonitorSettingEvent(model: model));
                          },
                        ),
                      ),
                      _buildRow(
                        "Cho phép chơi game nhiều người chơi",
                        DropdownButton<bool>(
                          value: state.model!.denyMultiplayerGaming,
                          items: const [
                            DropdownMenuItem(
                                value: false, child: Text("Cho phép")),
                            DropdownMenuItem(value: true, child: Text("Chặn")),
                          ],
                          onChanged: (value) {
                            model =
                                model.copyWith(denyMultiplayerGaming: value);
                            bloc.add(UpdateMonitorSettingEvent(model: model));
                          },
                        ),
                      ),
                      _buildRow(
                        "Cho phép thêm bạn bè trong Game Center",
                        DropdownButton<bool>(
                          value: state.model!.denyAddingFriends,
                          items: const [
                            DropdownMenuItem(value: true, child: Text("Không")),
                            DropdownMenuItem(
                                value: false, child: Text("Cho phép")),
                          ],
                          onChanged: (value) {
                            model = model.copyWith(denyAddingFriends: value);
                            bloc.add(UpdateMonitorSettingEvent(model: model));
                          },
                        ),
                      ),
                      _buildRow(
                        "Dịch vụ âm nhạc",
                        DropdownButton<bool>(
                          value: state.model!.denyMusicService,
                          items: const [
                            DropdownMenuItem(
                                value: false, child: Text("Cho phép")),
                            DropdownMenuItem(value: true, child: Text("Không")),
                          ],
                          onChanged: (value) {
                            model = model.copyWith(denyMusicService: value);
                            bloc.add(UpdateMonitorSettingEvent(model: model));
                          },
                        ),
                      ),
                    ],
                  );
                } else if (state.error.isNotEmpty) {
                  return Center(
                    child: Text(state.error),
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
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
