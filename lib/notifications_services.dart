import 'dart:io';
import 'dart:math';
import 'package:app_settings/app_settings.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:notifications/message_screen.dart';

class NotificationServices{

  FirebaseMessaging messaging =FirebaseMessaging.instance;
  FlutterLocalNotificationsPlugin plugin=FlutterLocalNotificationsPlugin();

  void notificationPermission()async{
    NotificationSettings settings=await messaging.requestPermission(
      announcement:true,
      alert:true,
      provisional:true,
      badge:true,
      carPlay:true,
      criticalAlert:true,
      sound: true,
    );
    if(settings.authorizationStatus==AuthorizationStatus.authorized)
      {
        if (kDebugMode) {
          print('User Grant Permission');
        }
      }
    else if(settings.authorizationStatus==AuthorizationStatus.provisional)
      {
        if (kDebugMode) {
          print('User Grant Provisional Permission');
        }
      }
    else{
      AppSettings.openNotificationSettings();
      if (kDebugMode) {
        print('User Denied Permissions');
      }
    }

  }

  void initLocalNotifications(BuildContext context ,RemoteMessage message)async{
    var androidInitSetting= const AndroidInitializationSettings('@mipmap/ic_launcher');

    var initializationSettings=InitializationSettings(
      android:androidInitSetting,
    );
    await plugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (payload){
        handleMessage(context, message);
      }
    );
  }

  void firebaseInat(BuildContext context){
    FirebaseMessaging.onMessage.listen((message) {
      if (kDebugMode) {
        print(message.notification!.title.toString());
        print(message.notification!.body.toString());
        print(message.data['type'].toString());
      }
      if(Platform.isAndroid){
        initLocalNotifications(context, message);
        showNotifications(message);
      }
      if(Platform.isIOS){
        foreGroundMessage();
      }

    });
  }

  Future<void> showNotifications(RemoteMessage message)async{
    AndroidNotificationChannel channel=AndroidNotificationChannel(
      Random.secure().nextInt(100000).toString(),
      'High Importance Notifications',
      importance:Importance.max
    );
    AndroidNotificationDetails androidNotificationDetails=AndroidNotificationDetails(
      channel.id.toString(),
      channel.name.toString(),
      channelDescription:'Description',
      importance:Importance.high,
      priority:Priority.max,
      icon:"@mipmap/ic_launcher",
      ticker:'ticker'
    );
    NotificationDetails notificationDetails=NotificationDetails(
     android:androidNotificationDetails,

    );
    Future.delayed(Duration.zero, (){
      plugin.show(
          0,
          message.notification!.title.toString(),
          message.notification!.body.toString(),
          notificationDetails
      );
    });
  }

    getDeviceToken()async{
    String? token=await messaging.getToken();
    return token;
  }
  void refreshToken()async{
    messaging.onTokenRefresh.listen((event) {
      if (kDebugMode) {
        print('Token refresh ----------------------------------------------------------');
        print(event.toString());
      }

    });
  }

  Future<void> setupInteractMessage(BuildContext context)async{
    RemoteMessage? initialMessage= await FirebaseMessaging.instance.getInitialMessage();

    if(initialMessage!=null){
      handleMessage(context, initialMessage);
    }
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      handleMessage(context,event);
    });
  }

  void handleMessage(BuildContext context,RemoteMessage message){

    if(message.data['type']=='message'){
      Navigator.push(context,MaterialPageRoute(builder: (context)=>MessageScreen(id:message.data['id'])));
    }

  }

  Future foreGroundMessage()async{
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert:true,
      badge:true,
      sound: true
    );
  }

}