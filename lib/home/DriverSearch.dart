
import 'dart:async';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cab/home/driver_on_the_way.dart';

import 'package:flutter_cab/modal/passenger_ride_model.dart';
import 'package:flutter_cab/utils/api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';

class DriverSearch extends StatefulWidget {

  final List rideDetailsList;

  DriverSearch({this.rideDetailsList});

  @override
  SplashScreenState createState() => new SplashScreenState();
}

class SplashScreenState extends State<DriverSearch>
    with SingleTickerProviderStateMixin {


  var _visible = true;

  String _linkMessage;
  bool _isCreatingLink = false;
  BuildContext Applicationcontext;
  String _testString =
      "To test: long press link and then copy and click from a non-browser "
      "app. Make sure this isn't being tested on iOS simulator and iOS xcode "
      "is properly setup. Look at firebase_dynamic_links/README.md for more "
      "details.";
  AnimationController animationController;
  Animation<double> animation;
  List pickupData = [];
  List dropData = [];
  int _counter = 0;
  var arrayPickup;
  var arrayDrop;
  var  passengerDetails;
  bool noDrivers=false;
  var dataList;
  String title = "Title";
  String helper = "helper";
  io.Socket socket;





  startTime() async {
    var _duration = new Duration(seconds: 2);
    return new Timer(_duration, navigationPage);
  }

  void navigationPage() async{
    SharedPreferences localStorage = await SharedPreferences.getInstance();
//    var token = localStorage.getString('token');
    var user = localStorage.getString('user');
    var user_type = localStorage.getString('user_type');
    if(user != null){
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) {
      //       return DashBoardScreen();
      //     },
      //   ),
      // );
      if(user_type=='doctor'){
        Navigator.of(context).pushReplacementNamed('/DoctorHomeScreen');
      }
      else{
        Navigator.of(context).pushReplacementNamed('/PatientHomeScreen');
      }

    }
    else{
      // Navigator.removeRoute(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) {
      //       return WelcomeScreen();
      //     },
      //   ),
      // );
      Navigator.pushReplacementNamed(context, '/Welcome');
    }

  }

  //Socket Implementation Test
  String  contactNum;
  String  userID;
  Future<String> getUserContact() async{
    SharedPreferences localStorage = await SharedPreferences.getInstance();

      setState(() {
        contactNum = localStorage.getString("userContact");
      });


    return contactNum;
  }
  Future<String> getUserID() async{
    SharedPreferences localStorage = await SharedPreferences.getInstance();

      userID = localStorage.getString("_id");

    return userID;
  }

  @override
  void dispose() {
    // TODO: implement dispose
  //  socket.clearListeners();
 //   socket.disconnect();
    print("Socket Disconnected : " + socket.id);
    super.dispose();
  }
  @override
 initState()  {
Applicationcontext = context;
    super.initState();


    // getUserContact().then((value) =>{
    //   print("++++++++CONTACT++++++++++"+value)
    // });
    // getUserID();
  //initSocket();

    animationController = new AnimationController(
        vsync: this, duration: new Duration(seconds: 3));
    animation =
    new CurvedAnimation(parent: animationController, curve: Curves.easeOut);

    animation.addListener(() => this.setState(() {}));
    animationController.forward();

    setState(() {
      _visible = !_visible;
    });
    List data1 = [];


    arrayPickup={
      "address":widget.rideDetailsList[2].toString(),
      "latitude":widget.rideDetailsList[3],
      "longitude":widget.rideDetailsList[4]
    };
    arrayDrop=[{
      "address":widget.rideDetailsList[5].toString(),
      "latitude": widget.rideDetailsList[6],
      "longitude":widget.rideDetailsList[7]
    }];
    passengerDetails={
      "id":widget.rideDetailsList[0].toString(),//"618b6e4c58b8b99484c33e69",//,//,//,
      "contactNumber": widget.rideDetailsList[13].toString()
    };
   // print(await getUserContact().toString()+"==============================hello==============================");
    //contactNum = await getUserContact().toString();




    // pickupData.add('address:'+widget.rideDetailsList[2].toString());
    // pickupData.add('latitude:'+widget.rideDetailsList[3].toString());
    // pickupData.add('longitude:'+widget.rideDetailsList[4].toString());
    // dropData.add('address:'+widget.rideDetailsList[5].toString());
    // pickupData.add('pickupLocation'+data1.toString());

    print(arrayDrop);
    print(arrayPickup);
    _findOnlineDrivers();
    //startTime();
  }

  driverArrivingNotification(String driverName,String vehicalName, String vehicalNumber) async {
    await AwesomeNotifications().createNotification(content: NotificationContent(
      id: 1,
      channelKey: 'driverOnTheWay',
      title: driverName +" is arriving",
      body:"Your Driver is arriving on a "+ vehicalName+"("+vehicalNumber+")",
      //icon: 'images/ic_logo'


    ));
  }


  void initSocket() async {
    String url = "http://173.82.95.250:8101";
    socket = io.io('$url', <String, dynamic>{
      'transports': ["websocket"],
      'autoConnect': true,
    });
  //
    socket.connect();
    if(socket.connected){
      print("Socket Connected===="+socket.id.toString());
      ////eol50FwPh18kq1sOAABu
    }
    else{
      print("Socket not connected");
    }
    var tripAcceptDetails;
    String tripID;
    socket.on('driverDetails', (data) {
      print(data);
      tripID = data['tripId'];
      tripAcceptDetails = {
        'tripId': tripID,
        'socketId':socket.id.toString()
      };
      //socket.emit('getTripAcceptDetails', tripAcceptDetails);
      print(data);
      print(arrayPickup);
      print(arrayDrop);


      socket.emit('getTripAcceptDetails', tripAcceptDetails);
      //socket.clearListeners();
      //socket.clearListeners();
      socket.close();
      driverArrivingNotification(data['driverName'],data['vehicleBrand'],data['vehicleRegistrationNo']);
//driverContactNo
     if(this.mounted){
       Navigator.of(context)
           .push(new MaterialPageRoute(builder: (context) => DriverOnTheWay(driverDetailsData: data,passengerDropData: arrayDrop,passengerPickupData: arrayPickup,)));

     }
         });





    socket.on('CancelTrip', (data) {
      print("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++=====================data");
       // Navigator.of(context)
       //     .push(new MaterialPageRoute(builder: (context) => DriverOnTheWay(driverDetailsData: data,passengerPickupData:pickupData,passengerDropData: dropData,)));
    });

    socket.on('getTripAcceptDetails', (_) => print('Driver DEtails REcived: ${socket.id}'));
   //
    String rawData;

//    socketListen();

    // ignore: unnecessary_statements
    // data2.socketId = socket.id.toString();
    // socket.connect();
    // print(socket.connected.toString()+"  test");
    // if(socket.connected){
    //   print('connected');
    //   print(data2._id+"  "+data2.socketId);
    //    List<driverCheckingModel> list;
    //   list.add(data2);
    //   // String json = jsonEncode(list);
    //   // socket.emit("getTripAcceptDetails",json);
    //   //print(json);
    // }else{
    //   print('socket Error');
    // }
    // socket.onConnect((_) {
    //
    //
    // });
   // try{
    //socket.connect();
   // driverCheckingModel newModel = new driverCheckingModel();
    //newModel._id = data2._id;
  //  newModel.socketId = socket.id.toString();
    //  data2.socketId = socket.id.toString();
      //socket.emit("getTripAcceptDetails",data2);
     // print(data2._id+"  "+ data2.socketId);

      // driverCheckingModel newDriver = new driverCheckingModel();
      // socket.emit("getTripAcceptDetails", jsonEncode(newModel.toJson()));
      // print(jsonEncode(newModel.toJson()));
      // socket.close();
      //socket.emit("getTripAcceptDetails", {"socketID":socket.id.toString(),"tripId":data2._id.toString()});
   //  print({"\""+"socketID"+"\"":"\""+socket.id.toString()+"\"","\""+"tripId"+"\"":"\""+data2._id.toString()+"\""});
   //  }catch(e){
   //    print(e.toString());
   //  }

    socket.on('driverDetails', (args) {
      print("==========================Test Socket=====================");
    });
    var data={
      "passengerId":widget.rideDetailsList[0],
      "address":widget.rideDetailsList[2].toString(),
      "longitude": widget.rideDetailsList[3].toString(),
      "latitude":widget.rideDetailsList[4].toString(),
      "currentStatus":"default"

    };
    // var mainMap = Map<String, Object>();
    // mainMap['passengerId'] = widget.rideDetailsList[0];
    // mainMap['address'] = widget.rideDetailsList[2];
    // mainMap['longitude'] = widget.rideDetailsList[3];
    // mainMap['latitude'] = widget.rideDetailsList[4];
    // mainMap['currentStatus'] = "default";
    // mainMap['socketId'] = socket.id;
    //
    // var myJson = json.encode(mainMap);
    // socket.emit('passengerConnected',myJson);
    // print(socket.connected);

    //

    // socket.on('onDeleted', (data) {
    //   // _listMessages.map((item) {
    //   //   if (item.id == data) {
    //   //     setState(() {
    //   //       item.isDeleted = 1;
    //   //     });
    //   //   }
    //   // }).toList();
    // });
    //
    // socket.on('numberOfConenctedUsers', (data) {
    //
    // });
  }

  createPassengerRide() async {
    final response = await http.post(
      Uri.parse('http://173.82.95.250:8095/trip/findonlinedrivers'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<dynamic, dynamic>{
        'passengerId': widget.rideDetailsList[0],
        'pickupLocation':arrayPickup,
        'dropLocations': arrayDrop,
        'distance': widget.rideDetailsList[8],
        'bidValue': widget.rideDetailsList[11],
        'vehicleCategory': widget.rideDetailsList[9],
        'vehicleSubCategory': widget.rideDetailsList[10],
        'hireCost': widget.rideDetailsList[12],
        'type': 'passengerTrip',
        'validTime': '',
        'payMethod': 'cash',
        'operationRadius':10
      }),
    );

    print(response.body);
    if (response.statusCode == 200) {
      dataList=json.decode(response.body)['notifiedDrivers'];


    } else {
      var result = json.decode(response.body);
      if(result['message']=="No online Drivers"){

        setState(() {


        });
      }
    }
    return "Success";
  }

  void _findOnlineDrivers() async {

    // var datta={
    //   'passengerId': widget.rideDetailsList[0],
    //   'pickupLocation':arrayPickup,
    //   'dropLocations': arrayDrop,
    //   'distance': widget.rideDetailsList[8],
    //   'bidValue': widget.rideDetailsList[11],
    //   'vehicleCategory': widget.rideDetailsList[9],
    //   'vehicleSubCategory': widget.rideDetailsList[10],
    //   'hireCost': widget.rideDetailsList[12],
    //   'type': 'passengerTrip',
    //   'validTime': '',
    //   'payMethod': 'cash',
    //   'operationRadius':20
    // };
    // print(datta);

    await Future.delayed(Duration(milliseconds: 2000));

    var data = {
      'passengerDetails': passengerDetails,
     // 'pickupLocation':arrayPickup,
      'pickupLocation':arrayPickup,
      'dropLocations': arrayDrop,
      'distance': widget.rideDetailsList[8].toString(),
      'bidValue': widget.rideDetailsList[11],
      'vehicleCategory': widget.rideDetailsList[9],
      'vehicleSubCategory': widget.rideDetailsList[10],
      'hireCost': widget.rideDetailsList[12],
      'type': 'passengerTrip',
      'validTime': "45",
      'payMethod': 'cash',
      'operationRadius':2.0
    };

      print(data);
    var res = await Network().postData(data, '/trip/finddriverforpassenger');

    var result = json.decode(res.body);

    print(result);

    print("---------------------- FIND ONLINE DRIVERS ----------------------");
    if (res.statusCode == 200) {
      dataList=json.decode(res.body)['notifiedDrivers'];
      var tripDetails =json.decode(res.body)['content'];

    //var driverDetails=json.decode(res.body)['notifiedDrivers'];

      Map<String, dynamic> map = json.decode(res.body);
     // var socketData = {
     //     'socketId':"",
     //     'tripId': tripDetails[0]["_id"].toString()
     // };
      driverCheckingModel newDrivermodel = driverCheckingModel();
      //newDrivermodel.socketId = tripDetails["socketId"].toString();
      newDrivermodel._id= tripDetails["_id"].toString();
      //initSocket();


    } else {
      var result = json.decode(res.body);
      if(result['message']=="No online Drivers"){
        //createPassengerRide();

        setState(() {

        });
        // Navigator.of(context)
        //     .push(new MaterialPageRoute(builder: (context) => DriverOnTheWay()));
      }
    }
    initSocket();
  }

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop:(){
        Navigator.pop(context);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            new Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[

                Padding(
                  padding: EdgeInsets.only(top: 100.0),
                  // child: new Image.asset(
                  //   'assets/images/powered_by.png',
                  //   height: 25.0,
                  //   fit: BoxFit.scaleDown,
                  // )),
                  child:new Image(
                    image: AssetImage("images/ic_logo.png"),
                    width: 150,
                    height: 150,
                  ),)
              ],
            ),
            new Column(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[

                Padding(
                  padding: EdgeInsets.only(bottom: 290.0),
                  // child: new Image.asset(
                  //   'assets/images/powered_by.png',
                  //   height: 25.0,
                  //   fit: BoxFit.scaleDown,
                  // )),
                  child:new Text('Searching Drivers...', style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Colors.deepOrange
                  )),),
                dataList!=null?Padding(
                    padding: EdgeInsets.only(bottom: 190.0),
                    // child: new Image.asset(
                    //   'assets/images/powered_by.png',
                    //   height: 25.0,
                    //   fit: BoxFit.scaleDown,
                    // )),
                    child:Container(
                      child:ListView.builder(
                        itemExtent: 100,
                        shrinkWrap: true,
                        itemBuilder: (context, i) {

                          return GestureDetector(
                              onTap: () {

                              },
                              child: Card(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30.0)),
                                child: Ink(
                                  decoration: BoxDecoration(
                                      border: Border.all(color: Colors.blue,
                                          width: 3),
                                      // gradient: LinearGradient(colors: [Color(0xFF02aab0    ),Color(0xFF53FFe5) ],
                                      //   begin: Alignment.centerLeft,
                                      //   end: Alignment.centerRight,
                                      // ),
                                      borderRadius: BorderRadius.circular(30.0)
                                  ),
                                  child: ListTile(
                                      leading: CircleAvatar(
                                          radius: 30,
                                          backgroundImage: NetworkImage(dataList[i]['driverPic'].toString())),
                                      title: Text(dataList[i]['driverInfo']['driverName']),
                                      subtitle: Text(dataList[i]['currentLocation']['address']),
                                      trailing: Image.network(dataList[i]['mapIconOntrip'].toString())
                                  ),
                                ),
                              )
                          );
                        },
                        itemCount: dataList.length,
                      ),)
                ):Container()

              ],
            ),
            new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Image.asset(
                  'images/preloader.gif',
                  width: 550,
                  height:  550,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
class Customer {
  String name;
  double value;

  Customer(this.name, this.value);

  @override
  String toString() {
    return '{ ${this.name}: ${this.value} }';
  }
}
class pickLocation{
  String address;
  double latitude;
  double longitude;

}
class driverCheckingModel {
  String socketId;
  String _id;

  // driverCheckingModel(this.socketId, this._id);
  // driverCheckingModel.fromJson(Map<String, dynamic> json)
  //     : name = json['n'],
  //       url = json['u'];

  Map<String, dynamic> toJson() {
    return {
      'socketId': socketId,
      'tripId': _id,
    };
  }
}
