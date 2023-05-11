import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intranet_movil/services/notifications_background.dart';
import 'package:intranet_movil/services/notifications_channel.dart';
import 'package:intranet_movil/utils/constants.dart';
import 'package:intranet_movil/views/chat/chat_page.dart';
import 'package:intranet_movil/views/request/request_main_page.dart';
import 'package:intranet_movil/widget/navigation_drawer_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _LogoutState createState() => _LogoutState();
}

final StreamController<String?> selectNotificationStream =
    StreamController<String?>.broadcast();

class _LogoutState extends State<SettingsPage> {
  late bool enableNotifications;

  int id = 0;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  @override
  void initState() {
    enableNotifications = false;
    createNotificationChannel();
    getNotificationStatus();
    configureSelectNotificationSubject();
    super.initState();
  }

  Future<bool?> getNotificationStatus() async {
    final prefs = await SharedPreferences.getInstance();
    bool? isEnableNotification = prefs.getBool('isEnableNotification');

    if (isEnableNotification == null) {
      enableNotifications = false;
    } else {
      setState(() {
        enableNotifications = isEnableNotification;
      });
    }
  }

  saveNotification(bool enableNotifications) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isEnableNotification', enableNotifications);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        drawer: const NavigationDrawerWidget(),
        appBar: AppBar(
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const ChatPage()));
                },
                child: const Image(
                  image: AssetImage('lib/assets/chat.png'),
                ),
              ),
            ),
          ],
          title: const Text(StringIntranetConstants.settingsPage),
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Activar notificaciones",
                      style: TextStyle(fontSize: 16),
                    ),
                    Switch(
                      value: enableNotifications,
                      onChanged: (bool value) async {
                        setState(() {
                          if (enableNotifications == false) {
                            isAndroidPermissionGranted();
                            requestPermissions();
                            initializeService();
                            enableNotifications = true;
                            saveNotification(enableNotifications);
                          } else {
                            enableNotifications = false;
                            final service = FlutterBackgroundService();
                            service.invoke("stopService");
                            saveNotification(enableNotifications);
                          }
                        });
                      },
                    )
                  ],
                ),
              ),
              //Segunda card
            ],
          ),
        ));
  }

  Future isAndroidPermissionGranted() async {
    if (Platform.isAndroid) {
      final bool granted = await flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()
              ?.areNotificationsEnabled() ??
          false;

      setState(() {
        enableNotifications = granted;
      });
    }
  }

  Future requestPermissions() async {
    if (Platform.isIOS || Platform.isMacOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      final bool? granted = await androidImplementation?.requestPermission();
      setState(() {
        enableNotifications = granted ?? false;
      });
    }
  }

  void configureSelectNotificationSubject() {
    selectNotificationStream.stream.listen((String? payload) async {
      if (payload == "request") {
        await Navigator.of(context).push(MaterialPageRoute<void>(
          builder: (BuildContext context) => const RequestMainPage(),
        ));
      }
    });
  }
}
