import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:intranet_movil/services/firebase_notifications.dart';

class FirebaseSettings{

  void initFirebaseService()async{
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
  }

  void getFirebaseToken()async{
    final fcmToken = await FirebaseMessaging.instance.getToken();
    print('FCM TOKEN');
    print(fcmToken);
    FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) {
    }).onError((err) {
        
    });
  }

  void configFirebaseMessageListener()async{
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {

    if (message.notification != null) {
      String? title = message.notification?.title.toString();
      String? description = message.notification?.body.toString();
      testFirebaseNotification(title, description);
    }});
  }

  void configFirebaseBackgroundMessageListener()async{
    //Segundo plano
    @pragma('vm:entry-point')
    Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
      await Firebase.initializeApp();
    }

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  }

  void configFirebaseNotification()async{
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
  }

  void configFirebaseNotifications()async{
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
  }
  

  void configFirebaseGlobalTopics()async{
    await FirebaseMessaging.instance.subscribeToTopic('PUBLICACIONES');
    await FirebaseMessaging.instance.subscribeToTopic('COMUNICADOS');
  }

  void configFirebasePersonalTopics(String idUser) async{
      await FirebaseMessaging.instance.subscribeToTopic(idUser);
      print("AHORA ESTA SUBSCRITO AL TOPIC: " + idUser.toString());
  }


}