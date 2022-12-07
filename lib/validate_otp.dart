import 'package:flutter/material.dart';
import 'package:flutter_cab/GetPickupLocation/location_pickup.dart';
import 'package:flutter_cab/UserDashboard/user_dashboard_page.dart';
import 'package:flutter_cab/home/home.dart';
import 'package:flutter_cab/register_account.dart';
import 'package:otp_screen/otp_screen.dart';
import 'package:flutter_cab/utils/api.dart';
import 'TestOSMSearchMap/osm_search_map.dart';
import 'connect_social_account.dart';
import 'login_password.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SuccessfulOtpScreen extends StatefulWidget {
  final String mobileNo;
  final String response;

  SuccessfulOtpScreen(this.mobileNo,this.response) : super();
  @override
  _SuccessfulOtpScreen createState() => _SuccessfulOtpScreen();
}
class _SuccessfulOtpScreen extends State<SuccessfulOtpScreen> {
  // This widget is the root of your application.

  Future<String> validateOtp(String otp) async {
    var res;
    // await Future.delayed(Duration(milliseconds: 2000));
    var data = {'ContactNumber': widget.mobileNo, 'pin': int.parse(otp)};
    if (widget.response == 'signup') {
      res = await Network().postData(data, '/user/validateOTP');
    } else {
      res = await Network().postData(data, '/user/validateLoginOTP');
    }

    var result = json.decode(res.body);
    print(result);
    if (result['message'] == "loggedin") {

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => RegisterCustomer(widget.mobileNo)),
        (Route<dynamic> route) => false,
      );
    } else {
      //print(result+"---------------------------");
      //SharedPreferences.setMockInitialValues({});
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      localStorage.setString('userId', result['user']['_id']);
      localStorage.setString('email', result['user']['email']);
      localStorage.setString('contactNumber',result['user']['contactNumber']);
      localStorage.setString('passengerCode', result['user']['passengerCode']);
      localStorage.setString('userProfilePic', result['user']['userProfilePic']);
      localStorage.setString('token', result['user']['token']);
      displaySharedData();
      //saveUserWithGetStorage(result);
      Navigator.pushAndRemoveUntil(
        context,
        //MaterialPageRoute(builder: (context) => Home()),
/*        MaterialPageRoute(builder: (context) => LocationPickup()),
            (Route<dynamic> route) => false,*/
        MaterialPageRoute(builder: (context) => UserDashboardPage()),
        (Route<dynamic> route) => false,
      );
    }
  }

  displaySharedData() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    String userId = localStorage.getString('userId');
    String email = localStorage.getString('email');
    String passengerCode = localStorage.getString('passengerCode');
    String userProfilePic = localStorage.getString('userProfilePic');
    String token = localStorage.getString('token');
    String number = localStorage.getString('contactNumber');
    print(' ----------------------------- USER SAVED: Validate OTP ----------------------------- ');
    print('userId: $userId');
    print('email: $email');
    print('passengerCode: $passengerCode');
    print('userProfilePic: $userProfilePic');
    print('token: $token');
    print('token: $number');
  }


/*  saveUserWithGetStorage(var result){
    final box = GetStorage();
    box.write('userId', result['user']['_id']);
    box.write('email', result['user']['email']);
    box.write('passengerCode', result['user']['passengerCode']);
    box.write('userProfilePic', result['user']['userProfilePic']);
    box.write('token', result['user']['token']);
  }

  displayUserWithGetStorage(var result){
    final box = GetStorage();
    print("userId: ${box.read('userId')}");
    print("email: ${box.read('email')}");
    print("passengerCode: ${box.read('passengerCode')}");
    print("passengerCode: ${box.read('passengerCode')}");
    print("token: ${box.read('token')}");
  }*/


  // void moveToNextScreen(context) {
  //   Navigator.push(context, MaterialPageRoute(
  //       builder: (context) => SuccessfulOtpScreen()));
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
/*      appBar: AppBar(
        title: Text('OTP Validation'),
      ),*/
      body: OtpScreen.withGradientBackground(
        topColor: Color(0xFFcc2b5e),
        bottomColor: Color(0xFF753a88),
        otpLength: 4,
        validateOtp: validateOtp,
        // routeCallback: moveToNextScreen,
        themeColor: Colors.white,
        titleColor: Colors.white,
        title: "Phone Number Verification",
        subTitle: "Enter the code sent to \n "+widget.mobileNo.toString(),
        icon: Image.asset(
          'images/phone_logo.png',
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}