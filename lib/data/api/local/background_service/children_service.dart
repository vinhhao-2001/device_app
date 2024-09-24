import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

import '../../../../core/utils/permissions.dart';
import '../../remote/firebase/child_firebase_api.dart';

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
      foregroundServiceTypes: [AndroidForegroundType.location],
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  return true;
}

// bắt đầu chạy ngầm
@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  await Firebase.initializeApp();

  Timer.periodic(const Duration(seconds: 5), (timer) async {
    final position = await Permissions().determinePosition();
    await ChildFirebaseApi().sendLocation(position);
  });
}
