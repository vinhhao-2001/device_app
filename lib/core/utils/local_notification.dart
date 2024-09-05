import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotification {
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  LocalNotification() {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iOSInitializationSettings =
        DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
        android: androidInitializationSettings, iOS: iOSInitializationSettings);
    flutterLocalNotificationsPlugin.initialize(settings);
  }
  Future<void> showNotification(String event, String appName) async {
    try{
      print('start');
      const AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails(
        'channel ID',
        "channel Name",
        channelDescription: 'channel Description',
        importance: Importance.max,
        priority: Priority.high,
      );

      const NotificationDetails notificationDetails = NotificationDetails(
          android: androidNotificationDetails, iOS: DarwinNotificationDetails());
      await flutterLocalNotificationsPlugin.show(0, 'Quản lý cài đặt ứng dụng',
          'Thiết bị của trẻ đã $event ứng dụng $appName', notificationDetails);
    }
    catch(e){
      print(e);
    }
    }

}
