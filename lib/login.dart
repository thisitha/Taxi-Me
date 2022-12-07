import 'package:flutter/material.dart';
import 'package:flutter_cab/utils/CustomTextStyle.dart';
import 'package:flutter_cab/validate_otp.dart';
//import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_cab/utils/api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'connect_social_account.dart';
import 'login_password.dart';
import 'dart:convert';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  var selectedItem;
  TextEditingController _mobileNumberController = new TextEditingController();

  bool isTextWritten = false;
  String mobileNo;

  var selectedValue = "+94";

  createCountryCodeList() {
    List<DropdownMenuItem<String>> countryCodeList = new List();
    countryCodeList.add(createDropdownItem("+94"));
    // countryCodeList.add(createDropdownItem("+92"));
    // countryCodeList.add(createDropdownItem("+93"));
   // countryCodeList.add(createDropdownItem("+91"));
    // countryCodeList.add(createDropdownItem("+95"));
    // countryCodeList.add(createDropdownItem("+96"));
    // countryCodeList.add(createDropdownItem("+97"));
    return countryCodeList;
  }

  createDropdownItem(String code) {
    return DropdownMenuItem(
      value: code,
      child: Text(code),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return MaterialApp(
      home: Scaffold(

        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Builder(
            builder: (context) {
              return Card(
                elevation: 4,
                borderOnForeground: true,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(16),
                        bottomLeft: Radius.circular(16))),
                margin: EdgeInsets.only(left: 0, right: 0, bottom: 4),
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(16),
                          bottomLeft: Radius.circular(16)),
                      shape: BoxShape.rectangle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(color: Colors.grey.shade50, blurRadius: 5),
                      ]),
                  width: double.infinity,
                  padding: EdgeInsets.only(top: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(height: 14),
                      Container(
                        alignment: Alignment.center,
                        child: Image(
                          image: AssetImage("images/ic_logo.png"),
                          width: 120,
                          height: 120,
                        ),
                      ),
                      SizedBox(height: 14),
                      Container(
                        margin: EdgeInsets.only(left: 16, top: 8),
                        child: Text(
                          "Ride with TaxiMe Cabs",
                          style: CustomTextStyle.regularTextStyle,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 16, top: 4),
                        child: Text(
                          "Enter your mobile number to Login or Register",
                          style: CustomTextStyle.regularTextStyle.copyWith(
                              color: Colors.grey,
                              fontSize: 12,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                      SizedBox(height: 14),
                      Container(
                        margin: EdgeInsets.only(right: 14, left: 14),
                        child: Row(
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.only(
                                  left: 8, right: 8, top: 4, bottom: 4),
                              decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(6)),
                                  border:
                                      Border.all(color: Colors.grey.shade400)),
                              child: DropdownButton(
                                items: createCountryCodeList(),
                                onChanged: (change) {
                                  setState(() {
                                    this.selectedValue = change;
                                  });
                                },
                                value: selectedValue,
                                isDense: true,
                                underline: Container(),
                              ),
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            Expanded(
                              child: Container(
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: <Widget>[
                                    TextField(
                                      maxLength: 9,
                                      decoration: InputDecoration(
                                        prefixText: '0',
                                        prefixStyle: TextStyle(color: Colors.black, fontSize: 15),
                                        border: border,
                                        enabledBorder: border,
                                        focusedBorder: border,
                                        contentPadding: EdgeInsets.only(
                                            left: 8,
                                            right: 32,
                                            top: 6,
                                            bottom: 6),
                                        hintText: "Mobile Number",
                                        hasFloatingPlaceholder: true,
                                        hintStyle: CustomTextStyle
                                            .regularTextStyle
                                            .copyWith(
                                                color: Colors.grey, fontSize: 12),
                                        labelStyle: CustomTextStyle
                                            .regularTextStyle
                                            .copyWith(
                                                color: Colors.black,
                                                fontSize: 12),
                                      ),

                                      onChanged: (value) {
                                        if (value.trim().length > 0) {
                                          setState(() {
                                            this.isTextWritten = true;
                                          });
                                        } else {
                                          this.isTextWritten = false;
                                        }
                                      },
                                      controller: _mobileNumberController,
                                      keyboardType: TextInputType.phone,
                                    ),
                                    createClearText()
                                  ],
                                ),
                                decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(4)),
                                    border: Border.all(
                                        width: 1, color: Colors.grey.shade400)),
                              ),
                              flex: 100,
                            )
                          ],
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          // GestureDetector(
                          //   onTap: (){
                          //     Navigator.of(context).push(new MaterialPageRoute(builder: (context)=>CreateSocialAccount()));
                          //   },
                          //   child: Container(
                          //     child: Text(
                          //       "Or connect with social account",
                          //       style: CustomTextStyle.mediumTextStyle.copyWith(
                          //           color: Colors.grey.shade600, fontSize: 12),
                          //     ),
                          //     margin: EdgeInsets.only(left: 18),
                          //   ),
                          // ),
                          // GestureDetector(
                          //   onTap: () {
                          //     Navigator.of(context).push(new MaterialPageRoute(
                          //         builder: (context) => LoginPassword()));
                          //   },
                          //   child: Container(
                          //     width: 40,
                          //     margin: EdgeInsets.only(right: 10),
                          //     height: 40,
                          //     decoration: BoxDecoration(
                          //         color: Colors.amber, shape: BoxShape.circle),
                          //     child: Icon(
                          //       Icons.arrow_forward,
                          //       color: Colors.white,
                          //     ),
                          //   ),
                          // )
                          GestureDetector(
                            onTap: () {
                              print('Clicked');

                            },
                            child:Container(
                              width: 370,
                              margin: EdgeInsets.only(right: 16, left: 16),
                              child: RaisedButton(
                                onPressed: () async {

                                  await LoginWithMobile();
                                  // sendOTPCode();
                                  // Navigator.of(context).push(new MaterialPageRoute(
                                  //     builder: (context) => SuccessfulOtpScreen(int.parse(_mobileNumberController.text))));

                                },
                                child: Text(
                                  "Connect with TaxiMe",
                                  style: CustomTextStyle.mediumTextStyle
                                      .copyWith(color: Colors.white, fontSize: 14),
                                ),
                                textColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(24))),
                                color: Colors.orangeAccent,
                              ),
                            ),
                          ),

                        ],
                      ),
                      SizedBox(height: 24),
                      Image.asset(
                        "images/undraw_town_r6pc.png",
                        height: size.height * 0.50,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  createClearText() {
    if (isTextWritten) {
      return Align(
        alignment: Alignment.topRight,
        child: GestureDetector(
          onTap: () {
            _mobileNumberController.clear();
            setState(() {
              isTextWritten = false;
            });
          },
          child: Container(
            margin: EdgeInsets.only(right: 8),
            width: 16,
            height: 16,
            decoration: BoxDecoration(
                color: Colors.grey.shade400, shape: BoxShape.circle),
            child: Icon(
              Icons.close,
              size: 14,
              color: Colors.white,
            ),
            alignment: Alignment.center,
          ),
        ),
      );
    } else {
      return Align(
        alignment: Alignment.topRight,
        child: Container(),
      );
    }
  }

  var border = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(4)),
      borderSide: BorderSide(color: Colors.white, width: 1));

  //Send Message through the Backend
   sendOTPCode() async {
    var data = {'ContactNumber': _mobileNumberController.text};
    var res = await Network().postData(data, '/user/registerOTP');
    return json.decode(res.body);
  }
   LoginWithMobile() async {
    // await Future.delayed(Duration(milliseconds: 2000));
     var txtMobile=_mobileNumberController.text;
     print('${txtMobile[0]}');
     if('${txtMobile[0]}'!='0'){
       var mobile='0'+_mobileNumberController.text;
       print('awaa');
       print(mobile);
       mobileNo=mobile;
       print(mobileNo);
     }
     else{
       mobileNo=_mobileNumberController.text;
     }

    var data_login = {'ContactNumber': mobileNo};
    var res = await Network().postData(data_login, '/user/login');
    var result=json.decode(res.body);
    print(result);
    if (result['message'] == "signup") {
      var data = {'ContactNumber': mobileNo};
      var res1 = await Network().postData(data, '/user/registerOTP');
      var result1=json.decode(res1.body);
      print(res.body);
      if(result1['message'] == "success"){

        Navigator.of(context).push(new MaterialPageRoute(
            builder: (context) => SuccessfulOtpScreen(mobileNo,result['message'])));
      }

    } else {

      Navigator.of(context).push(new MaterialPageRoute(
          builder: (context) => SuccessfulOtpScreen(mobileNo,result['message'])));
    }
  }
}
