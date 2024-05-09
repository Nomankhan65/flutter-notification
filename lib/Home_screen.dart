import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:notifications/notifications_services.dart';
import 'package:http/http.dart'as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  NotificationServices notificationServices=NotificationServices();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    notificationServices.notificationPermission();
    notificationServices.firebaseInat(context);
    notificationServices.setupInteractMessage(context);
    notificationServices.getDeviceToken().then((value){
      if (kDebugMode) {
        print('Device Token');
        print(value.toString());
      }
    });
    notificationServices.refreshToken();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        title:const Text('Notifications'),
      ),
      body:Center(child:TextButton(onPressed: (){
        notificationServices.getDeviceToken().then((value)async{
          var data={
            'to':value.toString(),
            'priority':'high',
            'notification':{
              'title':'send',
              'body':'send notification to other device'
            },
            'data':{
              'type':'message',
              'id':'notify123'
            }
          };
          await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
          body:jsonEncode(data),
            headers:{

              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization':'key= your firebase message key'
            }
          );
        });

      }, child:const Text('send notifications')),),
    );
  }
}
