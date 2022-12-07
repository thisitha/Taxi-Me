import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cab/GetDropLocation/location_drop.dart';
import 'package:flutter_cab/UserDashboard/Widgets/custom_button_widgets.dart';
import 'package:flutter_cab/UserDashboard/user_dashboard_styles.dart';
import 'package:flutter_cab/Widgets/SearchCity/place.dart';
import 'package:flutter_cab/home/dropOffMap.dart';
import 'package:flutter_cab/home/book_cab.dart';
import 'package:flutter_cab/modal/favorite_place.dart';
import 'package:flutter_cab/modal/passengerConnectModel.dart';
import 'package:flutter_cab/modal/passengerConnectModel.dart';
import 'package:flutter_cab/modal/passengerConnectModel.dart';
import 'package:flutter_cab/modal/passenger_model.dart';
import 'package:flutter_cab/utils/CustomTextStyle.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';

// import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart';

// import 'package:google_maps_place_picker/google_maps_place_picker.dart';
class PickupBothLocationsUser extends StatefulWidget {


  @override
  _PickupUserState createState() => _PickupUserState();
}

class _PickupUserState extends State<PickupBothLocationsUser> {
  GlobalKey<ScaffoldState> _scaffoldState = GlobalKey();
  var selectedItem;
  TextEditingController _pickupLocationCtrl = new TextEditingController();
  TextEditingController _dropLocationCtrl = new TextEditingController();
  List<FavoritePlace> listFavoritePlace = new List();
  bool isTextWritten = true;
  Position _currentPosition;
  String _currentAddress;
  LatLng pickupPlace;
  LatLng dropPlace;
  String passengerCode = 'passengerCode';
  FlutterToast flutterToast;

  String passengerID;
  String passengerAddress;
  String passengerLatitude;
  String passengerLongitude;
  String passengerCurrentStatus;
  String passengerSocketID;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getUserLocation();
    //getConnectPassengerDetails();
    // _pickupLocationCtrl.text=widget.pickupPlace.display_name.toString();
    createFavoritePlaceList();

    flutterToast = FlutterToast(context);
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
     passengerAddress = _pickupLocationCtrl.text;
 passengerLatitude = pickupPlace.latitude.toString();
    passengerLongitude = pickupPlace.longitude.toString();
     passengerCurrentStatus = "default";
    passengerSocketID = socket.id.toString();
   //var  passengerConnectModel newPassenger;
  //  var  newPassenger = new passengerConnectModel(passengerID,passengerAddress,passengerLatitude,passengerLongitude,passengerCurrentStatus,passengerSocketID);

    setState(() {
      var emitData = {
      'passengerId': passengerID.toString(),
        'address':passengerAddress.toString(),
        'latitude': passengerLatitude.toString(),
        'longitude': passengerLongitude.toString(),
        'currentStatus': passengerCurrentStatus.toString(),
        'socketId' :passengerSocketID
      };
      socket.onConnect((_) {
        print('connect');
        if (this.mounted){
          socket.emit('passengerConnected', emitData);
        }

      });
      print(emitData);

     // print(newPassenger.pa.toString());

      //passengerConnectSocketEmit(newPassenger);
    });



