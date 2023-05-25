import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future createNotificationChannel() async {
  const AndroidNotificationChannel androidNotificationChannel =
      AndroidNotificationChannel(
    'Channel01',
    'Solicitudes',
    description: 'Canal de notificaciones para las solicitudes',
    importance: Importance.high,
  );
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(androidNotificationChannel);
}
