import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotification {
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  LocalNotification() {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/icon_notification');
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
  Future<void> installedNotification(String event, String appName) async {
    try {
      const AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
        'channel ID',
        "channel Name",
        channelDescription: 'channel Description',
        importance: Importance.max,
        priority: Priority.high,
      );

      const NotificationDetails notificationDetails = NotificationDetails(
          android: androidNotificationDetails,
          iOS: DarwinNotificationDetails());
      await flutterLocalNotificationsPlugin.show(0, 'Device App',
          'Thiết bị của trẻ đã $event ứng dụng $appName', notificationDetails);
    } catch (e) {
      throw 'Không thể gửi thông báo';
    }
  }

  Future<void> outsideSafeZoneNotification() async {
    try {
      const AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
        'channel ID',
        "channel Name",
        channelDescription: 'channel Description',
        importance: Importance.max,
        priority: Priority.high,
      );

      const NotificationDetails notificationDetails = NotificationDetails(
          android: androidNotificationDetails,
          iOS: DarwinNotificationDetails());
      await flutterLocalNotificationsPlugin.show(0, 'Device App',
          'Trẻ đang ở ngoài vùng an toàn', notificationDetails);
    } catch (e) {
      throw 'Không thể gửi thông báo';
    }
  }
}
