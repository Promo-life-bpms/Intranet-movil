import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:device_info_plus/device_info_plus.dart';
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
import 'package:flutter_background_service/flutter_background_service.dart';

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
  late List<RequestModel>? _requestModel2 = [];
  late String _token = "";

  bool _notificationsEnabled = false;
  int id = 0;

  @override
  void initState() {
    super.initState();
    _getData();

    _isAndroidPermissionGranted();
    _requestPermissions();
    _createNotificationChannel();
    initializeService();
  }

  Stream<List<RequestModel>?> _request() async* {
    while (true) {
      await Future<void>.delayed(const Duration(seconds: 2));
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      _requestModel2 = (await ApiRequestService().getRequest(token.toString()))!
          .cast<RequestModel>();
      if (_requestModel2!.length > _requestModel!.length) {
        _showNotification();
      }
      yield _requestModel2;
    }
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
          body: StreamBuilder(
              stream: _request(),
              builder: (context, AsyncSnapshot<List<RequestModel>?> snapshot) {
                if (snapshot.hasData) {
                  _requestModel = snapshot.data;

                  TabBarView(
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
                  );
                }
                return TabBarView(
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
                );
              }),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RequestPage()),
              );
            },
            backgroundColor: ColorIntranetConstants.primaryColorNormal,
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }

  /* Notificaciones */

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
            icon: "@mipmap/ic_launcher_round");
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    await flutterLocalNotificationsPlugin.show(
        id++, 'Intranet', 'Tu solicitud ha sido aprobada', notificationDetails);
  }

  Future<void> _repeatNotification() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    late List<RequestModel>? requestModel = [];

    requestModel = (await ApiRequestService().getRequest(token.toString()))!
        .cast<RequestModel>();
    Future.delayed(const Duration(seconds: 1)).then((value) => setState(() {}));

    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('Channel01', 'Solicitudes',
            channelDescription: 'Canal de notificaciones para las solicitudes',
            importance: Importance.max,
            priority: Priority.high,
            icon: "@mipmap/ic_launcher_round");
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    await flutterLocalNotificationsPlugin.periodicallyShow(
        id++,
        'Prueba',
        requestModel.length.toString(),
        RepeatInterval.everyMinute,
        notificationDetails,
        androidAllowWhileIdle: true);
  }

  Future<void> onStart() async {
    // Only available for flutter 3.0.0 and later
    DartPluginRegistrant.ensureInitialized();

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    // bring to foreground
    Timer.periodic(const Duration(seconds: 1), (timer) async {
      _showNotification();
    });
  }
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  /// OPTIONAL, using custom notification channel id
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'Channel01', // id
    'Solicitudes', // title
    description: 'Canal de notificaciones para las solicitudes', // description
    importance: Importance.high, // importance must be at low or higher level
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      // this will be executed when app is in foreground or background in separated isolate
      onStart: onStart,

      // auto start service
      autoStart: true,
      isForegroundMode: true,

      notificationChannelId: 'Channel01',
      initialNotificationTitle: 'Notificaciones Intranet',
      initialNotificationContent: '',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
      // auto start service
      autoStart: true,

      // this will be executed when app is in foreground in separated isolate
      onForeground: onStart,

      // you have to enable background fetch capability on xcode project
      onBackground: onIosBackground,
    ),
  );

  service.startService();
}

// to ensure this is executed
// run app from xcode, then from xcode menu, select Simulate Background Fetch

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  _showNotification();
  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  // Only available for flutter 3.0.0 and later
  DartPluginRegistrant.ensureInitialized();

  /// OPTIONAL when use custom notification
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  final prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');

  late List<RequestModel> _requestModel = [];
  _requestModel = (await ApiRequestService().getRequest(token.toString()))!
      .cast<RequestModel>();

  int numb = _requestModel.length;
  // bring to foreground
  Timer.periodic(const Duration(seconds: 5), (timer) async {
    _requestModel = (await ApiRequestService().getRequest(token.toString()))!
        .cast<RequestModel>();

    if (_requestModel.length > numb) {
      numb = _requestModel.length;
      _showNotification();
    }

    print("totalllllll");
    print(_requestModel.length);
    print(numb);
  });
}

Future _showNotification() async {
  const AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails('Channel01', 'Solicitudes',
          channelDescription: 'Canal de notificaciones para las solicitudes',
          importance: Importance.max,
          priority: Priority.high,
          icon: "@mipmap/ic_launcher_round");
  const NotificationDetails notificationDetails =
      NotificationDetails(android: androidNotificationDetails);
  await flutterLocalNotificationsPlugin.show(id++, "Solicitud",
      "Tu solicitud se ha creado satisfactoriamente", notificationDetails);
}
