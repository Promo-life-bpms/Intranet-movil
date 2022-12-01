import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intranet_movil/services/notifications_background.dart';
import 'package:intranet_movil/services/notifications_channel.dart';
import 'package:intranet_movil/utils/constants.dart';
import 'package:intranet_movil/views/chat/chat_page.dart';
import 'package:intranet_movil/widget/navigation_drawer_widget.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _LogoutState createState() => _LogoutState();
}

class _LogoutState extends State<SettingsPage> {
  bool enableNotifications = false;
  bool _notificationsEnabled = false;
  int id = 0;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  @override
  void initState() {
    createNotificationChannel();

    super.initState();
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
                      onChanged: (bool value) {
                        setState(() {
                          if (enableNotifications == false) {
                            enableNotifications = true;
                            isAndroidPermissionGranted();
                            requestPermissions();
                            initializeService();
                          } else {
                            enableNotifications = false;
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
        _notificationsEnabled = granted;
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
        _notificationsEnabled = granted ?? false;
      });
    }
  }
}