   // return newPassenger;
  }






  displaySharedData() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    String userId = localStorage.getString('userId');
    String email = localStorage.getString('email');
    String passengerCode = localStorage.getString('passengerCode');
    String userProfilePic = localStorage.getString('userProfilePic');
    String token = localStorage.getString('token');

    print(' ----------------------------- USER SAVED: User Dashboard Page ----------------------------- ');
    print('userId: $userId');
    print('email: $email');
    print('passengerCode: $passengerCode');
    print('userProfilePic: $userProfilePic');
    print('token: $token');
  }

  Future<String> getPassengerDetails() async{
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    String userId = localStorage.getString('userId');
    String email = localStorage.getString('email');
    String passengerCode = localStorage.getString('passengerCode');
    String userProfilePic = localStorage.getString('userProfilePic');
    String token = localStorage.getString('token');
    return localStorage.getString('passengerCode');
  }

  createFavoritePlaceList() {
    listFavoritePlace
        .add(createFavorite("GIT - Office", "No.29 Dalugama, Kelaniya"));
    listFavoritePlace.add(
        createFavorite("Katunayake Airport", "No.65 Walukarama Rd, Colombo"));
    listFavoritePlace.add(createFavorite("Home", "Dalugama, Kelaniya"));
    return listFavoritePlace;
  }

  createFavorite(String title, String subtitle) {
    return new FavoritePlace(title, subtitle);
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
      _pickupLocationCtrl.text =
          "${place1.street}, ${place2.thoroughfare}, ${place1.locality}";
      // currentPostion = LatLng(position.latitude, position.longitude);
      //print(placemarks.toString());
      print("Pickup Place: ${_pickupLocationCtrl.text}");
      print("Pickup Place Latitude: ${pickupPlace.latitude}");
      print("Pickup Place Longitude: ${pickupPlace.longitude}");
    });
  }

  _headView() {
    return Padding(
      padding: const EdgeInsets.only(top: 5.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios_rounded,
                      color: UserDashBoardStyles.fontColor,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    "Select Your Route",
                    style: UserDashBoardStyles().textHeading1(),
                  ),
                ],
              ),
              Image.asset(
                'images/user_dashboard/taxime_logo.png',
                height: 70,
                width: 70,
              ),
            ],
          ),
          Image.asset(
            'images/user_dashboard/dashboard_vehicle_service.png',
            width: MediaQuery.of(context).size.width * 0.9,
          ),
        ],
      ),
    );
  }

  _searchBoxesView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 20.0, bottom: 5.0),
          child: Text(
            "Pickup Location",
            style: UserDashBoardStyles().textSubHeading2(),
          ),
        ),
        Container(
          height: 45.0,
          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: GooglePlaceAutoCompleteTextField(
              textEditingController: _pickupLocationCtrl,
              googleAPIKey: "AIzaSyCtg102uMuplrssv_sk_FD-IcKI5hxnnSw",
              inputDecoration: InputDecoration(
                hintText: 'Enter Pickup Location',
                contentPadding: const EdgeInsets.only(left: 10.0),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: UserDashBoardStyles.fontColor,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    Icons.cancel_rounded,
                    color: UserDashBoardStyles.fontColor,
                  ),
                  onPressed: () => createClearTextPickup(),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(
                    color: UserDashBoardStyles.fontColor,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(
                    color: UserDashBoardStyles.fontColor,
                  ),
                ),
              ),
              countries: ["LK"],
              // optional by default null is set
              isLatLngRequired: true,
              // if you required coordinates from place detail
              getPlaceDetailWithLatLng: (Prediction prediction) {
                // this method will return latlng with place detail
                print("placeDetails" + prediction.lng.toString());

                setState(() {
                  pickupPlace = LatLng(double.parse(prediction.lat),
                      double.parse(prediction.lng));
                });
              },
              // this callback is called when isLatLngRequired is true
              itmClick: (Prediction prediction) {
                print(prediction.lat);
                // pickupPlace=LatLng(double.parse(prediction.lat), double.parse(prediction.lng));
                _pickupLocationCtrl.text = prediction.description;
                _pickupLocationCtrl.selection = TextSelection.fromPosition(
                    TextPosition(offset: prediction.description.length));
              }),
        ),
        SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.only(left: 20.0, bottom: 5.0),
          child: Text(
            "Drop Off Location",
            style: UserDashBoardStyles().textSubHeading2(),
          ),
        ),
        Container(
          height: 45.0,
          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: GooglePlaceAutoCompleteTextField(
              textEditingController: _dropLocationCtrl,
              googleAPIKey: "AIzaSyCtg102uMuplrssv_sk_FD-IcKI5hxnnSw",
              inputDecoration: InputDecoration(
                hintText: 'Enter Drop Off Location',
                contentPadding: const EdgeInsets.only(left: 10.0),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: UserDashBoardStyles.fontColor,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    Icons.cancel_rounded,
                    color: UserDashBoardStyles.fontColor,
                  ),
                  onPressed: () => createClearTextDrop(),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(
                    color: UserDashBoardStyles.fontColor,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(
                    color: UserDashBoardStyles.fontColor,
                  ),
                ),
              ),
              countries: ["LK"],
              // optional by default null is set
              isLatLngRequired: true,

              // if you required coordinates from place detail
              getPlaceDetailWithLatLng: (Prediction prediction) {
                // this method will return latlng with place detail
                print("placeDetails" + prediction.lng.toString());

                setState(() {
                  dropPlace = LatLng(double.parse(prediction.lat),
                      double.parse(prediction.lng));
                });
              },
              // this callback is called when isLatLngRequired is true
              itmClick: (Prediction prediction) {
                _dropLocationCtrl.text = prediction.description;
                _dropLocationCtrl.selection = TextSelection.fromPosition(
                    TextPosition(offset: prediction.description.length));
              }),
        ),
      ],
    );
  }

  printRideDetails() async {
    print(" ---------------------- RIDE DETAILS ---------------------- ");
    print("Passenger Code: ${passengerCode = await getPassengerDetails()}");
    print("Is Text Written: ${this.isTextWritten}");
    print("Pickup Place Address: ${_pickupLocationCtrl.text}");
    print("Pickup Place Latitude: ${pickupPlace.latitude}");
    print("Pickup Place Longitude: ${pickupPlace.longitude}");
    print("Drop Place Address: ${_dropLocationCtrl.text}");
    print("Drop Place Latitude: ${dropPlace.latitude}");
    print("Drop Place Longitude: ${dropPlace.longitude}");
  }

  validateRideDetails() {
    if (_dropLocationCtrl.text.isEmpty && _pickupLocationCtrl.text.isEmpty) {
      print("Please select Pickup & Drop Location");
      _showWarningToast("Please select Pickup & Drop Location");
    } else if (_pickupLocationCtrl.text.isEmpty) {
      print("Please select Pickup Location");
      _showWarningToast("Please select Pickup Location");
    } else if (_dropLocationCtrl.text.isEmpty) {
      print("Please select Drop Location");
      _showWarningToast("Please select Drop Location");
    } else {
      printRideDetails();
      Navigator.of(context).push(new MaterialPageRoute(
          builder: (context) => BookWithoutDestination(
              passengerCode = "passengerCode",
              this.isTextWritten,
          _pickupLocationCtrl.text,
          pickupPlace,
          _dropLocationCtrl.text,
              dropPlace,)));
    }
  }

  _showWarningToast(String warningMsg) {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.red,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.warning_rounded,
            color: Colors.white,
          ),
          SizedBox(
            width: 12.0,
          ),
          Text(warningMsg, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
        ],
      ),
    );
    flutterToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: Duration(seconds: 2),
    );
  }


  _continueToRideView() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: CustomButtonWidget(
        color: UserDashBoardStyles.fontColor,
        text: 'Select Ride',
        textColor: UserDashBoardStyles.fontWhiteColor,
        onClicked: () {
          if(dropPlace.latitude!=null){
            validateRideDetails();
          }else{

          }

          //getConnectPassengerDetails();
        },
      ),
    );
  }

  _favouriteLocationsView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Row(
              children: [
                Image.asset(
                  'images/user_dashboard/favourite_places.png',
                  height: 25.0,
                  width: 25.0,
                ),
                SizedBox(
                  width: 10.0,
                ),
                Text(
                  "Favorite Places",
                  style: CustomTextStyle.mediumTextStyle.copyWith(fontSize: 16),
                ),
              ],
            ),
          ),
          ListView.builder(
            itemBuilder: (context, position) {
              return createFavoriteListItem(
                  listFavoritePlace[position], context);
            },
            itemCount: listFavoritePlace.length,
            shrinkWrap: true,
            primary: false,
          ),
        ],
      ),
    );
  }

  _recentLocationsView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Row(
              children: [
                Image.asset(
                  'images/user_dashboard/recent_places.png',
                  height: 25.0,
                  width: 25.0,
                ),
                SizedBox(
                  width: 10.0,
                ),
                Text(
                  "Recently Visited Places",
                  style: CustomTextStyle.mediumTextStyle.copyWith(fontSize: 16),
                ),
              ],
            ),
          ),
          ListView.builder(
            itemBuilder: (context, position) {
              return createRecentlyPlaceListItem(listFavoritePlace[position]);
            },
            itemCount: listFavoritePlace.length,
            shrinkWrap: true,
            primary: false,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        key: _scaffoldState,
        backgroundColor: Colors.white,
        body: ListView(
          physics: BouncingScrollPhysics(),
          children: <Widget>[
            _headView(),
            _searchBoxesView(),
            _continueToRideView(),
            SizedBox(
              height: 10.0,
            ),
            _favouriteLocationsView(),
            _recentLocationsView(),
          ],
        ),
      ),
    );
  }

  createClearTextPickup() {
/*    return Align(
      alignment: Alignment.topRight,
      child: GestureDetector(
        onTap: () {
          _pickupLocationCtrl.clear();
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
    );*/

    _pickupLocationCtrl.clear();
    setState(() {
      isTextWritten = false;
    });
  }

  createClearTextDrop() {
    /*return Align(
      alignment: Alignment.topRight,
      child: GestureDetector(
        onTap: () {
          _dropLocationCtrl.clear();
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
    );*/

    _dropLocationCtrl.clear();
    setState(() {
      isTextWritten = false;
    });
  }

  createFavoriteListItem(
      FavoritePlace listFavoritePlace, BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 8,
          ),
          Container(
            child: Icon(
              Icons.location_on_rounded,
              size: 20,
              color: UserDashBoardStyles.iconLiteColor,
            ),
            margin: EdgeInsets.only(top: 4),
          ),
          SizedBox(
            width: 8,
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: 4,
                ),
                Container(
                  child: Text(
                    listFavoritePlace.title,
                    style: UserDashBoardStyles().textBody2(),
                  ),
                ),
                SizedBox(
                  height: 4,
                ),
                Container(
                  child: Text(
                    listFavoritePlace.subtitle,
                    style: UserDashBoardStyles()
                        .textCustomCaption(UserDashBoardStyles.iconLiteColor),
                  ),
                )
              ],
            ),
            flex: 100,
          ),
          GestureDetector(
            child: Container(
              child: Icon(
                Icons.remove_circle_outline,
                color: UserDashBoardStyles.redColor,
              ),
              margin: EdgeInsets.only(top: 4),
            ),
            onTap: () {
              showDeleteBottomSheet(context);
            },
          ),
        ],
      ),
    );
  }

  createRecentlyPlaceListItem(FavoritePlace listFavoritePlace) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            width: 8,
          ),
          Container(
            child: Icon(
              Icons.location_on_rounded,
              size: 20,
              color: UserDashBoardStyles.iconLiteColor,
            ),
            margin: EdgeInsets.only(top: 4),
          ),
          SizedBox(
            width: 8,
          ),
          Container(
            child: Text(
              listFavoritePlace.subtitle,
              style: UserDashBoardStyles().textBody2(),
            ),
          )
        ],
      ),
    );
  }

  void showDeleteBottomSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext mCtx) {
          return Container(
            height: 120,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10))),
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 16,
                ),
                Text(
                  "Delete Favorite",
                  style: CustomTextStyle.mediumTextStyle,
                ),
                SizedBox(
                  height: 8,
                ),
                Text(
                  "Are you sure you want to delete?",
                  style: CustomTextStyle.regularTextStyle
                      .copyWith(color: Colors.grey, fontSize: 12),
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: Container(
                        child: RaisedButton(
                          onPressed: () {},
                          child: Text(
                            "Yes",
                            style: CustomTextStyle.mediumTextStyle,
                          ),
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(100)),
                              side: BorderSide(color: Colors.grey, width: 1)),
                        ),
                      ),
                      flex: 50,
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: Container(
                        child: RaisedButton(
                          onPressed: () {},
                          child: Text(
                            "No",
                            style: CustomTextStyle.mediumTextStyle,
                          ),
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(100)),
                              side: BorderSide(color: Colors.grey, width: 1)),
                        ),
                      ),
                      flex: 50,
                    ),
                    SizedBox(
                      width: 8,
                    ),
                  ],
                )
              ],
            ),
          );
        });
  }

}
