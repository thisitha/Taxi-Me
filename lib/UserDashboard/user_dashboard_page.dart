import 'package:flutter/material.dart';
import 'package:flutter_cab/GetBothLocation/getbothlocations.dart';
import 'package:flutter_cab/UserDashboard/foods_page.dart';
import 'package:flutter_cab/UserDashboard/packages_page.dart';
import 'package:flutter_cab/UserDashboard/ride_page.dart';
import 'package:flutter_cab/UserDashboard/user_dashboard_styles.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong/latlong.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart';

class UserDashboardPage extends StatefulWidget {
  const UserDashboardPage({Key key}) : super(key: key);

  @override
  _UserDashboardPageState createState() => _UserDashboardPageState();
}

class _UserDashboardPageState extends State<UserDashboardPage> {

  LatLng pickupPlace;
  String passengerID;
  String passengerAddress;
  String passengerLatitude;
  String passengerLongitude;
  String passengerCurrentStatus;
  String passengerSocketID;
  bool passengerConnected = true;
  displaySharedData() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    String userId = localStorage.getString('userId');
    String email = localStorage.getString('email');
    String passengerCode = localStorage.getString('passengerCode');
    String userProfilePic = localStorage.getString('userProfilePic');
    String token = localStorage.getString('token');
 // var location =GPSTracker
    print(' ----------------------------- USER SAVED: User Dashboard Page ----------------------------- ');
    print('userId: $userId');
    print('email: $email');
    print('passengerCode: $passengerCode');
    print('userProfilePic: $userProfilePic');
    print('token: $token');
  }

  void _getUserLocation() async {
    var position = await GeolocatorPlatform.instance
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemarks =
    await placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark place1 = placemarks[0];
    Placemark place2 = placemarks[1];
    setState(() {
      pickupPlace = LatLng(position.latitude, position.longitude);
      GetAddressFromLatLong(position);
   // print(position);
      // _pickupLocationCtrl.text =
      // "${place1.street}, ${place2.thoroughfare}, ${place1.locality}";
      // currentPostion = LatLng(position.latitude, position.longitude);
      //print(placemarks.toString());
   //   print("Pickup Place: ${_pickupLocationCtrl.text}");
      print("Pickup Place Latitude: ${pickupPlace.latitude}");
      print("Pickup Place Longitude: ${pickupPlace.longitude}");
    });
  }
  Future<void> GetAddressFromLatLong(Position position)async {
    List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
    print(placemarks);
    Placemark place = placemarks[0];
    passengerAddress = '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';
    print("Pickup Place Address: $passengerAddress");
    getConnectPassengerDetails();
  }
  void getConnectPassengerDetails()async{
    String url = "http://173.82.95.250:8101";
    Socket socket = io('$url', <String, dynamic>{
      'transports': ["websocket"],
      'autoConnect': true,
    });
    socket.connect();
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    String userId = localStorage.getString('userId');
    passengerID = userId;
    //passengerAddress
    passengerLatitude = pickupPlace.latitude.toString();
    passengerLongitude = pickupPlace.longitude.toString();
    passengerCurrentStatus = "default";
    passengerSocketID = socket.id.toString();
    //var  passengerConnectModel newPassenger;
    //  var  newPassenger = new passengerConnectModel(passengerID,passengerAddress,passengerLatitude,passengerLongitude,passengerCurrentStatus,passengerSocketID);

    setState(() {

      //print(emitData);
      socket.onConnect((data) => (){
        print("Socket Connected"+socket.id);
      });
      socket.onConnect((_) {
        print('connect');
        var emitData = {
          'passengerId': passengerID.toString(),
          'address':passengerAddress.toString(),
          'latitude': passengerLatitude.toString(),
          'longitude': passengerLongitude.toString(),
          'currentStatus': passengerCurrentStatus.toString(),
          'socketId' :socket.id
        };
        print(emitData);
        if (this.mounted){
          socket.emit('passengerConnected', emitData);
        }

      });
      //print(emitData);

      // print(newPassenger.pa.toString());

      //passengerConnectSocketEmit(newPassenger);
    });



    // return newPassenger;
  }


  _drawerMenu() {
    if(passengerConnected){
      _getUserLocation();
      passengerConnected = false;
    }
    //displaySharedData();
    //_getUserLocation();

    return Drawer(
      child: ListView(
        physics: BouncingScrollPhysics(),
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            padding: const EdgeInsets.symmetric(horizontal: 0.0),
            child: Stack(
              children: [
                Container(
                  alignment: Alignment.center,
                  color: Color.fromRGBO(249, 168, 38, 1),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: Image.asset(
                      'images/user_dashboard/drawer_header_3.png',
                      width: MediaQuery.of(context).size.width,
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: CircleAvatar(
                      radius: 40.0,
                      backgroundImage:
                          NetworkImage('https://via.placeholder.com/150'),
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                )
              ],
            ),
          ),
          ListTile(
            title: Row(
              children: [
                Icon(
                  Icons.directions_car_rounded,
                  color: UserDashBoardStyles.fontColor,
                ),
                SizedBox(
                  width: 10.0,
                ),
                const Text('Ride'),
              ],
            ),
            onTap: () {
              // Update the state of the app
              // ...
              // Then close the drawer
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Row(
              children: [
                Icon(
                  Icons.fastfood_rounded,
                  color: UserDashBoardStyles.fontColor,
                ),
                SizedBox(
                  width: 10.0,
                ),
                const Text('Foods'),
              ],
            ),
            onTap: () {
              // Update the state of the app
              // ...
              // Then close the drawer
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Row(
              children: [
                Icon(
                  Icons.backpack_rounded,
                  color: UserDashBoardStyles.fontColor,
                ),
                SizedBox(
                  width: 10.0,
                ),
                const Text('Packages'),
              ],
            ),
            onTap: () {
              // Update the state of the app
              // ...
              // Then close the drawer
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Row(
              children: [
                Icon(
                  Icons.lightbulb,
                  color: UserDashBoardStyles.fontColor,
                ),
                SizedBox(
                  width: 10.0,
                ),
                const Text('Your Tips'),
              ],
            ),
            onTap: () {
              // Update the state of the app
              // ...
              // Then close the drawer
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Row(
              children: [
                Icon(
                  Icons.account_balance_wallet_rounded,
                  color: UserDashBoardStyles.fontColor,
                ),
                SizedBox(
                  width: 10.0,
                ),
                const Text('Wallet'),
              ],
            ),
            onTap: () {
              // Update the state of the app
              // ...
              // Then close the drawer
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Row(
              children: [
                Icon(
                  Icons.help_rounded,
                  color: UserDashBoardStyles.fontColor,
                ),
                SizedBox(
                  width: 10.0,
                ),
                const Text('Help'),
              ],
            ),
            onTap: () {
              // Update the state of the app
              // ...
              // Then close the drawer
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Row(
              children: [
                Icon(
                  Icons.settings_rounded,
                  color: UserDashBoardStyles.fontColor,
                ),
                SizedBox(
                  width: 10.0,
                ),
                const Text('Settings'),
              ],
            ),
            onTap: () {
              // Update the state of the app
              // ...
              // Then close the drawer
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Row(
              children: [
                Icon(
                  Icons.airport_shuttle_rounded,
                  color: UserDashBoardStyles.fontColor,
                ),
                SizedBox(
                  width: 10.0,
                ),
                const Text('Drive with TaxiMe'),
              ],
            ),
            onTap: () {
              // Update the state of the app
              // ...
              // Then close the drawer
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Row(
              children: [
                Icon(
                  Icons.note_rounded,
                  color: UserDashBoardStyles.fontColor,
                ),
                SizedBox(
                  width: 10.0,
                ),
                const Text('Legal'),
              ],
            ),
            onTap: () {
              // Update the state of the app
              // ...
              // Then close the drawer
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  _quickStartButton(String imageName, String typeName, className) {
    return GestureDetector(
      child: Column(
        children: [
          Container(
            height: 60.0,
            width: 60.0,
            decoration: BoxDecoration(
              border: Border.all(
                color: UserDashBoardStyles.quickStartBackground,
                style: BorderStyle.solid,
                width: 1.0,
              ),
              color: UserDashBoardStyles.quickStartBackground,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Image.asset(imageName),
            ),
          ),
          SizedBox(
            height: 10.0,
          ),
          Text(
            "$typeName",
            style: UserDashBoardStyles().textCaption(),
          ),
        ],
      ),
      onTap: () => Navigator.of(context)
          .push(new MaterialPageRoute(builder: (context) => className)),
    );
  }
  String greeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Hello Good Morning!';
    }
    if (hour < 17) {
      return 'Hello Good Afternoon!';
    }
    return 'Hello Good Evening!';
  }

  @override
  void initState() {
    displaySharedData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UserDashBoardStyles.scaffoldColor,
      appBar: AppBar(
        backgroundColor: UserDashBoardStyles.scaffoldColor,
        elevation: 0.0,
        iconTheme: IconThemeData(color: UserDashBoardStyles.fontColor),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_rounded),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.settings_rounded),
            onPressed: () {},
          )
        ],
      ),
      drawer: _drawerMenu(),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting(),
                style: UserDashBoardStyles().textHeading1(),
              ),
              Image.asset(
                'images/user_dashboard/dashboard_office.png',
                width: MediaQuery.of(context).size.width,
              ),
              Text(
                "Quick Start",
                style: UserDashBoardStyles().textSubHeading1(),
              ),
              SizedBox(
                height: 25.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _quickStartButton('images/user_dashboard/tab_car.png', 'Ride',
                      PickupBothLocationsUser()),
                  _quickStartButton('images/user_dashboard/tab_foods.png',
                      'Foods', FoodsPage()),
                  _quickStartButton('images/user_dashboard/tab_package.png',
                      'Package', PackagesPage()),
                ],
              ),
              SizedBox(
                height: 25.0,
              ),
              Lottie.network(
                  'https://assets1.lottiefiles.com/packages/lf20_bhebjzpu.json',
                  width: MediaQuery.of(context).size.width),
/*              Image.asset(
                'images/user_dashboard/dashboard_vehicle_service.png',
                width: MediaQuery.of(context).size.width,
              ),*/
            ],
          ),
        ),
      ),
    );
  }
}
