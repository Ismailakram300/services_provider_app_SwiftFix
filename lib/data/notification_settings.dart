import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationServices{
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  void requestNotificationPrtmission() async{
    NotificationSettings settings= await messaging.requestPermission(
alert: true,
announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );
    if(settings.authorizationStatus == AuthorizationStatus.authorized){
      print("user granted Permissions");

    }else if(settings.authorizationStatus == AuthorizationStatus.authorized) {
      print("user granted providsional Permissions");

    }else{
      print("user denied Permissions");
    }
  }
}