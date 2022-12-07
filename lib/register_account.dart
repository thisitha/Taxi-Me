import 'package:flutter/material.dart';
import 'package:flutter_cab/home/home.dart';
import 'package:flutter_cab/utils/CustomTextStyle.dart';
import 'package:flutter_cab/verify_code.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter_cab/utils/api.dart';
import 'connect_social_account.dart';
import 'login_password.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
class RegisterCustomer extends StatefulWidget {
  final String mobileNo;

  RegisterCustomer(this.mobileNo) : super();
  @override
  _RegisterCustomer createState() => _RegisterCustomer();
}

class _RegisterCustomer extends State<RegisterCustomer> {
  bool isTextWritten = false;
  final _formKey = GlobalKey<FormState>();
  TextEditingController _mobileNumberController = new TextEditingController();
  TextEditingController _emailControleer = new TextEditingController();
  TextEditingController _userNameController = new TextEditingController();
  TextEditingController _birthDayController = new TextEditingController();
  var dob;
  var sex;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      _mobileNumberController.text=widget.mobileNo.toString();
    });
  }
  @override
  Widget build(BuildContext context) {
    final format = DateFormat("MM/dd");
    String _dropDownValue;
    return Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Card(
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
              child: Form(
              key: _formKey,
              child:Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Container(
                  //   alignment: Alignment.center,
                  //   child: Image(
                  //     image: AssetImage("images/ic_logo.png"),
                  //     width: 80,
                  //     height: 80,
                  //   ),
                  // ),
                  Container(
                    height: 140.0,
                    color: Colors.white,
                    child: new Column(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(top: 15.0),
                          child: new Stack(fit: StackFit.loose, children: <Widget>[
                            new Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                new Container(
                                    width: 100.0,
                                    height: 100.0,
                                    decoration: new BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: new DecorationImage(
                                        image: new AssetImage("images/ic_logo.png"),
                                        fit: BoxFit.cover,
                                      ),
                                    )),
                              ],
                            ),
                            Padding(
                                padding: EdgeInsets.only(top: 50.0, right: 70.0),
                                child:GestureDetector(
                                  onTap: ()async{
                                    var file = await ImagePicker.pickImage(source: ImageSource.gallery);
                                    var res = await uploadImage(file.path, widget.mobileNo);
                                    setState(() {
                                      // state = res;
                                      print(res);
                                    });
                                  },
                                  child: new Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      new CircleAvatar(
                                        backgroundColor: Colors.red,
                                        radius: 20.0,
                                        child: new Icon(
                                          Icons.camera_alt,
                                          color: Colors.white,
                                        ),
                                      )
                                    ],
                                  ),
                                ) ),
                          ]),
                        )
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 16, top: 8),
                    child: Text(
                      "Mobile No",
                      style: CustomTextStyle.regularTextStyle,
                    ),
                  ),
                  SizedBox(height: 3),
                  Container(
                    margin: EdgeInsets.only(right: 14, left: 14),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Container(
                            child: Stack(
                              alignment: Alignment.center,
                              children: <Widget>[
                                TextFormField(
                                  decoration: InputDecoration(
                                    border: border,
                                    enabledBorder: border,
                                    focusedBorder: border,
                                    contentPadding: EdgeInsets.only(
                                        left: 8, right: 32, top: 6, bottom: 6),
                                    hintText: "Enter your Mobile No",
                                    hasFloatingPlaceholder: true,
                                    hintStyle: CustomTextStyle.regularTextStyle
                                        .copyWith(
                                        color: Colors.grey, fontSize: 12),
                                    labelStyle: CustomTextStyle.regularTextStyle
                                        .copyWith(
                                        color: Colors.black, fontSize: 12),
                                  ),
                                  controller: _mobileNumberController,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (mobile) {
                                    if (mobile.isEmpty) {
                                      return 'Please Enter Mobile No';
                                    }
                                    return null;
                                  },
                                ),

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
                  Container(
                    margin: EdgeInsets.only(left: 16, top: 8),
                    child: Text(
                      "Email address",
                      style: CustomTextStyle.regularTextStyle,
                    ),
                  ),
                  SizedBox(height: 3),
                  Container(
                    margin: EdgeInsets.only(right: 14, left: 14),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Container(
                            child: Stack(
                              alignment: Alignment.center,
                              children: <Widget>[
                                TextFormField(
                                  decoration: InputDecoration(
                                    border: border,
                                    enabledBorder: border,
                                    focusedBorder: border,
                                    contentPadding: EdgeInsets.only(
                                        left: 8, right: 32, top: 6, bottom: 6),
                                    hintText: "Enter your email address",
                                    hasFloatingPlaceholder: true,
                                    hintStyle: CustomTextStyle.regularTextStyle
                                        .copyWith(
                                        color: Colors.grey, fontSize: 12),
                                    labelStyle: CustomTextStyle.regularTextStyle
                                        .copyWith(
                                        color: Colors.black, fontSize: 12),
                                  ),
                                  controller: _emailControleer,
                                  keyboardType: TextInputType.emailAddress,

                                ),

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
                  Container(
                    margin: EdgeInsets.only(left: 16, top: 8),
                    child: Text(
                      "Username",
                      style: CustomTextStyle.regularTextStyle,
                    ),
                  ),
                  SizedBox(height: 3),
                  Container(
                    margin: EdgeInsets.only(right: 14, left: 14),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Container(
                            child: Stack(
                              alignment: Alignment.center,
                              children: <Widget>[
                                TextFormField(
                                  decoration: InputDecoration(
                                    border: border,
                                    enabledBorder: border,
                                    focusedBorder: border,
                                    contentPadding: EdgeInsets.only(
                                        left: 8, right: 32, top: 6, bottom: 6),
                                    hintText: "Enter Username",
                                    hasFloatingPlaceholder: true,
                                    hintStyle: CustomTextStyle.regularTextStyle
                                        .copyWith(
                                        color: Colors.grey, fontSize: 12),
                                    labelStyle: CustomTextStyle.regularTextStyle
                                        .copyWith(
                                        color: Colors.black, fontSize: 12),
                                  ),
                                  controller: _userNameController,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (email) {
                                    if (email.isEmpty) {
                                      return 'Please Enter Username';
                                    }
                                    return null;
                                  },
                                ),

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
                  Container(
                    margin: EdgeInsets.only(left: 16, top: 8),
                    child: Text(
                      "Gender",
                      style: CustomTextStyle.regularTextStyle,
                    ),
                  ),
                  SizedBox(height: 3),
                  Container(
                    margin: EdgeInsets.only(right: 14, left: 14),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Container(
                            child: Stack(
                              alignment: Alignment.center,
                              children: <Widget>[
                                DropdownButtonFormField<String>(
                                  decoration: InputDecoration(
                                    prefixIcon: Icon(
                                      Icons.person,
                                    ),
                                    hintText: "Select Gender Type ",
                                    hintStyle: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.normal),
                                  ),
                                  value: _dropDownValue,
                                  items: ["Male", "Female"]
                                      .map((label) => DropdownMenuItem(
                                    child: Text(label),
                                    value: label,
                                  ))
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() => _dropDownValue = value);
                                  },
                                  validator: (sexValue) {
                                    // if (sexValue.isEmpty) {
                                    //   return 'Please enter email';
                                    // }
                                    // else{
                                      if(sexValue=='Male'){
                                        sex = 'male';
                                      }
                                      else{
                                        sex = 'female';
                                      }
                                    // }


                                    return null;
                                  },
                                ),

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
                  SizedBox(height: 16),
                  Container(
                    margin: EdgeInsets.only(left: 16, top: 8),
                    child: Text(
                      "Birthday",
                      style: CustomTextStyle.regularTextStyle,
                    ),
                  ),
                  SizedBox(height: 3),
                  Container(
                    margin: EdgeInsets.only(right: 14, left: 14),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Container(
                            child: Stack(
                              alignment: Alignment.center,
                              children: <Widget>[
                                DateTimeField(
                                  format: format,
                                  onShowPicker: (context, currentValue) {

                                    return showDatePicker(
                                        context: context,
                                        firstDate: DateTime(1900),
                                        initialDate: currentValue ?? DateTime.now(),
                                        lastDate: DateTime(2100));
                                  },
                                  decoration: InputDecoration(
                                    prefixIcon: Icon(
                                      Icons.date_range,
                                    ),
                                    hintText: "Date of Birth",
                                    hintStyle: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.normal),
                                  ),
                                  onChanged: (date){
                                    print(date);
                                    var day=date.day;
                                    var month=date.month;
                                    var datee=month.toString()+'/'+day.toString();
                                    print(datee);
                                  },
                                  validator: (dateOfBirthValue) {
                                    var day=dateOfBirthValue.day;
                                    var month=dateOfBirthValue.month;
                                    var datee=month.toString()+'/'+day.toString();
                                    dob = datee;

                                    return null;
                                  },
                                ),

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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          print('Clicked');

                        },
                        child:Container(
                          width: 370,
                          margin: EdgeInsets.only(right: 16, left: 16),
                          child: RaisedButton(
                            onPressed: () async {
                                  if (_formKey.currentState.validate()) {
                                    RegisterAccount();
                                  }

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
                      // GestureDetector(
                      //   onTap: (){
                      //     if (_formKey.currentState.validate()) {
                      //       // _register();
                      //     }
                      //     // Navigator.push(context, new MaterialPageRoute(builder: (context)=>VerifyCode()));
                      //   },
                      //   child: Container(
                      //     width: 40,
                      //     margin: EdgeInsets.only(right: 10),
                      //     height: 40,
                      //     decoration: BoxDecoration(
                      //         color: Colors.grey, shape: BoxShape.circle),
                      //     child: Icon(
                      //       Icons.arrow_forward,
                      //       color: Colors.white,
                      //     ),
                      //   ),
                      // )
                    ],
                  ),
                  SizedBox(height: 24),
                ],
              ),
              ),
            ),
          ),
        ),
      );

  }
  Future<String> uploadImage(filename, url) async {
    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.files.add(await http.MultipartFile.fromPath('picture', filename));
    var res = await request.send();
    return res.reasonPhrase;
  }
  RegisterAccount() async {
    // await Future.delayed(Duration(milliseconds: 2000));
    var data = {
      'ContactNumber': _mobileNumberController.text,
    'email':_emailControleer.text,
    'UserName ':_userNameController.text,
      'Gender':sex,
    'Birthday':dob,
    'UserPlatform':'android',
    'userProfilePic':''};
    var res = await Network().postData(data, '/user/signup');
    var result=json.decode(res.body);
    print(result);
    if (result['message'] == "signedin") {
      SharedPreferences.setMockInitialValues({});
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      localStorage.setString('userContact', result['ContactNumber']);
      localStorage.setString('userId', result['user']['_id']);
      localStorage.setString('email', result['user']['email']);
      localStorage.setString('passengerCode', result['user']['passengerCode']);
      localStorage.setString('userProfilePic', result['user']['userProfilePic']);
      localStorage.setString('token', result['user']['token']);

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => Home()),
            (Route<dynamic> route) => false,
      );
    } else {
      return "The entered OTP is wrong";
    }
  }

  var border = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(4)),
      borderSide: BorderSide(color: Colors.white, width: 1));
}
