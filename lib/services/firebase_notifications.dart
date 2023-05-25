import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
 
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
int id = 0;

Future testFirebaseNotification(title, description) async {
  const AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails('Channel01', 'Solicitudes',
          channelDescription: 'Canal de notificaciones para las solicitudes',
          importance: Importance.max,
          priority: Priority.high,
          icon: "@mipmap/ic_launcher_round");
  const NotificationDetails notificationDetails =
      NotificationDetails(android: androidNotificationDetails);
  await flutterLocalNotificationsPlugin.show(id++, title,
      description, notificationDetails);
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
      id++, "Solicitud", "Tu solicitud fue aprobada", notificationDetails,
      payload: "request");
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
      id++, "Solicitud", "Tu solicitud fue rechazada", notificationDetails,
      payload: "request");
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
      "Tu solicitud se eliminó correctamente", notificationDetails,
      payload: "request");
}

Future pendingManagerRequestNotification() async {
  const AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails('Channel01', 'Solicitudes',
          channelDescription: 'Canal de notificaciones para las solicitudes',
          importance: Importance.max,
          priority: Priority.high,
          icon: "@mipmap/ic_launcher_round");
  const NotificationDetails notificationDetails =
      NotificationDetails(android: androidNotificationDetails);
  await flutterLocalNotificationsPlugin.show(id++, "Solicitud",
      "Tienes una nueva solicitud para autorizar", notificationDetails);
}
