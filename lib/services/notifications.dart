import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intranet_movil/views/request/request_main_page.dart';

Future createdRequestNotification() async {
  const AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails('Channel01', 'Solicitudes',
          channelDescription: 'Canal de notificaciones para las solicitudes',
          importance: Importance.max,
          priority: Priority.high,
          icon: "@mipmap/ic_launcher_round");
  const NotificationDetails notificationDetails =
      NotificationDetails(android: androidNotificationDetails);
  await flutterLocalNotificationsPlugin.show(id++, "Solicitud",
      "Tu solicitud se creó satisfactoriamente", notificationDetails);
}

Future approvedRequestNotification() async {
  const AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails('Channel01', 'Solicitudes',
          channelDescription: 'Canal de notificaciones para las solicitudes',
          importance: Importance.max,
          priority: Priority.high,
          icon: "@mipmap/ic_launcher_round");
  const NotificationDetails notificationDetails =
      NotificationDetails(android: androidNotificationDetails);
  await flutterLocalNotificationsPlugin.show(id++, "Solicitud",
      "Tu solicitud fue aprobada satistactoriamente", notificationDetails);
}

Future rejectedRequestNotification() async {
  const AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails('Channel01', 'Solicitudes',
          channelDescription: 'Canal de notificaciones para las solicitudes',
          importance: Importance.max,
          priority: Priority.high,
          icon: "@mipmap/ic_launcher_round");
  const NotificationDetails notificationDetails =
      NotificationDetails(android: androidNotificationDetails);
  await flutterLocalNotificationsPlugin.show(
      id++, "Solicitud", "Tu solicitud fue rechazada", notificationDetails);
}
