import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter_cab/GetDropLocation/location_drop.dart';
import 'package:flutter_cab/fare_info.dart';
import 'package:flutter_cab/home/DriverSearch.dart';
import 'package:flutter_cab/home/book_cab.dart';
import 'package:flutter_cab/home/trip_end.dart';
import 'package:flutter_cab/utils/CustomTextStyle.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:syncfusion_flutter_maps/maps.dart';
import 'package:url_launcher/url_launcher.dart';
import 'cancel_trip.dart';
import 'cancel_trip_feedback.dart';
import 'dialog/payment_dialog.dart';
import 'dialog/promo_code_dialog.dart';
import 'package:google_maps_webservice/directions.dart' as directions;

class DriverOnTheWay extends StatefulWidget {
  var driverDetailsData;
  var passengerPickupData;
  List passengerDropData = [];
  String appTitle;


  DriverOnTheWay(
      {this.driverDetailsData,
      this.passengerDropData,
      this.passengerPickupData,
      this.appTitle});
  @override
  _DriverOnTheWayState createState() => _DriverOnTheWayState();
}

class _DriverOnTheWayState extends State<DriverOnTheWay> {
//  String passengerLat passengerLat=  double.parse();
  var _ahmedabad; //= LatLng(7.06140169, 79.97053139);
  var _ahmedabad1; // = LatLng(40.038304, 79.511856);
  var pickupLat;
  var pickupLongi;
  var dropLat;
  var dropLongi;
  var distance;
  var distanceKM;
  PolylinePoints polylinePoints = PolylinePoints();
  List polylinePointss;
  MapZoomPanBehavior zoomPanBehavior;
  List<dynamic>  markerData ;

  List<MapLatLng> polyline;
  List<PolylineModel> polylines;
  List<LatLng> polylineCoordinates = [];
  io.Socket socket;
  Set<Marker> markers = new Set();
  final Set<Polyline>_polyline={};
  List<LatLng> latlng = List();
  var tripAcceptDetails;
  bool tripCancelChecker = true;
  bool tripStarted = true;
  double tempMarkerSize = 5;
  //Map<PolylineId, Polyline> polylines = {};

 // PolylinePoints polylinePoints = PolylinePoints();

  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
  GoogleMapController mapController;
  String passengerCode;
  List<PointLatLng> result;
  bool cancelButton = true;
  final MapTileLayerController _layerController = MapTileLayerController();



  String googleAPiKey = "AIzaSyCtg102uMuplrssv_sk_FD-IcKI5hxnnSw";

  var overviewPolylines;

  static const LatLng _center = const LatLng(33.738045, 73.084488);


//add your lat and lng where you wants to draw polyline
@override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }


  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();


        getPassengerID().then((value) => passengerCode = value);

