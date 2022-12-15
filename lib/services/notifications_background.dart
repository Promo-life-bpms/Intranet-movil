import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intranet_movil/model/approve_request.dart';
import 'package:intranet_movil/model/request.dart';
import 'package:intranet_movil/services/api_manager_request.dart';
import 'package:intranet_movil/services/api_request.dart';
import 'package:intranet_movil/services/api_rh_request.dart';
import 'package:intranet_movil/services/notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  final prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');

  print(token);
  late List<RequestModel> _requestModel = [];
  late List<ApprovedRequestModel>? _managerRequestModel = [];
  late List<ApprovedRequestModel>? _rhRequestModel = [];

  //Lista inicial, tomada como referencia al momento de actualizar las solicitudes
  _requestModel = (await ApiRequestService().getRequest(token.toString()))!
      .cast<RequestModel>();
  _managerRequestModel =
      (await ApiManagerRequestService().getManagerRequest(token.toString()))!
          .cast<ApprovedRequestModel>();
  _rhRequestModel = (await ApiRhRequestService().getRhRequest())!
      .cast<ApprovedRequestModel>();

  var approvedRequest = _requestModel
      .where((element) => element.humanResourcesStatus == "Aprobada");

  var rejectedRequest = _requestModel.where((element) =>
      element.humanResourcesStatus == "Rechazada" ||
      element.directManagerStatus == "Rechazada");

  var pendingRequest = _requestModel
      .where((element) => element.humanResourcesStatus == "Pendiente");

  var managerRequest = _managerRequestModel
      .where((element) => element.directManagerStatus == "Pendiente");

  var rhRequest = _rhRequestModel
      .where((element) => element.humanResourcesStatus == "Pendiente");

  // LLamada al servidor para actualizar el estado de las solicitudes
  Timer.periodic(const Duration(seconds: 7), (timer) async {
    _requestModel = (await ApiRequestService().getRequest(token.toString()))!
        .cast<RequestModel>();
    print(token);
    _managerRequestModel =
        (await ApiManagerRequestService().getManagerRequest(token.toString()))!
            .cast<ApprovedRequestModel>();

    _rhRequestModel = (await ApiRhRequestService().getRhRequest())!
        .cast<ApprovedRequestModel>();

    //Se filtran las solicitudes por tipo de solicitud
    var newApprovedRequest = _requestModel
        .where((element) => element.humanResourcesStatus == "Aprobada");

    var newRejectedRequest = _requestModel.where((element) =>
        element.humanResourcesStatus == "Rechazada" ||
        element.directManagerStatus == "Rechazada");

    var newPendingRequest = _requestModel
        .where((element) => element.humanResourcesStatus == "Pendiente");

    var newManagerRequest = _managerRequestModel!
        .where((element) => element.directManagerStatus == "Pendiente");

    var newRhRequest = _rhRequestModel!
        .where((element) => element.humanResourcesStatus == "Pendiente");

    //En caso de que el usuario elimina una soliciutd se elimina y se asigna al estado inicial
    if (newPendingRequest.length < pendingRequest.length) {
      if (newApprovedRequest.length > approvedRequest.length) {
        approvedRequestNotification();
        approvedRequest = newApprovedRequest;
      }

      //Solicitud rechazada por RH o Manager
      if (newRejectedRequest.length > rejectedRequest.length) {
        rejectedRequestNotification();
        rejectedRequest = newRejectedRequest;
      }
    }
    //Solicitud Aprobada por RH
    if (newApprovedRequest.length > approvedRequest.length) {
      approvedRequestNotification();
      approvedRequest = newApprovedRequest;
    }

    //Solicitud rechazada por RH o Manager
    if (newRejectedRequest.length > rejectedRequest.length) {
      rejectedRequestNotification();
      rejectedRequest = newRejectedRequest;
    }

    //Notificacion a Manager
    if (newManagerRequest.length > managerRequest.length) {
      pendingManagerRequestNotification();
      managerRequest = newManagerRequest;
    }

    //Notificacion a RH
    if (newRhRequest.length > rhRequest.length) {
      pendingManagerRequestNotification();
      rhRequest = newRhRequest;
    }
  });
}
