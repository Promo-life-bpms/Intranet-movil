
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:intranet_movil/firebase_options.dart';
import 'package:intranet_movil/model/birthday.dart';
import 'package:intranet_movil/model/communique.dart';
import 'package:intranet_movil/model/user_model.dart';
import 'package:intranet_movil/services/api_birthday.dart';
import 'package:intranet_movil/services/api_communique.dart';
import 'package:intranet_movil/services/api_user.dart';
import 'package:intranet_movil/services/api_auth.dart';
import 'package:intranet_movil/services/firebase_notifications.dart';
import 'package:intranet_movil/services/notifications.dart';
import 'package:intranet_movil/services/notifications_channel.dart';
import 'package:intranet_movil/utils/constants.dart';
import 'package:intranet_movil/views/auth/login_page.dart';
import 'package:intranet_movil/views/home/home_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

//Segundo plano
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  print("Handling a background message: ${message.data}");
}


void firebaseRequestPermissions() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;


    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: true,
      provisional: false,
      sound: true,
    );

    print('PERMISOS DE USUARIO: ${settings.authorizationStatus}');
}

void firebaseMessageListener() {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  print('Got a message whilst in the foreground!');
  print('Message data: ${message.data.toString()}');
  

 /*  Map<String, dynamic> foregrowndMessage =  */
  if (message.notification != null) {
    String? title = message.notification?.title.toString();
    String? description = message.notification?.body.toString();
 
    testFirebaseNotification(title, description);
    print('Message also contained a notification: }');
    /* pendingRequestNotification();  */
  }
  });
}

void firebaseGetFCMToken() async {
  final fcmToken = await FirebaseMessaging.instance.getToken();
  print('FCM TOKEN');
  print(fcmToken);
  FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) {
    print('FIREBASE TOKEN');
    print(fcmToken);
  }).onError((err) {
      print("ERROR AL OBTENR EL TOKEN");
  });
}

void main()async {


  //Inicializar servicios de firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  //Escucha de notificaciones y token
  firebaseGetFCMToken();
  firebaseMessageListener(); 
  firebaseRequestPermissions();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(ChangeNotifierProvider(
    create: (BuildContext context) => AuthProvider(),
    child: const MyApp()
      ));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<MyApp> {
  late List<UserModel>? _userModel = [];
  late List<BirthdayModel>? _brithdayModel = [];
  late List<CommuniqueModel>? _communiqueModel = [];

  late String? _token = "";

  late String validator = "";

  @override
  void initState() {
    super.initState();
    createNotificationChannel();
    _getData();
    _getHomeData();
  }



  
  void _getData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = prefs.getString('token');
    });
    _userModel =
        (await ApiUserService().getUsers(_token.toString()))!.cast<UserModel>();

    if (_userModel!.isNotEmpty) {
      setState(() {
        validator = "hasData";
      });
    }

    Future.delayed(const Duration(seconds: 1)).then((value) => setState(() {}));
  }

  void _getHomeData() async {
    _brithdayModel =
        (await ApiBrithdayService().getBrithday())!.cast<BirthdayModel>();
    _communiqueModel =
        (await ApiCommuniqueService().getCommunique())!.cast<CommuniqueModel>();

    Future.delayed(const Duration(seconds: 1)).then((value) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Login',
        //Tema custom de la aplicacion
        theme: ThemeData(
            primaryColor: ColorIntranetConstants.primaryColorLight,
            primaryColorLight: ColorIntranetConstants.primaryColorLight,
            primaryColorDark: ColorIntranetConstants.primaryColorDark,
            backgroundColor: ColorIntranetConstants.backgroundColorDark,
            scaffoldBackgroundColor:
                ColorIntranetConstants.backgroundColorNormal,
            hoverColor: ColorIntranetConstants.primaryColorLight,
            appBarTheme: const AppBarTheme(
                backgroundColor: ColorIntranetConstants.primaryColorLight)),
        home: Scaffold(
            body: _token == null
                ? Center(
                    //Widget que valida si esta autenticado o no
                    child: Consumer<AuthProvider>(
                    builder: (context, auth, child) {
                      switch (auth.isAuthenticated) {
                        case true:
                          return HomePage(
                            userData: _userModel,
                            birthdayData: _brithdayModel,
                            communiqueData: _communiqueModel,
                          );

                        default:
                          return LoginForm();
                      }
                    },
                  ))
                : const HomePage()));
  }
}
