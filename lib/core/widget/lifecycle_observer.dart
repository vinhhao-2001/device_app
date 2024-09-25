import 'dart:ui';

import 'package:device_app/core/utils/local_notification.dart';
import 'package:flutter/material.dart';

abstract class LifecycleObserver<T extends StatefulWidget> extends State<T>
    with WidgetsBindingObserver {
  void onStart();
  void onEnd();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    onStart();
  }

  @override
  void dispose() {
    onEnd();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      onStart();
    } else if (state == AppLifecycleState.paused) {
      onEnd();
    }
  }

  @override
  void didChangeAccessibilityFeatures() {
    // TODO: implement didChangeAccessibilityFeatures

    super.didChangeAccessibilityFeatures();
  }

  @override
  void didChangeMetrics() {
    // TODO: implement didChangeMetrics

    super.didChangeMetrics();
  }

  // thực hiện trước khi ứng dụng bị đóng
  @override
  Future<AppExitResponse> didRequestAppExit() async {
    await LocalNotification().installedNotification('event', 'appName');
    return super.didRequestAppExit();
  }

  @override
  void didChangePlatformBrightness() {
    // TODO: implement didChangePlatformBrightness
    super.didChangePlatformBrightness();
  }

  @override
  Future<bool> didPopRoute() {
    // TODO: implement didPopRoute
    return super.didPopRoute();
  }

  // lấy lỗi khi xây dựng ứng dụng
  void checkError() {
    try {
      build(context);
    } catch (e) {
      throw Exception('Lỗi xây dựng giao diện: $e');
    }
  }

  // kiểm tra chế độ nằm ngang
  bool isLandscape() {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  // tạo dialog khi thoát giao diện
  Future<bool> confirmExit(BuildContext context, String nameScreen) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Thoát giao diện'),
              content: Text('Bạn muốn thoát $nameScreen'),
              actions: <Widget>[
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    child: const Text('Không')),
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    child: const Text('Có')),
              ],
            );
          },
        ) ??
        false;
  }

}
