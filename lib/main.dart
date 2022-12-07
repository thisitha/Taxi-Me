import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_cab/TestLocationSearch/sl_locations_page.dart';
import 'package:flutter_cab/splash.dart';

import 'login.dart';

/*
* Start Date : 16-07-2019
* Author : Aakash Kareliya
* */
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext context) {
    return super.createHttpClient(context)
      ..maxConnectionsPerHost = 5;
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'driverOnTheWay',
          channelName: "Driver Is On His Way To You",
          channelDescription: "Please Wait for the driver to arrive",
          defaultColor: Color(0XFF9050DD),
          playSound: true,
        ),
        NotificationChannel(
          channelKey: 'tripCancelled',
          channelName: "Trip Is Cancelled",
          channelDescription: "Trip Is Cancelled",
          defaultColor: Color(0XFF9050DD),
          playSound: true,
        )
      ]
  );



  // socket.on('event', (data) => print(data));
  // socket.onDisconnect((_) => print('disconnect'));
  // socket.on('fromServer', (_) => print(_));
  HttpOverrides.global = MyHttpOverrides();


  runApp(new MaterialApp(
    home: WillPopScope(child: Splash(),
    onWillPop: (){
      print("back Pressed_--------------------------------------------------------------------------------------------");
    },),
    routes: <String, WidgetBuilder>{
      "\login": (context) => Login(),
    },
  ));
}

class MyApp extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Splash(),
    );
  }
}
