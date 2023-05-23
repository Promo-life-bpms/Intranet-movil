import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intranet_movil/model/birthday.dart';
import 'package:intranet_movil/model/communique.dart';
import 'package:intranet_movil/model/user_model.dart';
import 'package:intranet_movil/services/api_birthday.dart';
import 'package:intranet_movil/services/api_communique.dart';
import 'package:intranet_movil/services/api_user.dart';
import 'package:intranet_movil/services/api_auth.dart';
import 'package:intranet_movil/services/notifications_channel.dart';
import 'package:intranet_movil/utils/constants.dart';
import 'package:intranet_movil/views/auth/login_page.dart';
import 'package:intranet_movil/views/home/home_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  print('Handling a background message ${message.messageId}');
}


/* void main() {
  runApp(ChangeNotifierProvider(
    create: (BuildContext context) => AuthProvider(),
    child: const MyApp(),
  ));
  
} */

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'C1', // id
  'Notificaciones', // title
  description: 'Canal de notificaciones para las solicitudes', // description
  importance: Importance.high, // importance must be at low or higher level
);


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
 
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
 
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  runApp(const MyApp());
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
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);



  String messageTitle = "Empty";
  String notificationAlert = "alert";


 /*  @override
  void initState() {
    super.initState();
  
     createNotificationChannel();
     _getData();
    _getHomeData();
   
  } */

   void initState() {
    super.initState();
 getToken();
     _getData();
    _getHomeData();


    var initializationSettingsAndroid =
         AndroidInitializationSettings('ic_launcher');
    var initialzationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings =
        InitializationSettings(android: initialzationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
 
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                /* channel.description, */
                color: Colors.blue,
                // TODO add a proper drawable resource to android, for now using
                //      one that already exists in example app.
                icon: "@mipmap/ic_launcher",
              ),
            ));
      }
    });
 
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        showDialog(
          context: context,
            // context: context,
            builder: (_) {
          return AlertDialog(
            title: Text("Hola"),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [Text("Esto es una notificacion")],
              ),
            ),
          );
        });
      }
    });
     
    getToken();
  }
 
 
late String token;
getToken() async {
  _token = await FirebaseMessaging.instance.getToken();
  if(_token !=null){
    _token = token;

    print("TOKEEEEEEEEEEEEEEEEEEN");
    print(_token);
  }
}


  void initFirebase() async{
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
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
        navigatorObservers: <NavigatorObserver>[observer],
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
