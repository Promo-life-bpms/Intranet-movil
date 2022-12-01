import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intranet_movil/views/request/request_main_page.dart';

Future pendingRequestNotification() async {
  const AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails('Channel01', 'Solicitudes',
          channelDescription: 'Canal de notificaciones para las solicitudes',
          importance: Importance.max,
          priority: Priority.high,
          icon: "@mipmap/ic_launcher_round");
  const NotificationDetails notificationDetails =
      NotificationDetails(android: androidNotificationDetails);
  await flutterLocalNotificationsPlugin.show(id++, "Solicitud",
      "Solicitud creada y enviada para autorizaciòn", notificationDetails);
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
  await flutterLocalNotificationsPlugin.show(
      id++, "Solicitud", "Tu solicitud fue aprobada", notificationDetails);
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

Future deletedRequestNotification() async {
  const AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails('Channel01', 'Solicitudes',
          channelDescription: 'Canal de notificaciones para las solicitudes',
          importance: Importance.max,
          priority: Priority.high,
          icon: "@mipmap/ic_launcher_round");
  const NotificationDetails notificationDetails =
      NotificationDetails(android: androidNotificationDetails);
  await flutterLocalNotificationsPlugin.show(id++, "Solicitud",
      "Tu solicitud se eliminó correctamente", notificationDetails);
}
