import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_cab/GetBothLocation/getbothlocations.dart';
import 'package:flutter_cab/GetPickupLocation/location_pickup.dart';
import 'package:flutter_cab/home/home.dart';
import 'package:flutter_cab/utils/CustomTextStyle.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'TestOSMSearchMap/osm_search_map.dart';
import 'UserDashboard/user_dashboard_page.dart';
import 'login.dart';


class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {


  @override
  void initState() {
    super.initState();
    splashMove();
  }

  displaySharedData(SharedPreferences localStorage) async {
    String userId = localStorage.getString('userId');
    String email = localStorage.getString('email');
    String passengerCode = localStorage.getString('passengerCode');
    String userProfilePic = localStorage.getString('userProfilePic');
    String token = localStorage.getString('token');

    print(' ----------------------------- SAVED USER ----------------------------- ');
    print('userId: $userId');
    print('email: $email');
    print('passengerCode: $passengerCode');
    print('userProfilePic: $userProfilePic');
    print('token: $token');
  }

  navigatePage() async{
    //SharedPreferences.setMockInitialValues({});
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    displaySharedData(localStorage);
     var User=localStorage.getString('userId');
     print("-------------------------------- USER: $User --------------------------------");
     if(User!=null){
       Navigator.pushAndRemoveUntil(
         context,
         //MaterialPageRoute(bu
         // ilder: (context) => Home()),
         MaterialPageRoute(builder: (context) => /*PickupBothLocationsUser()*/ UserDashboardPage()),
             (Route<dynamic> route) => false,
       );
     }
     else{
       Navigator.of(context)
           .pushReplacement(new MaterialPageRoute(builder: (context) => Login()));
     }

  }

  splashMove() {
    return Timer(Duration(seconds: 4), navigatePage);
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        //resizeToAvoidBottomPadding: false,
        resizeToAvoidBottomInset: true,
        body: Builder(builder: (context){
          return Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                      image: DecorationImage(image: AssetImage("images/ic_logo.png"),)
                  ),
                ),
                Text("Safety and comforts is our concerns ",style: TextStyle(
                    fontSize: 20, fontFamily: "Roboto", fontWeight: FontWeight.w400
                ),)
              ],
            ),
          );
        }),
      ),
    );
  }
}