//    final Uint8List markerIcon = await getBytesFromAsset('assets/images/flutter.png', 100);
    // final Marker marker = Marker(icon: BitmapDescriptor.fromBytes(markerIcon));
    // TODO: implement initState
    //  super.initState();

    setState(() {
      _ahmedabad = LatLng(
          double.parse(widget.passengerPickupData['latitude'].toString()),
          double.parse(widget.passengerPickupData['longitude'].toString()));
      _ahmedabad1 = LatLng(
          double.parse(widget.driverDetailsData['latitude'].toString()),
          double.parse(widget.driverDetailsData['longitude'].toString()));
      dropLat = widget.driverDetailsData['latitude'].toString();
      dropLongi = widget.driverDetailsData['longitude'].toString();
    });
    super.initState();

    addMarker();
    _getUserLocation();
    setMapPins();



    //driverDetailsSocket();
    const oneSec = Duration(seconds: 2);//_getUserLocation(),
    Timer.periodic(oneSec, (Timer t) => { driverDetailsSocket(), addMarker()});
    latlng.add(_ahmedabad);
    latlng.add( _ahmedabad1);
    _onAddMarkerButtonPressed();
    _layerController.updateMarkers([1]);
    setState(() {

    });

  }



  Future<void> callDriver(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
  tripCanceledByDriver() async {
    await AwesomeNotifications().createNotification(content: NotificationContent(
      id: 1,
      channelKey: 'tripCancelled',
      title: "Trip has been cancelled by the driver",
      body:"Driver has cancelled the trip, Please Retry",

      //icon: 'images/ic_logo'
    ));
  }
  driverHasArrived() async {
    await AwesomeNotifications().createNotification(content: NotificationContent(
      id: 1,
      channelKey: 'tripCancelled',
      title: "The Trip has Been Started",
      body:"BE SAFE",

      //icon: 'images/ic_logo'
    ));
  }

  addMarker() {

    markers.add(createMarker("ahmedabad", _ahmedabad));
    markers.add(createMarker("ahmedabad1", _ahmedabad1));
  }


  Future<String> getPassengerID() async {

    SharedPreferences localStorage = await SharedPreferences.getInstance();

      passengerCode = localStorage.getString('passengerCode');
      return passengerCode;
  }

  void _getUserLocation() async {
    var position = await GeolocatorPlatform.instance
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark place1 = placemarks[0];
    Placemark place2 = placemarks[1];
    if(tripCancelChecker){
      setState(() {
        var pickupPlace = LatLng(position.latitude, position.longitude);
        // _pickupLocationCtrl.text =
        //"${place1.street}, ${place2.thoroughfare}, ${place1.locality}";
        // currentPostion = LatLng(position.latitude, position.longitude);
        //print(placemarks.toString());
        // print("Pickup Place: ${_pickupLocationCtrl.text}");
        //  print("Pickup Place Latitude: ${pickupPlace.latitude}");
        // print("Pickup Place Longitude: ${pickupPlace.longitude}");
       // setState(() {
          _ahmedabad = LatLng(pickupPlace.latitude, pickupPlace.longitude);
          pickupLat = pickupPlace.latitude;
          pickupLongi = pickupPlace.longitude;
      //  });
      });
    }
  }




  Future<void> _onAddMarkerButtonPressed() async {

   // setState(() {

      _polyline.add(Polyline(
        polylineId: PolylineId(_center.toString()),
        visible: true,

        //latlng is List<LatLng>
        points: latlng,
        color: Colors.blue,
      ));
   // });


  }







  createMarker(String id, LatLng latLng) {
    return Marker(
      markerId: MarkerId(id),
      position: latLng,
      //icon: bitmapDescriptor,
    );
  }

  void _onMapCreated(GoogleMapController mapController) {
    this.mapController = mapController;
  }


  void driverDetailsSocket( ) {
  //    print("---------------------------------------------------------------------------------Driver Detail Socket--------------------------------");
      String tripID = widget.driverDetailsData['tripId'];
      String driverID = widget.driverDetailsData['driverId'];
      String url = "http://173.82.95.250:8101";
      socket = io.io('$url', <String, dynamic>{
        'transports': ["websocket"],
        'autoConnect': true,
      });
      String socketID = socket.id;
      if(socket.connected){
       // print("Socket Connected===="+socket.id.toString());
        ////eol50FwPh18kq1sOAABu
      }
      tripAcceptDetails = {
        'driverId':driverID ,
        'tripId': tripID,
        'socketId': socket.id.toString()
      };
      socket.connect();
     // print(socketID);
      socket.emit('getDriverLocationById', tripAcceptDetails);
      // socket.on('driverDetails', (data) {
      //   print(data);
      //  // print(data['latitude']);
      // });

      socket.on('getDriverLocationByIdResult', (data) {
        if (this.mounted){
          if(tripCancelChecker){
            //setState(() {
            if(tripStarted){
              dropLat = data['currentLocation']['latitude'].toString();
              dropLongi = data['currentLocation']['longitude'].toString();

              _ahmedabad1 = LatLng(data['currentLocation']['latitude'], data['currentLocation']['longitude']);

            }else{

            }


            //   print(data);
            //  });
            setMapPins();
            if(tripStarted){

              if(data['currentStatus'] == "onTrip"){
                /// print(data['currentStatus']);
                driverHasArrived();
           //     print(data);

                tripStarted = false;

                setState(() {
                  dropLongi = widget.passengerDropData[0]['longitude'].toString();
                  dropLat = widget.passengerDropData[0]['latitude'].toString();
                //  print(widget.passengerDropData);
                //  print(widget.passengerDropData[0]['longitude'].toString()+"+++++++++++++++++"+widget.passengerDropData[0]['latitude'].toString());
                  setMapPins();
                  _layerController.updateMarkers([1]);
                  _layerController.insertMarker(1);
                  tempMarkerSize = 15;
                  //_layerController.removeMarkerAt(4);
                  //_layerController.updateMarkers([3]);
                  cancelButton = false;
                });
                setState(() {

                });
              }

            }

          }
        }
       // driverHasArrived();
      //  print(data['currentLocation']['longitude']);





        //Navigator.pop(context);
        ////print(data['latitude']);
      });
      socket.on('tripEndByDriver', (data) {
       // print(data);
       // print(widget.driverDetailsData.toString());
        if(this.mounted){
          Navigator.of(context)
              .push(new MaterialPageRoute(builder: (context) => TripEnd(tripEndDetails: data,driverDetails: widget.driverDetailsData,currentLoaction: _ahmedabad1,destionationLocation: _ahmedabad,passengerPickupData:widget.passengerPickupData,passengerDropData: widget.passengerDropData ,)));

        }

      });
      socket.on('tripCancelByDriver', (data) {
        if(tripCancelChecker){

          setState(() {
            tripCancelChecker = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Trip Cancelled By Driver"),
            duration: Duration(milliseconds: 5000),
            onVisible: (){
              tripCanceledByDriver();

            },
          ));
          Navigator.pop(context);
          Navigator.pop(context);

            //Navigator.of(context)
             //   .push(new MaterialPageRoute(builder: (context) => BookWithoutDestination(passengerCode,false,widget.passengerPickupData['address'],_ahmedabad,widget.passengerDropData[0]['address'],_ahmedabad1)));
        }

        //socket.clearListeners();


      });

  }
  Future<dynamic> setMapPins() {
    var steps;
    final JsonDecoder _decoder = JsonDecoder();
    List<MapLatLng> polyLineFrom= List<MapLatLng>();
    final BASE_URL = "http://139.59.239.142:5000/route/v1/driving/" +

        pickupLongi.toString() +
        "," +
        pickupLat.toString() +
        ";" +
        dropLongi.toString()+
        "," +
        dropLat.toString() +

        "?steps=true";

   // print(BASE_URL);
    return http.get(BASE_URL).then((http.Response response) {

      String res = response.body;
      // int statusCode = response.statusCode;
      // if (statusCode < 200 || statusCode > 400 || json == null) {
      //   res = "{\"status\":" +
      //       statusCode.toString() +
      //       ",\"message\":\"error\",\"response\":" +
      //       res +
      //       "}";
      //   throw new Exception(res);
      // }

      try {
        steps = _decoder
            .convert(res)["routes"][0]["legs"][0]["steps"] ;
        //  print(steps.length);
        if(steps!=null){
          for (var i = 0; i < steps.length; i++) {
            var insertion=steps[i]['intersections'];
            // print(insertion.length);
            for (var j = 0; j < insertion.length; j++) {
              polyLineFrom.add(MapLatLng(insertion[j]['location'][1], insertion[j]['location'][0]));
            }
          }

          setState(() {
            var distanceInMeter= _decoder
                .convert(res)["routes"][0]["distance"];
            var distanceInKM = distanceInMeter / 1000;
            double num2 = double.parse((distanceInKM).toStringAsFixed(2));
            distanceKM = num2;
           // print(distanceKM);
            polylines = <PolylineModel>[
              PolylineModel(polyLineFrom,5, Colors.blue),
            ];
            //print(polylines);
            zoomPanBehavior = MapZoomPanBehavior(
              zoomLevel: 15,
              focalLatLng: MapLatLng(pickupLat,pickupLongi),
            );
          });

        }
        // print(polyLineFrom);
      } catch (e) {
        throw new Exception(e);
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(child: Scaffold(
      key: _scaffoldKey,
      body: Container(
        width: double.infinity,
        child: Stack(
          children: <Widget>[
            polylines != null? SfMaps(

              layers: [
                //  MapShapeLayer(source: data),

                MapTileLayer(
                  controller:_layerController ,
                  //initialFocalLatLng: MapLatLng(20.3173, 78.7139),
                  initialZoomLevel: 1,
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  zoomPanBehavior: zoomPanBehavior,
                  sublayers: [
                    MapPolylineLayer(
                      polylines: List<MapPolyline>.generate(
                        polylines.length,
                            (int index) {
                         // print(polylines.length);
                          return MapPolyline(
                            points: polylines[index].points,
                            color: polylines[index].color,
                            width: polylines[index].width,
                          );
                        },
                      ).toSet(),
                    ),
                  ],
                  initialMarkersCount: 5,
                  markerBuilder: (context, index) {


                    if (index == 0) {
                      return MapMarker(
                          child: Image.asset( "images/pickup_location_marker.png",scale: 5,),
                          iconColor: Colors.white,
                          iconStrokeColor: Colors.blue,
                          iconStrokeWidth: 2,
                          latitude: pickupLat,
                          longitude: pickupLongi);
                    } else if (index == 1) {
                      return MapMarker(
                          child: Image.asset( "images/pickup_location_marker.png",scale: 5,),
                          iconColor: Colors.white,
                          iconStrokeColor: Colors.blue,
                          iconStrokeWidth: 2,
                          latitude: double.parse(dropLat),
                          longitude: double.parse(dropLongi));
                    }


                    return MapMarker(
                        child: Image.asset( "images/pickup_location_marker.png",scale:300,),
                        iconColor: Colors.white,
                        iconStrokeColor: Colors.blue,
                        iconStrokeWidth: 2,
                        latitude: double.parse(dropLat),
                        longitude: double.parse(dropLongi));

                    ////

                  },
                ),
              ],
            ):Container(),
            // GoogleMap(
            //   key: Key("AIzaSyCtg102uMuplrssv_sk_FD-IcKI5hxnnSw"),
            //   onMapCreated: _onMapCreated,
            //   markers: markers,
            //   polylines: _polyline,
            //   mapType: MapType.normal,
            //   initialCameraPosition:
            //   CameraPosition(target: _ahmedabad, zoom: 14),
            // ),
            Align(
              key: Key("address"),
              alignment: Alignment.topCenter,
              child: Container(
                margin: EdgeInsets.only(top: 24),
                child: Column(
                  children: <Widget>[
                    Card(
                      margin: EdgeInsets.symmetric(horizontal: 30, vertical: 8),
                      child: Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Container(
                              width: 10,
                              margin: EdgeInsets.only(left: 16),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.green,
                              ),
                              height: 10,
                            ),
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.only(left: 16),
                                child: Text(
                                  widget.passengerPickupData['address'],
                                  style: CustomTextStyle.regularTextStyle
                                      .copyWith(color: Colors.grey.shade800),
                                ),
                              ),
                              flex: 100,
                            ),
                            IconButton(
                                icon: Icon(
                                  Icons.favorite_border,
                                  color: Colors.grey,
                                  size: 18,
                                ),
                                onPressed: () {})
                          ],
                        ),
                      ),
                    ),
                    Card(
                      margin: EdgeInsets.symmetric(horizontal: 30, vertical: 0),
                      child: Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Container(
                              width: 10,
                              margin: EdgeInsets.only(left: 16),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.red,
                              ),
                              height: 10,
                            ),
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.only(top: 16, bottom: 16),
                                margin: EdgeInsets.only(left: 16),
                                child: Text(
                                  widget.passengerDropData[0]['address'],
                                  style: CustomTextStyle.regularTextStyle
                                      .copyWith(color: Colors.grey.shade800),
                                ),
                              ),
                              flex: 100,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    // RaisedButton(
                    //   onPressed: () {
                    //     if(cancelButton){
                    //       Navigator.of(context).push(new MaterialPageRoute(
                    //           builder: (context) => CancelTripFeedback()));
                    //     }else{
                    //       return null;
                    //     }
                    //
                    //   },
                    //   padding:
                    //   EdgeInsets.symmetric(horizontal: 48, vertical: 10),
                    //   shape: RoundedRectangleBorder(
                    //       borderRadius: BorderRadius.circular(100)),
                    //   color: Colors.black.withOpacity(0.5),
                    //   textColor: Colors.white,
                    //   child: Text(
                    //     "Cancel Trip",
                    //     style: CustomTextStyle.mediumTextStyle
                    //         .copyWith(color: Colors.white),
                    //   ),
                    // )
                  ],
                ),
              ),
            ),
            Align(
              key: Key("drive_details"),
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 300,
                width: double.infinity,
                child: Stack(
                  children: <Widget>[
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(top: 24),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16))),
                      child: Column(
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Stack(
                                children: <Widget>[
                                  Container(
                                    width: 100,
                                    height: 100,
                                    margin: EdgeInsets.only(left: 16, top: 16),
                                    decoration: BoxDecoration(
                                        image: DecorationImage(
                                            image: NetworkImage(
                                                widget.driverDetailsData[
                                                'driverPic'])),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10))),
                                  ),
                                  Container(
                                    alignment: Alignment.bottomCenter,
                                    margin: EdgeInsets.only(left: 16, top: 86),
                                    width: 100,
                                    height: 30,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(10),
                                            bottomRight: Radius.circular(10)),
                                        color: Colors.black.withOpacity(0.5)),
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: <Widget>[
                                        Text(
                                          "4.5",
                                          style: CustomTextStyle.boldTextStyle
                                              .copyWith(
                                              color: Colors.white,
                                              fontSize: 16),
                                        ),
                                        SizedBox(
                                          width: 4,
                                        ),
                                        Icon(
                                          Icons.star,
                                          color: Colors.yellowAccent.shade700,
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(
                                width: 16,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 20),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      widget.driverDetailsData['driverName'],
                                      style: CustomTextStyle.mediumTextStyle
                                          .copyWith(fontSize: 16),
                                    ),
                                    SizedBox(
                                      height: 8,
                                    ),
                                    Text(
                                      "On the way",
                                      style: CustomTextStyle.mediumTextStyle
                                          .copyWith(
                                          fontSize: 16,
                                          color:
                                          Colors.tealAccent.shade700),
                                    ),
                                    SizedBox(
                                      height: 8,
                                    ),
                                    Container(
                                      padding: EdgeInsets.all(6),
                                      child: RichText(
                                        text: TextSpan(children: [
                                          TextSpan(
                                              text: widget.driverDetailsData[
                                              'vehicleRegistrationNo'],
                                              style: CustomTextStyle
                                                  .boldTextStyle
                                                  .copyWith(
                                                  color: Colors.black)),
                                          TextSpan(
                                              text: "-",
                                              style: CustomTextStyle
                                                  .mediumTextStyle
                                                  .copyWith(
                                                  color: Colors.grey,
                                                  fontSize: 16)),
                                          TextSpan(
                                              text: widget.driverDetailsData[
                                              'vehicleBrand'] +
                                                  "(" +
                                                  widget.driverDetailsData[
                                                  'vehicleColor'] +
                                                  ")",
                                              style: CustomTextStyle
                                                  .regularTextStyle
                                                  .copyWith(color: Colors.grey))
                                        ]),
                                      ),
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(
                                              color: Colors.grey, width: 1),
                                          borderRadius:
                                          BorderRadius.circular(4)),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                          Container(
                            width: double.infinity,
                            margin: EdgeInsets.only(top: 16),
                            color: Colors.grey.shade300,
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: GestureDetector(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: Text(
                                        "Payment",
                                        style: CustomTextStyle.regularTextStyle,
                                      ),
                                      padding:
                                      EdgeInsets.only(top: 14, bottom: 14),
                                    ),
                                    onTap: () {
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return PaymentDialog();
                                          });
                                    },
                                  ),
                                  flex: 50,
                                ),
                                Container(
                                  width: 1,
                                  height: 40,
                                  color: Colors.grey,
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return PromoCodeDialog();
                                          });
                                    },
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: Text(
                                        "Promo Code",
                                        style: CustomTextStyle.regularTextStyle
                                            .copyWith(color: Colors.grey),
                                      ),
                                      padding:
                                      EdgeInsets.only(top: 14, bottom: 14),
                                    ),
                                  ),
                                  flex: 50,
                                )
                              ],
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            child: RaisedButton(
                              onPressed: () {
                                callDriver("tel:"+widget.driverDetailsData['driverContactNo']);
                              },
                              materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                              child: Text(
                                "Call Driver",
                                style: CustomTextStyle.mediumTextStyle
                                    .copyWith(color: Colors.white),
                              ),
                              color: Colors.tealAccent.shade400,
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(0))),
                              padding: EdgeInsets.all(16),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(2),
                            width: double.infinity,
                            child: RaisedButton(
                              onPressed: () {
                                if(cancelButton){
                                  Navigator.of(context).push(new MaterialPageRoute(
                                      builder: (context) => CancelTripFeedback()));
                                }else{
                                  return null;
                                }
                               //callDriver("tel:"+widget.driverDetailsData['driverContactNo']);
                              },
                              materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                              child: Text(
                                "Cancel Trip",
                                style: CustomTextStyle.mediumTextStyle
                                    .copyWith(color: Colors.white),
                              ),
                              color: Colors.red.shade300,
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(0))),
                              padding: EdgeInsets.all(16),
                            ),
                          )

                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Container(
                          child: Icon(
                            Icons.my_location,
                            color: Colors.black,
                          ),
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.grey.shade200,
                                    offset: Offset(1, 1),
                                    spreadRadius: 2,
                                    blurRadius: 10)
                              ]),
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Container(
                          child: Icon(
                            Icons.info_outline,
                            color: Colors.black,
                          ),
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.grey.shade200,
                                    offset: Offset(1, 1),
                                    spreadRadius: 2,
                                    blurRadius: 10)
                              ]),
                        ),
                        SizedBox(
                          width: 16,
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ), onWillPop: (){

    });
  }
}
