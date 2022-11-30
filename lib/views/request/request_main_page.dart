import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intranet_movil/model/request.dart';
import 'package:intranet_movil/services/api_request.dart';
import 'package:intranet_movil/utils/constants.dart';
import 'package:intranet_movil/views/chat/chat_page.dart';
import 'package:intranet_movil/views/request/modules/approved.dart';
import 'package:intranet_movil/views/request/modules/pending.dart';
import 'package:intranet_movil/views/request/modules/process.dart';
import 'package:intranet_movil/views/request/modules/rejected.dart';
import 'package:intranet_movil/views/request/new_request.dart';
import 'package:intranet_movil/widget/navigation_drawer_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

int id = 0;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

const String portName = 'notification_send_port';

class ReceivedNotification {
  ReceivedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
  });

  final int id;
  final String? title;
  final String? body;
  final String? payload;
}

String? selectedNotificationPayload;

/// A notification action which triggers a url launch event
const String urlLaunchActionId = 'id_1';

/// A notification action which triggers a App navigation event
const String navigationActionId = 'id_3';

/// Defines a iOS/MacOS notification category for text input actions.
const String darwinNotificationCategoryText = 'textCategory';

/// Defines a iOS/MacOS notification category for plain actions.
const String darwinNotificationCategoryPlain = 'plainCategory';

class RequestMainPage extends StatefulWidget {
  const RequestMainPage({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<RequestMainPage> {
  late List<RequestModel>? _requestModel = [];
  late String _token = "";

  bool _notificationsEnabled = false;
  int id = 0;

  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel androidNotificationChannel =
        AndroidNotificationChannel(
      'Channel01',
      'Solicitudes',
      description: 'Canal de notificaciones para las solicitudes',
      importance: Importance.max,
    );
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidNotificationChannel);
  }

  @override
  void initState() {
    super.initState();
    _getData();

    _isAndroidPermissionGranted();
    _requestPermissions();
    _createNotificationChannel();
  }

  Future<void> _isAndroidPermissionGranted() async {
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

  Future<void> _requestPermissions() async {
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

  Future<void> _showNotification() async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('Channel01', 'Solicitudes',
            channelDescription: 'Canal de notificaciones para las solicitudes',
            importance: Importance.max,
            priority: Priority.high,
            icon: "@mipmap/ic_launcher");
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    await flutterLocalNotificationsPlugin.show(
        id++, 'Brando', 'Es gay', notificationDetails);
  }

  void _getData() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token != null || token!.isNotEmpty) {
      _token = token;
    }

    _requestModel = (await ApiRequestService().getRequest(token.toString()))!
        .cast<RequestModel>();
    Future.delayed(const Duration(seconds: 1)).then((value) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primaryColor: ColorIntranetConstants.primaryColorLight,
          primaryColorLight: ColorIntranetConstants.primaryColorLight,
          primaryColorDark: ColorIntranetConstants.primaryColorDark,
          backgroundColor: ColorIntranetConstants.backgroundColorDark,
          hoverColor: ColorIntranetConstants.primaryColorLight,
          scaffoldBackgroundColor: ColorIntranetConstants.backgroundColorNormal,
          appBarTheme: const AppBarTheme(
              backgroundColor: ColorIntranetConstants.primaryColorLight)),
      home: DefaultTabController(
        length: 4,
        child: Scaffold(
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
            bottom: TabBar(
                isScrollable: true,
                unselectedLabelColor: Colors.white.withOpacity(0.3),
                indicatorColor: Colors.white,
                tabs: const [
                  Tab(
                    child: Text(StringIntranetConstants.requestPendingPage),
                  ),
                  Tab(
                    child: Text(StringIntranetConstants.requestProcessPage),
                  ),
                  Tab(
                    child: Text(StringIntranetConstants.requestApprovedPage),
                  ),
                  Tab(
                    child: Text(StringIntranetConstants.requestRejectedPage),
                  ),
                ]),
            title: const Text(StringIntranetConstants.requestPage),
          ),
          body: TabBarView(
            children: [
              PendingRequestPage(
                requestModel: _requestModel
                    ?.where((i) =>
                        i.directManagerStatus == "Pendiente" &&
                        i.humanResourcesStatus == "Pendiente")
                    .toList(),
                token: _token,
                contextMain: context,
              ),
              ProcessRequestPage(
                  requestModel: _requestModel
                      ?.where((i) =>
                          i.directManagerStatus == "Aprobada" &&
                          i.humanResourcesStatus == "Pendiente")
                      .toList()),
              ApprovedRequestPage(
                  requestModel: _requestModel
                      ?.where((i) =>
                          i.directManagerStatus == "Aprobada" &&
                          i.humanResourcesStatus == "Aprobada")
                      .toList()),
              RejectedRequestPage(
                  requestModel: _requestModel
                      ?.where((i) =>
                          i.directManagerStatus == "Rechazada" ||
                          i.humanResourcesStatus == "Rechazada")
                      .toList()),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              await _showNotification();
              /*  Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RequestPage()),
              ); */
            },
            backgroundColor: ColorIntranetConstants.primaryColorNormal,
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}
