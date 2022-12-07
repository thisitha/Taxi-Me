import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_cab/Widgets/SearchCity/place.dart';
import 'package:flutter_cab/home/DriverSearch.dart';
import 'package:flutter_cab/home/cancel_trip_feedback.dart';
import 'package:flutter_cab/home/trip_started.dart';
import 'package:flutter_cab/utils/CustomTextStyle.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'cancel_trip.dart';
import 'dialog/payment_dialog.dart';
import 'dialog/promo_code_dialog.dart';
import 'package:latlong/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_place_picker/google_maps_place_picker.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'dart:async';
import 'package:flutter_cab/utils/api.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:math';
import 'package:flutter/rendering.dart';
import 'package:syncfusion_flutter_maps/maps.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

const double CAMERA_ZOOM = 13;
const double CAMERA_TILT = 0;
const double CAMERA_BEARING = 30;
// LatLng SOURCE_LOCATION = LatLng(42.7477863, -71.1699932);
// LatLng DEST_LOCATION = LatLng(42.6871386, -71.2143403);

class BookWithoutDestination extends StatefulWidget {
  final String passengerCode;
  final bool isTextWritten;
  final String pickupPlaceAddress;
  final LatLng pickupPlace;
  final String dropOffPlaceAddress;
  final LatLng dropOffPlace;

  BookWithoutDestination(
      this.passengerCode,
      this.isTextWritten,
      this.pickupPlaceAddress,
      this.pickupPlace,
      this.dropOffPlaceAddress,
      this.dropOffPlace);

  @override
  _BookWithoutDestinationState createState() =>
      _BookWithoutDestinationState(isTextWritten);
}

class _BookWithoutDestinationState extends State<BookWithoutDestination> {

  var distance;
  var distanceKM;
  // Set<Marker> markers = new Set();
  // Completer<GoogleMapController> _controller = Completer();
  // this set will hold my markers
  // Set<Marker> _markers = {};
  // // this will hold the generated polylines
  // Set<Polyline> _polylines = {};
  // this will hold each polyline coordinate as Lat and Lng pairs
  // List<LatLng> polylineCoordinates = [];
  // this is the key object - the PolylinePoints
  // which generates every polyline between start and finish
  PolylinePoints polylinePoints = PolylinePoints();
  String googleAPIKey = "AIzaSyCtg102uMuplrssv_sk_FD-IcKI5hxnnSw";
  // for my custom icons
  // BitmapDescriptor sourceIcon;
  // BitmapDescriptor destinationIcon;
  // BitmapDescriptor bitmapDescriptor;
  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey();
  bool isTextWritten;
  //Tuk
  var tukList;
  //Nano
  var nanoList;
  //Smart
  var smartList;
  //prime
  var primeList;
  //van
  var miniVan;

  var selectedVehicleSubCategory;
  var lowerBidLimit = 0;
  var selectedCategoryDetail;
  var tripTotalCost='0';
  List polylinePointss;

  io.Socket socket;
   // List<MapLatLng> polyline;
   // List<List<MapLatLng>> polylines;

   List<MapLatLng> polyline;
   List<PolylineModel> polylines;
   MapZoomPanBehavior zoomPanBehavior;
  _BookWithoutDestinationState(this.isTextWritten);

  String passengerCode = 'passengerCode';
  FlutterToast flutterToast;

  // Budget - Nano, Tuk
  // Economy - Prime, Smart
  // Family - Mini Van
  var selectedVehicleCategory;

  List<dynamic> rideDetailsList = [];
  List<dynamic>  markerData ;
  bool imagesLoaded =false;
@override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void initState() {

   // WidgetsFlutterBinding.ensureInitialized();
    setMapPins();


    // polyline = <MapLatLng>[
    //   MapLatLng(13.0827, 80.2707),
    //   MapLatLng(13.1746, 79.6117),
    //   MapLatLng(13.6373, 79.5037),
    //   MapLatLng(14.4673, 78.8242),
    //   MapLatLng(14.9091, 78.0092),
    //   MapLatLng(16.2160, 77.3566),
    //   MapLatLng(17.1557, 76.8697),
    //   MapLatLng(18.0975, 75.4249),
    //   MapLatLng(18.5204, 73.8567),
    //   MapLatLng(19.0760, 72.8777),
    // ];

    //
    //   polylines = <List<MapLatLng>>[polyline];
    // print(polylines);

    // TODO: implement initState
    // SOURCE_LOCATION = LatLng(widget.pickupPlace.lat,
    //     widget.pickupPlace.long);
    // DEST_LOCATION = LatLng(widget.dropOffPlace.lat,
    //     widget.dropOffPlace.long);
    initSocket();
    getAllLocation();
    // Future.delayed(Duration.zero, () {
    //
    //   loadingDialog();
    //
    // });
    super.initState();

    // _getDistance();

    setSourceAndDestinationIcons();
    // BitmapDescriptor.fromAssetImage(
    //         ImageConfiguration(), "images/map-marker.png")
    //     .then((bitmap) {
    //   bitmapDescriptor = bitmap;
    // });
    // markers.add(Marker(
    //     markerId: MarkerId("ahmedabad"),
    //     position: _ahmedabad,
    //     infoWindow: InfoWindow(title: "Title", snippet: "Content"),
    //     icon: bitmapDescriptor));

    if (isTextWritten) {
      // markers.add(Marker(
      //     markerId: MarkerId("lal_darwaja"),
      //     position: _lal_darwaja,
      //     infoWindow: InfoWindow(title: "Title", snippet: "Content"),
      //     icon: bitmapDescriptor));
      // WidgetsBinding.instance
      //     .addPostFrameCallback((_) => showFareEstimationBottomSheet());
    }
    flutterToast = FlutterToast(context);
    const oneSec = Duration(seconds:1);
    Timer.periodic(oneSec, (Timer t) => getAllDriverLocation());
  }
  loadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        // return object of type Dialog
        return Dialog(
          elevation: 0.0,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          child: Container(
            height: 150.0,
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SpinKitRing(
                  color: Colors.yellow,
                  lineWidth: 1.5,
                  size: 35.0,
                ),

                Text(
                    "Loading..."),

            ],
            ),
          ),
        );
      },
    );

    // Timer(
    //     Duration(seconds: 3),
    //     (){
    //
    //     }
    //
    //
    // );
    return AlertDialog(
      title: Text("Favourite Address Has Been Added"),
    );
    print("Outside Timer");
  }
  void initSocket()  {


    // socket.on('onDeleted', (data) {
    //   // _listMessages.map((item) {
    //   //   if (item.id == data) {
    //   //     setState(() {
    //   //       item.isDeleted = 1;
    //   //     });
    //   //   }
    //   // }).toList();
    // });

    // socket.on('numberOfConenctedUsers', (data) {
    //
    // });
  }

  getAllDriverLocation() async {
    String url = "http://173.82.95.250:8101";
    socket = io.io('$url', <String, dynamic>{
      'transports': ["websocket"],
      'autoConnect': true,
    });
    socket.connect();
    String socketID = socket.id;
   // print(socketID);

   // print(socket.connected);
    socket.on('connect', (_) {
    //  print('Connect wunaddhdj');
    });

    if(socket.connected){
      // Map map = Map();
      // map['passengerId'] = await getPassengerDetails();
      // map['longitude'] = widget.pickupPlace.longitude;
      // map['latitude'] = widget.pickupPlace.latitude;
      // map['socketId'] = socket.id;
      // map['radius'] = 10;


      var data = {
        'passengerId':await getPassengerDetails(),
        'longitude':  widget.pickupPlace.longitude,
        'latitude':widget.pickupPlace.latitude,
        'socketId':socket.id,
        'radius':10
      };

   //   var myJson = jsonEncode(map);
      //print(myJson);
      socket.emit('getOnlineDriversBylocation',data);

    }
    //
    socket.on('allOnlineDriversResult', (data) {
      // for( var data2 in data['currentLocation'] ){
      //   //avilableDrivers: data2[];
     // print(data);
      if (this.mounted) {
        setState(() {
          markerData = data;
        });
      }

      // }
     // newMarkers.clear();


    //  print(data[0]['currentLocation']);

    });
   // socket.();
  }



  getAllLocation() async {
  //loadingDialog();
    // await Future.delayed(Duration(milliseconds: 2000));
    var data = {
      'latitude': widget.pickupPlace.latitude,
      'longitude': widget.pickupPlace.longitude
    };
    var res = await Network().postData(
        data, '/vehiclecategory/getCategoryAllDataTimeAndLocationBased');
    var result = json.decode(res.body);

    print(result);
    if (result['message'] == "success") {
      setState(() {
        tukList = result['content'][0];
        nanoList = result['content'][1];
        smartList = result['content'][2];
        primeList = result['content'][3];
        miniVan = result['content'][4];
        //Navigator.pop(context);
        imagesLoaded = true;
      });
    } else {
      return "No Data";
    }
  }

  void setSourceAndDestinationIcons() async {
    // sourceIcon = await BitmapDescriptor.fromAssetImage(
    //     ImageConfiguration(devicePixelRatio: 2.5),
    //     'images/pickup_location_marker.png');
    // destinationIcon = await BitmapDescriptor.fromAssetImage(
    //     ImageConfiguration(devicePixelRatio: 2.5),
    //     'images/pickup_location_marker.png');
  }

  // void onMapCreated(GoogleMapController controller) {
  //   _controller.complete(controller);
  //   setMapPins();
  //   setPolylines();
  // }

  Future<dynamic> setMapPins() {
    var steps;
    final JsonDecoder _decoder = JsonDecoder();
    List<MapLatLng> polyLineFrom= List<MapLatLng>();
    final BASE_URL = "http://139.59.239.142:5000/route/v1/driving/" +

        widget.pickupPlace.longitude.toString() +
        "," +
        widget.pickupPlace.latitude.toString() +
        ";" +
        widget.dropOffPlace.longitude.toString()+
        "," +
        widget.dropOffPlace.latitude.toString() +

    "?steps=true";

    print(BASE_URL);
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
           print(distanceKM);
           polylines = <PolylineModel>[
             PolylineModel(polyLineFrom,5, Colors.blue),
           ];
           print(polylines);
           zoomPanBehavior = MapZoomPanBehavior(
             zoomLevel: 15,
             focalLatLng: MapLatLng(widget.pickupPlace.latitude, widget.pickupPlace.longitude),
           );
         });

       }
       // print(polyLineFrom);
      } catch (e) {
        throw new Exception(e);
      }
    });
  }

  // Future<dynamic> _getDistance() {
  //   final JsonDecoder _decoder = JsonDecoder();
  //
  //   final BASE_URL = "https://maps.googleapis.com/maps/api/directions/json?" +
  //       "origin=" +
  //       widget.pickupPlace.latitude.toString() +
  //       "," +
  //       widget.pickupPlace.longitude.toString() +
  //       "&destination=" +
  //       widget.dropOffPlace.latitude.toString() +
  //       "," +
  //       widget.dropOffPlace.longitude.toString() +
  //       "&key=$googleAPIKey";
  //
  //   print(BASE_URL);
  //   return http.get(BASE_URL).then((http.Response response) {
  //     String res = response.body;
  //     int statusCode = response.statusCode;
  //     if (statusCode < 200 || statusCode > 400 || json == null) {
  //       res = "{\"status\":" +
  //           statusCode.toString() +
  //           ",\"message\":\"error\",\"response\":" +
  //           res +
  //           "}";
  //       throw new Exception(res);
  //     }
  //
  //     try {
  //       distance = _decoder
  //               .convert(res)["routes"][0]["legs"][0]["distance"]['text']
  //               .toString() ??
  //           'No Dispaly';
  //       var distanceinMeter =
  //           _decoder.convert(res)["routes"][0]["legs"][0]["distance"]['value'];
  //       var distanceInKM = distanceinMeter / 1000;
  //       double num2 = double.parse((distanceInKM).toStringAsFixed(2));
  //       distanceKM = num2;
  //     } catch (e) {
  //       throw new Exception(res);
  //     }
  //   });
  // }

  setPolylines() async {
    // List<PointLatLng> result = await polylinePoints?.getRouteBetweenCoordinates(
    //     googleAPIKey,
       // SOURCE_LOCATION.latitude,
    //     SOURCE_LOCATION.longitude,
    //     DEST_LOCATION.latitude,
    //     DEST_LOCATION.longitude);
    // if (result.isNotEmpty) {
    //   // loop through all PointLatLng points and convert them
    //   // to a list of LatLng, required by the Polyline
    //   result.forEach((PointLatLng point) {
    //     polylineCoordinates.add(LatLng(point.latitude, point.longitude));
    //   });
    // }

    setState(() {
      // create a Polyline instance
      // with an id, an RGB color and the list of LatLng pairs

      // Polyline polyline = Polyline(
      //     polylineId: PolylineId("poly"),
      //     color: Colors.black,
      //     points: polylineCoordinates);
      // add the constructed polyline as a set of points
      // to the polyline set, which will eventually
      // end up showing up on the map
      // _polylines.add(polyline);
    });
  }
  String contactNum;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    // CameraPosition initialLocation = CameraPosition(
    //     zoom: CAMERA_ZOOM,
    //     bearing: CAMERA_BEARING,
    //     tilt: CAMERA_TILT,
    //     target: SOURCE_LOCATION);
    return MaterialApp(
      theme: ThemeData(
          primarySwatch: Colors.green,
          dialogTheme: DialogTheme(backgroundColor: Colors.white),
          canvasColor: Colors.transparent,
          accentColor: Colors.amber),
      home: Scaffold(
        key: scaffoldKey,
        //resizeToAvoidBottomPadding: false,
        resizeToAvoidBottomInset: true,
        body: imagesLoaded!=false? Builder(
          builder: (context) {
            return   Container(
              child: Stack(
                children: <Widget>[
                  polylines!=null?SfMaps(

                    layers: [
                    //  MapShapeLayer(source: data),

                      MapTileLayer(

                        //initialFocalLatLng: MapLatLng(20.3173, 78.7139),
                        initialZoomLevel: 15,
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        zoomPanBehavior: zoomPanBehavior,
                        sublayers: [
                          MapPolylineLayer(
                            polylines: List<MapPolyline>.generate(
                              polylines.length,
                                  (int index) {
                                print(polylines.length);
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
                                latitude: widget.pickupPlace.latitude,
                                longitude: widget.pickupPlace.longitude);
                          }
                         try{
                           if (index == 1) {
                             return MapMarker(
                                 child: Image.asset( "images/car_marker.png",scale: 1,),
                                 iconColor: Colors.white,
                                 iconStrokeColor: Colors.blue,
                                 iconStrokeWidth: 2,
                                 latitude: markerData[0]['currentLocation']['latitude'],
                                 longitude: markerData[0]['currentLocation']['longitude']);
                           }else if (index == 2) {
                             return MapMarker(
                                 child: Image.asset( "images/car_marker.png",scale: 1,),
                                 iconColor: Colors.white,
                                 iconStrokeColor: Colors.blue,
                                 iconStrokeWidth: 2,
                                 latitude: markerData[1]['currentLocation']['latitude'],
                                 longitude: markerData[1]['currentLocation']['longitude']);
                           }else if (index == 3) {
                             return MapMarker(
                                 child: Image.asset( "images/car_marker.png",scale: 1,),
                                 iconColor: Colors.white,
                                 iconStrokeColor: Colors.blue,
                                 iconStrokeWidth: 2,
                                 latitude: markerData[2]['currentLocation']['latitude'],
                                 longitude: markerData[2]['currentLocation']['longitude']);
                           }

                         }catch(e){

                         }

                          return MapMarker(
                              child: Image.asset( "images/pickup_location_marker.png",scale: 5,),
                              iconColor: Colors.white,
                              iconStrokeColor: Colors.blue,
                              iconStrokeWidth: 2,
                              latitude: widget.dropOffPlace.latitude,
                              longitude: widget.dropOffPlace.longitude);

                          ////

                        },
                      ),
                    ],
                  ):
                      Container(),
                  // FlutterMap(
                  //       // mapController: mapController,
                  //       options: MapOptions(
                  //         center: LatLng(widget.pickupPlace.latitude, widget.pickupPlace.longitude),
                  //         zoom: 10,
                  //       ),
                  //
                  //       layers: [
                  //         TileLayerOptions(
                  //             urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  //             subdomains: ['a', 'b', 'c']),
                  //          MarkerLayerOptions(
                  //           markers: [
                  //             Marker(
                  //               width: 120.0,
                  //               height: 120.0,
                  //               point: LatLng(widget.pickupPlace.latitude, widget.pickupPlace.longitude),
                  //               builder: (ctx) => Container(
                  //                 child: Icon(
                  //                   Icons.location_on,
                  //                   color: Colors.red,
                  //                   size: 40.0,
                  //                 ),
                  //               ),
                  //             ),
                  //             Marker(
                  //               width: 120.0,
                  //               height: 120.0,
                  //               point: LatLng(widget.dropOffPlace.latitude, widget.dropOffPlace.longitude),
                  //               builder: (ctx) => Container(
                  //                 child: Icon(
                  //                   Icons.location_on,
                  //                   color: Colors.red,
                  //                   size: 40.0,
                  //                 ),
                  //               ),
                  //             ),
                  //           ],
                  //         ),
                  //
                  //
                  //       ],
                  //     ),
                  Column(
                    key: Key("Cars"),
                    children: <Widget>[
                      SizedBox(
                        height: 20,
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          margin: EdgeInsets.only(right: 12, top: 24),
                          child: Image(
                            image: AssetImage("images/ic_close.png"),
                          ),
                        ),
                      ),
                      Card(
                        margin:
                            EdgeInsets.symmetric(horizontal: 30, vertical: 12),
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
                                    widget.pickupPlaceAddress
                                        .toString(),
                                    style: CustomTextStyle.regularTextStyle
                                        .copyWith(color: Colors.grey.shade800),
                                  ),
                                ),
                                flex: 100,
                              ),
                              IconButton(
                                  icon: Icon(
                                    Icons.my_location,
                                    color: Colors.greenAccent,
                                    size: 18,
                                  ),
                                  onPressed: () {})
                            ],
                          ),
                        ),
                      ),
                      Card(
                        margin: EdgeInsets.symmetric(
                          horizontal: 30,
                        ),
                        child: Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                width: 10,
                                margin: EdgeInsets.only(left: 16),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.pink,
                                ),
                                height: 10,
                              ),
                              Expanded(
                                child: Container(
                                  margin: EdgeInsets.only(left: 16),
                                  child: Text(
                                    widget.dropOffPlaceAddress
                                        .toString(),
                                    style: CustomTextStyle.regularTextStyle
                                        .copyWith(color: Colors.grey.shade800),
                                  ),
                                ),
                                flex: 100,
                              ),
                              IconButton(
                                  icon: Icon(
                                    Icons.local_taxi_sharp,
                                    color: Colors.pink,
                                    size: 18,
                                  ),
                                  onPressed: () {})
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          alignment: Alignment.bottomCenter,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              // Stack(
                              //   key: Key("timer"),
                              //   children: <Widget>[
                              //     // Align(
                              //     //   child: Container(
                              //     //     key: Key("navigationKey"),
                              //     //     width: 36,
                              //     //     height: 36,
                              //     //     margin: EdgeInsets.only(top: 8),
                              //     //     decoration: BoxDecoration(
                              //     //         color: Colors.black.withOpacity(0.4),
                              //     //         shape: BoxShape.circle,
                              //     //         image: DecorationImage(
                              //     //           image: AssetImage(
                              //     //               "images/navigation.png"),
                              //     //         )),
                              //     //   ),
                              //     //   alignment: Alignment.bottomCenter,
                              //     // ),
                              //     Align(
                              //       alignment: Alignment.topRight,
                              //       child: Container(
                              //         key: Key("timer"),
                              //         decoration: BoxDecoration(
                              //             boxShadow: [
                              //               BoxShadow(
                              //                   color: Colors.grey.shade400,
                              //                   blurRadius: 60,
                              //                   offset: Offset(-6, -10)),
                              //               BoxShadow(
                              //                   color: Colors.grey.shade400,
                              //                   blurRadius: 60,
                              //                   offset: Offset(-6, 10))
                              //             ],
                              //             borderRadius: BorderRadius.all(
                              //                 Radius.circular(12))),
                              //         child: Card(
                              //           elevation: 0,
                              //           color: Colors.white,
                              //           margin: EdgeInsets.only(
                              //               bottom: 8, right: 16),
                              //           child: Container(
                              //             child: Image(
                              //               image: AssetImage(
                              //                   "images/stopwatch.png"),
                              //             ),
                              //             margin: EdgeInsets.all(8),
                              //           ),
                              //           shape: RoundedRectangleBorder(
                              //               borderRadius: BorderRadius.all(
                              //                   Radius.circular(12))),
                              //         ),
                              //       ),
                              //     )
                              //   ],
                              // )
                            ],
                          ),
                        ),
                        flex: 80,
                      ),
                      SizedBox(
                        height: 2,
                      ),
                      Container(
                        height: 180,
                        child: Card(
                            elevation: 1,
                            color: Color(0xFFFF922C),
                            margin: EdgeInsets.all(0),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(25),
                                    topRight: Radius.circular(25))),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Expanded(
                                        flex: 2,
                                        child: Text(
                                          "Pick your \nCategory",
                                          style: CustomTextStyle.mediumTextStyle
                                              .copyWith(
                                                  color: Colors.white,
                                                  fontSize: 20),
                                        )),
                                    Flexible(
                                        flex: 6,
                                        child: Container(
                                          height: 120,
                                          child: ListView(
                                            // This next line does the trick.
                                            scrollDirection: Axis.horizontal,
                                            children: [
                                              Container(
                                                child: Row(
                                                  children: <Widget>[
                                                    Container(
                                                      width: 80,
                                                      height: 107,
                                                      child: GestureDetector(
                                                        onTap: () async {
                                                          //getAllDriverLocation();
                                                          setState(() {
                                                            selectedVehicleCategory = "Budget";
                                                            selectedVehicleSubCategory =
                                                                "Tuk";
                                                            lowerBidLimit = tukList[
                                                                'lowerBidLimit'];
                                                            selectedCategoryDetail =
                                                                tukList;
                                                          });
                                                          await priceCalculation();
                                                        },
                                                        child: Card(
                                                          color:
                                                          selectedVehicleSubCategory ==
                                                                      'Tuk'
                                                                  ? Colors.green
                                                                  : Colors
                                                                      .white,
                                                          elevation: 15,
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        15),
                                                          ),
                                                          child: Center(
                                                            child: Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: <
                                                                  Widget>[
                                                                Image(
                                                                  image: NetworkImage(selectedVehicleSubCategory ==
                                                                          'Tuk'
                                                                      ? tukList[
                                                                          'subCategoryIcon']
                                                                      : tukList[
                                                                          'subCategoryIconSelected']),
                                                                ),
                                                                Text(
                                                                  'Tuk',
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontSize:
                                                                          15),
                                                                ),
                                                                SizedBox(
                                                                    height: size
                                                                            .height *
                                                                        0.01)
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      width: 80,
                                                      height: 107,
                                                      child: GestureDetector(
                                                        onTap: () async {
                                                          setState(() {
                                                            selectedVehicleCategory = "Budget";
                                                            selectedVehicleSubCategory =
                                                                "Nano";
                                                            lowerBidLimit =
                                                                nanoList[
                                                                    'lowerBidLimit'];
                                                            selectedCategoryDetail =
                                                                nanoList;
                                                          });
                                                          await priceCalculation();
                                                        },
                                                        child: Card(
                                                          color:
                                                          selectedVehicleSubCategory ==
                                                                      'Nano'
                                                                  ? Colors.green
                                                                  : Colors
                                                                      .white,
                                                          elevation: 30,
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        15.0),
                                                          ),
                                                          child: Center(
                                                            child: Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: <
                                                                  Widget>[
                                                                Image(
                                                                  image: NetworkImage(selectedVehicleSubCategory ==
                                                                          'Nano'
                                                                      ? nanoList[
                                                                          'subCategoryIcon']
                                                                      : nanoList[
                                                                          'subCategoryIconSelected']),
                                                                ),
                                                                Text(
                                                                  'Nano',
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontSize:
                                                                          15),
                                                                ),
                                                                SizedBox(
                                                                    height: size
                                                                            .height *
                                                                        0.01),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      width: 80,
                                                      height: 107,
                                                      child: GestureDetector(
                                                        onTap: () async {
                                                          setState(() {
                                                            selectedVehicleCategory = "Economy";
                                                            selectedVehicleSubCategory =
                                                                "Smart";
                                                            lowerBidLimit =
                                                                smartList[
                                                                    'lowerBidLimit'];
                                                            selectedCategoryDetail =
                                                                smartList;
                                                          });
                                                          await priceCalculation();
                                                        },
                                                        child: Card(
                                                          color:
                                                          selectedVehicleSubCategory ==
                                                                      'Smart'
                                                                  ? Colors.green
                                                                  : Colors
                                                                      .white,
                                                          elevation: 30,
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        15.0),
                                                          ),
                                                          child: Center(
                                                            child: Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: <
                                                                  Widget>[
                                                                Image(
                                                                  image: NetworkImage(selectedVehicleSubCategory ==
                                                                          'Smart'
                                                                      ? smartList[
                                                                          'subCategoryIcon']
                                                                      : smartList[
                                                                          'subCategoryIconSelected']),
                                                                ),
                                                                Text(
                                                                  'Smart',
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontSize:
                                                                          15),
                                                                ),
                                                                SizedBox(
                                                                    height: size
                                                                            .height *
                                                                        0.01),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      width: 80,
                                                      height: 107,
                                                      child: GestureDetector(
                                                        onTap: () async {
                                                          setState(() {
                                                            selectedVehicleCategory = "Economy";
                                                            selectedVehicleSubCategory =
                                                                "Prime";
                                                            lowerBidLimit =
                                                                primeList[
                                                                    'lowerBidLimit'];
                                                            selectedCategoryDetail =
                                                                primeList;
                                                          });
                                                          await priceCalculation();
                                                        },
                                                        child: Card(
                                                          color:
                                                          selectedVehicleSubCategory ==
                                                                      'Prime'
                                                                  ? Colors.green
                                                                  : Colors
                                                                      .white,
                                                          elevation: 30,
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        15.0),
                                                          ),
                                                          child: Center(
                                                            child: Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: <
                                                                  Widget>[
                                                                Image(
                                                                  image: NetworkImage(selectedVehicleSubCategory ==
                                                                          'Prime'
                                                                      ? primeList[
                                                                          'subCategoryIcon']
                                                                      : primeList[
                                                                          'subCategoryIconSelected']),
                                                                ),
                                                                Text(
                                                                  'Prime',
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontSize:
                                                                          15),
                                                                ),
                                                                SizedBox(
                                                                    height: size
                                                                            .height *
                                                                        0.01),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      width: 80,
                                                      height: 107,
                                                      child: GestureDetector(
                                                        onTap: () async {
                                                          setState(() {
                                                            selectedVehicleCategory = "Family";
                                                            selectedVehicleSubCategory =
                                                                "Mini Van";
                                                            lowerBidLimit = miniVan[
                                                                'lowerBidLimit'];
                                                            selectedCategoryDetail =
                                                                miniVan;
                                                          });
                                                          await priceCalculation();
                                                        },
                                                        child: Card(
                                                          color:
                                                          selectedVehicleSubCategory ==
                                                                      'Mini Van'
                                                                  ? Colors.green
                                                                  : Colors
                                                                      .white,
                                                          elevation: 30,
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        15.0),
                                                          ),
                                                          child: Center(
                                                            child: Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: <
                                                                  Widget>[
                                                                Image(
                                                                  image: NetworkImage(selectedVehicleSubCategory ==
                                                                          'Mini Van'
                                                                      ? miniVan[
                                                                          'subCategoryIcon']
                                                                      : miniVan[
                                                                          'subCategoryIconSelected']),
                                                                ),
                                                                Text(
                                                                  'Mini Van',
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontSize:
                                                                          15),
                                                                ),
                                                                SizedBox(
                                                                    height: size
                                                                            .height *
                                                                        0.01),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ))
                                  ],
                                ),
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      flex: 15,
                                      child: GestureDetector(
                                        child: Container(
                                          alignment: Alignment.center,
                                          child: Text(
                                            "Distance",
                                            style: CustomTextStyle
                                                .regularTextStyle
                                                .copyWith(
                                                    color: Colors.white,
                                                    fontSize: 15),
                                          ),
                                          padding: EdgeInsets.only(
                                              top: 14, bottom: 14),
                                        ),
                                        onTap: () {
                                          // showDialog(
                                          //     context: context,
                                          //     builder: (context) {
                                          //       return PaymentDialog();
                                          //     });
                                        },
                                      ),
                                    ),
                                    SizedBox(width: size.width * 0.03),
                                    Container(
                                      child: Text(
                                        distanceKM.toString()+'Km',
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w900),
                                      ),
                                    ),
                                    SizedBox(width: size.width * 0.07),
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
                                          alignment: Alignment.topLeft,
                                          child: RichText(
                                            text: TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: "Estimate Cost: ",
                                                  style: CustomTextStyle
                                                      .mediumTextStyle
                                                      .copyWith(
                                                          color: Colors.black,
                                                          fontSize: 13),
                                                ),
                                                TextSpan(
                                                  text: "  Rs.$tripTotalCost",
                                                  style: CustomTextStyle
                                                      .regularTextStyle
                                                      .copyWith(
                                                          color: Colors.black,
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.w900),
                                                )
                                              ],
                                            ),
                                          ),
                                          padding: EdgeInsets.only(
                                              top: 14, bottom: 14),
                                        ),
                                      ),
                                      flex: 50,
                                    ),
                                    // SizedBox(width: size.width * 0.07),
                                  ],
                                ),
                              ],
                            )),
                      ),
                      // getDestinationView(),

                      Container(
                        width: double.infinity,
                        color: Color(0xFFFF922C),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: GestureDetector(
                                child: Container(
                                  alignment: Alignment.center,
                                  child: Text(
                                    "Pay By",
                                    style: CustomTextStyle.regularTextStyle
                                        .copyWith(
                                            color: Colors.white, fontSize: 16),
                                  ),
                                  padding: EdgeInsets.only(top: 14, bottom: 14),
                                ),
                                onTap: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return PaymentDialog();
                                      });
                                },
                              ),
                              flex: 5,
                            ),
                            Expanded(
                              child: GestureDetector(
                                child: Container(
                                  alignment: Alignment.center,
                                  child: Text(
                                    "Cash",
                                    style: CustomTextStyle.regularTextStyle
                                        .copyWith(
                                            color: Colors.white, fontSize: 16),
                                  ),
                                  padding: EdgeInsets.only(top: 14, bottom: 14),
                                ),
                                onTap: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return PaymentDialog();
                                      });
                                },
                              ),
                              flex: 6,
                            ),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(right: 30.0, left: 30),
                                child: Container(
                                  height: 90,
                                  width: 40,
                                  child: Card(
                                    elevation: 1,
                                    color: Colors.green,
                                    margin: EdgeInsets.all(0),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(25),
                                      topRight: Radius.circular(25),
                                      bottomLeft: Radius.circular(25),
                                      bottomRight: Radius.circular(25),
                                    )),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              alignment: Alignment.topCenter,
                                              child: GestureDetector(
                                                child: Container(
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    "-   ",
                                                    style: CustomTextStyle
                                                        .regularTextStyle
                                                        .copyWith(
                                                            color: Colors.white,
                                                            fontSize: 30,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w900),
                                                  ),
                                                ),
                                                onTap: () {
                                                  setState(() {
                                                    if (selectedVehicleSubCategory ==
                                                            'Tuk' &&
                                                        lowerBidLimit !=
                                                            tukList[
                                                                'lowerBidLimit']) {
                                                      lowerBidLimit =
                                                          lowerBidLimit - 1;
                                                    } else if (selectedVehicleSubCategory ==
                                                            'Nano' &&
                                                        lowerBidLimit !=
                                                            nanoList[
                                                                'lowerBidLimit']) {
                                                      lowerBidLimit =
                                                          lowerBidLimit - 1;
                                                    } else if (selectedVehicleSubCategory ==
                                                            'Smart' &&
                                                        lowerBidLimit !=
                                                            smartList[
                                                                'lowerBidLimit']) {
                                                      lowerBidLimit =
                                                          lowerBidLimit - 1;
                                                    } else if (selectedVehicleSubCategory ==
                                                            'Prime' &&
                                                        lowerBidLimit !=
                                                            primeList[
                                                                'lowerBidLimit']) {
                                                      lowerBidLimit =
                                                          lowerBidLimit - 1;
                                                    } else if (selectedVehicleSubCategory ==
                                                            'Mini Van' &&
                                                        lowerBidLimit !=
                                                            miniVan[
                                                                'lowerBidLimit']) {
                                                      lowerBidLimit =
                                                          lowerBidLimit - 1;
                                                    }
                                                  });
                                                  priceCalculation();
                                                },
                                              ),
                                              padding:
                                                  EdgeInsets.only(bottom: 10),
                                            ),
                                            Container(
                                              alignment: Alignment.topCenter,
                                              child: Text(
                                                "Rs." +
                                                    lowerBidLimit.toString(),
                                                style: CustomTextStyle
                                                    .regularTextStyle
                                                    .copyWith(
                                                        color: Colors.white,
                                                        fontSize: 30),
                                              ),
                                              padding:
                                                  EdgeInsets.only(bottom: 10),
                                            ),
                                            Container(
                                              alignment: Alignment.centerRight,
                                              child: GestureDetector(
                                                child: Container(
                                                  alignment:
                                                      Alignment.centerRight,
                                                  child: Text(
                                                    "  +",
                                                    style: CustomTextStyle
                                                        .regularTextStyle
                                                        .copyWith(
                                                            color: Colors.white,
                                                            fontSize: 30,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w900),
                                                  ),
                                                ),
                                                onTap: () {
                                                  setState(() {
                                                    if (selectedVehicleSubCategory ==
                                                            'Tuk' &&
                                                        lowerBidLimit !=
                                                            tukList[
                                                                'upperBidLimit']) {
                                                      lowerBidLimit =
                                                          lowerBidLimit + 1;
                                                    } else if (selectedVehicleSubCategory ==
                                                            'Nano' &&
                                                        lowerBidLimit !=
                                                            nanoList[
                                                                'upperBidLimit']) {
                                                      lowerBidLimit =
                                                          lowerBidLimit + 1;
                                                    } else if (selectedVehicleSubCategory ==
                                                            'Smart' &&
                                                        lowerBidLimit !=
                                                            smartList[
                                                                'upperBidLimit']) {
                                                      lowerBidLimit =
                                                          lowerBidLimit + 1;
                                                    } else if (selectedVehicleSubCategory ==
                                                            'Prime' &&
                                                        lowerBidLimit !=
                                                            primeList[
                                                                'upperBidLimit']) {
                                                      lowerBidLimit =
                                                          lowerBidLimit + 1;
                                                    } else if (selectedVehicleSubCategory ==
                                                            'Mini Van' &&
                                                        lowerBidLimit !=
                                                            miniVan[
                                                                'upperBidLimit']) {
                                                      lowerBidLimit =
                                                          lowerBidLimit + 1;
                                                    }
                                                    priceCalculation();
                                                  });
                                                },
                                              ),
                                              padding:
                                                  EdgeInsets.only(bottom: 10),
                                            )
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Expanded(
                                              child:
                                                  // Container(
                                                  //   height:45,
                                                  //   child:Card(
                                                  //     elevation: 1,
                                                  //     color: Colors.black,
                                                  //     margin: EdgeInsets.all(0),
                                                  //     shape: RoundedRectangleBorder(
                                                  //         borderRadius: BorderRadius.only(
                                                  //           topLeft: Radius.circular(25),
                                                  //           topRight: Radius.circular(25),
                                                  //           bottomLeft: Radius.circular(25),
                                                  //           bottomRight:Radius.circular(25),)),
                                                  //     child: Container(
                                                  //       alignment: Alignment.bottomCenter,
                                                  //       child: Text(
                                                  //         "Book Now",
                                                  //         style: CustomTextStyle.regularTextStyle
                                                  //             .copyWith(
                                                  //             color: Colors.white, fontSize: 16),
                                                  //       ),
                                                  //       padding: EdgeInsets.only( bottom: 10),
                                                  //     ),
                                                  //   ),
                                                  //
                                                  // ),
                                                  GestureDetector(
                                                child: Container(
                                                  height: 45,
                                                  child: Card(
                                                    elevation: 1,
                                                    color: Colors.black,
                                                    margin: EdgeInsets.all(0),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .only(
                                                      topLeft:
                                                          Radius.circular(25),
                                                      topRight:
                                                          Radius.circular(25),
                                                      bottomLeft:
                                                          Radius.circular(25),
                                                      bottomRight:
                                                          Radius.circular(25),
                                                    )),
                                                    child: Container(
                                                      alignment: Alignment
                                                          .bottomCenter,
                                                      child: Text(
                                                        "Book Now",
                                                        style: CustomTextStyle
                                                            .regularTextStyle
                                                            .copyWith(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 16),
                                                      ),
                                                      padding: EdgeInsets.only(
                                                          bottom: 10),
                                                    ),
                                                  ),
                                                ),
                                                onTap: () {

                                                  //socket.clearListeners();
                                                  validateRide();
                                                },
                                              ),
                                              flex: 50,
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              flex: 20,
                            )
                          ],
                        ),
                      ),
                      Container(
                          width: double.infinity,
                          height: 1,
                          color: Color(0xFFFF922C),
                          child: Text('')),
                    ],
                  )
                ],
              ),
            ) ;
          },
        ):Container(
            alignment: Alignment.topCenter,
            color: Colors.white,
            margin: EdgeInsets.only(top: 20),
            child: Center(
              child: CircularProgressIndicator(
                value: 0.8,
                valueColor: new AlwaysStoppedAnimation<Color>(Colors.yellow),
              ),
            )
        ),
      ),
    );
  }

  Future<String> getPassengerDetails() async{
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    String userId = localStorage.getString('userId');
    String temp = localStorage.getString("contactNumber");


    String email = localStorage.getString('email');
    String passengerCode = localStorage.getString('passengerCode');
    String userProfilePic = localStorage.getString('userProfilePic');
    String token = localStorage.getString('token');
    if (this.mounted) {
      setState(() {
        contactNum = temp;
      });
    }

    return userId;
  }
  Future<String> getUserContact() async{
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    String  contactNum = localStorage.getString("userContact");

    return contactNum;
  }

  _setupRideDetails() async {
    rideDetailsList = [
      passengerCode = await getPassengerDetails(),
      widget.isTextWritten,
      widget.pickupPlaceAddress,
      widget.pickupPlace.latitude,
      widget.pickupPlace.longitude,
      widget.dropOffPlaceAddress,
      widget.dropOffPlace.latitude,
      widget.dropOffPlace.longitude,
      distanceKM,
      selectedVehicleCategory,
      selectedVehicleSubCategory,
      lowerBidLimit.toString(),
      tripTotalCost,
      contactNum

    ];


    printRideDetails();

    Navigator.of(context)
        .push(new MaterialPageRoute(builder: (context) => DriverSearch(rideDetailsList: rideDetailsList,)));
  }

  printRideDetails() async {
    print("---------------------- FINALIZED RIDE DETAILS ----------------------");
    print("Passenger Code: ${rideDetailsList[0]}");
    print("Is Text Written: ${rideDetailsList[1]}");
    print("Pickup Place Address: ${rideDetailsList[2]}");
    print("Pickup Place Latitude: ${rideDetailsList[3]}");
    print("Pickup Place Longitude: ${rideDetailsList[4]}");
    print("Drop Place Address: ${rideDetailsList[5]}");
    print("Drop Place Latitude: ${rideDetailsList[6]}");
    print("Drop Place Longitude: ${rideDetailsList[7]}");
    print("Distance: ${rideDetailsList[8]}");
    print("Vehicle Category: ${rideDetailsList[9]}");
    print("Vehicle Sub Category: ${rideDetailsList[10]}");
    print("Lower Bid Limit: ${rideDetailsList[11]}");
    print("Estimate Cost: ${rideDetailsList[12]}");
    print("Contact Number: ${rideDetailsList[13]}");
    print("---------------------- READY TO SET RIDE ----------------------");


  }

  validateRide() async {
    if (selectedVehicleSubCategory == null) {
      print("Please Select Vehicle Category");
      _showWarningToast("Please select vehicle category");
    } else if (distanceKM.toString() == null) {
      print("Invalid distance. Please try again");
      _showWarningToast("Invalid distance. Please try again");
    } else if (selectedVehicleSubCategory == null) {
      print("Please select a vehicle category");
      _showWarningToast("Please select a vehicle category");
    } else if (lowerBidLimit.toString() == null) {
      print("Invalid lower bid limit. Please try again");
      _showWarningToast("Invalid lower bid limit. Please try again");
    } else if (tripTotalCost.toString() == null) {
      print("Invalid estimate cost. Please try again");
      _showWarningToast("Invalid estimate cost. Please try again");
    } else {
      _setupRideDetails();
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

  getDestinationView() {
    return Container(
      padding: EdgeInsets.only(top: 12, bottom: 12),
      width: double.infinity,
      color: Colors.grey.shade100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            "USD 550-600",
            style: CustomTextStyle.regularTextStyle,
          ),
          SizedBox(
            height: 4,
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "Note: ",
                  style: CustomTextStyle.mediumTextStyle
                      .copyWith(color: Colors.grey, fontSize: 12),
                ),
                Expanded(
                  child: Text(
                    "This is an approximate estimate, Actual cost may be different due to traffic and waiting time.",
                    softWrap: true,
                    textAlign: TextAlign.center,
                    style: CustomTextStyle.regularTextStyle
                        .copyWith(color: Colors.grey, fontSize: 12),
                  ),
                  flex: 100,
                )
              ],
            ),
          ),
          /*RichText(
                  text: TextSpan(children: [
                    TextSpan(
                      text: "Note: ",
                      style: CustomTextStyle.mediumTextStyle
                          .copyWith(color: Colors.grey, fontSize: 12),
                    ),
                    TextSpan(
                      text:
                      "This is an approximate estimate, Actual cost may be different due to traffic and waiting time.",
                      style: CustomTextStyle.regularTextStyle
                          .copyWith(color: Colors.grey, fontSize: 12,),
                    )
                  ],
                  ),
                )*/
        ],
      ),
    );
    // : GestureDetector(
    //     onTap: () {
    //       Navigator.of(context).pop();
    //     },
    //     child: Container(
    //       padding: EdgeInsets.only(top: 12, bottom: 12),
    //       width: double.infinity,
    //       color: Colors.grey.shade100,
    //       child: Column(
    //         mainAxisAlignment: MainAxisAlignment.center,
    //         children: <Widget>[
    //           Icon(
    //             Icons.info_outline,
    //             color: Colors.black,
    //             size: 20,
    //           ),
    //           SizedBox(
    //             height: 4,
    //           ),
    //           Text(
    //             "To get estimation please enter the drop off location",
    //             style: CustomTextStyle.regularTextStyle
    //                 .copyWith(color: Colors.grey, fontSize: 12),
    //           )
    //         ],
    //       ),
    //     ),
    //   );
  }

  showFareEstimationBottomSheet() {
    return scaffoldKey.currentState.showBottomSheet((BuildContext context) {
      return Container(
        height: 230,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(16), topLeft: Radius.circular(16))),
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: 16, left: 8, right: 8),
              child: Text(
                "Fare Breakdown",
                style: CustomTextStyle.mediumTextStyle,
              ),
            ),
            Container(
              child: Text(
                "Below mentioned fare rates may change according to surcharge and adjustments.",
                style: CustomTextStyle.regularTextStyle
                    .copyWith(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              margin: EdgeInsets.symmetric(horizontal: 36, vertical: 2),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              margin: EdgeInsets.only(left: 8, right: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(left: 8, top: 8, bottom: 8),
                    child: Text(
                      "Min Fare (First 1 Km)",
                      style: CustomTextStyle.regularTextStyle
                          .copyWith(fontSize: 14),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(right: 8, top: 8, bottom: 8),
                    child: Text(
                      "USD 80.00",
                      style: CustomTextStyle.regularTextStyle
                          .copyWith(color: Colors.grey, fontSize: 14),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 4,
            ),
            Container(
              margin: EdgeInsets.only(left: 8, right: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(left: 8, top: 8, bottom: 8),
                    child: Text(
                      "After 1 Km (Per Km)",
                      style: CustomTextStyle.regularTextStyle
                          .copyWith(fontSize: 14),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(right: 8, top: 8, bottom: 8),
                    child: Text(
                      "USD 5.00",
                      style: CustomTextStyle.regularTextStyle
                          .copyWith(color: Colors.grey, fontSize: 14),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 4,
            ),
            Container(
              margin: EdgeInsets.only(left: 8, right: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(left: 8, top: 8, bottom: 8),
                    child: Text(
                      "Waiting Time (Per 1 Hour)",
                      style: CustomTextStyle.regularTextStyle
                          .copyWith(fontSize: 14),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(right: 8, top: 8, bottom: 8),
                    child: Text(
                      "USD 300.00",
                      style: CustomTextStyle.regularTextStyle
                          .copyWith(color: Colors.grey, fontSize: 14),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 6,
            ),
            Container(
              width: double.infinity,
              child: RaisedButton(
                onPressed: () {},
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(0))),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                child: Text(
                  "Close",
                  style: CustomTextStyle.regularTextStyle,
                ),
                textColor: Colors.black,
                color: Colors.grey.shade200,
              ),
            )
          ],
        ),
      );
    });
  }

  priceCalculation() {
    var totalCost = 0;

    if (selectedCategoryDetail == null || distanceKM == 0.0) return 0;

    if (selectedCategoryDetail['priceSelection'].length != null &&
        selectedCategoryDetail['priceSelection'][0]['timeBase'].length !=
            null) {
      print(distanceKM);
      if (distanceKM <=
          selectedCategoryDetail['priceSelection'][0]['timeBase'][0]
              ['minimumKM']) {
        totalCost = (selectedCategoryDetail['priceSelection'][0]['timeBase'][0]
                    ['baseFare'] +
                selectedCategoryDetail['priceSelection'][0]['timeBase'][0]
                    ['minimumFare'])
            .toInt();
        print('cost1$totalCost');
      } else if (selectedCategoryDetail['priceSelection'][0]['timeBase'][0]
              ['belowAboveKMRange'] >
          0) {
        if (distanceKM <=
            selectedCategoryDetail['priceSelection'][0]['timeBase'][0]
                ['belowAboveKMRange']) {
          totalCost = (selectedCategoryDetail['priceSelection'][0]['timeBase']
                      [0]['baseFare'] +
                  selectedCategoryDetail['priceSelection'][0]['timeBase'][0]
                      ['minimumFare'] +
                  (distanceKM -
                          selectedCategoryDetail['priceSelection'][0]
                              ['timeBase'][0]['minimumKM']) *
                      lowerBidLimit)
              .toInt();
          print('cost2$totalCost');
        } else if (distanceKM >
            selectedCategoryDetail['priceSelection'][0]['timeBase'][0]
                ['belowAboveKMRange']) {
          totalCost = (selectedCategoryDetail['priceSelection'][0]['timeBase']
                      [0]['baseFare'] +
                  selectedCategoryDetail['priceSelection'][0]['timeBase'][0]
                      ['minimumFare'] +
                  (selectedCategoryDetail['priceSelection'][0]['timeBase'][0]
                              ['belowAboveKMRange'] -
                          selectedCategoryDetail['priceSelection'][0]
                              ['timeBase'][0]['minimumKM']) *
                      lowerBidLimit +
                  (distanceKM -
                          selectedCategoryDetail['priceSelection'][0]
                              ['timeBase'][0]['belowAboveKMRange']) *
                      selectedCategoryDetail['priceSelection'][0]['timeBase'][0]
                          ['aboveKMFare'])
              .toInt();
          // print('cost 3$totalCost');
        }
      } else {
        totalCost = (selectedCategoryDetail['priceSelection'][0]['timeBase'][0]
                    ['baseFare'] +
                selectedCategoryDetail['priceSelection'][0]['timeBase'][0]
                    ['minimumFare'] +
                (distanceKM -
                        selectedCategoryDetail['priceSelection'][0]['timeBase']
                            [0]['minimumKM']) *
                    lowerBidLimit)
            .toInt();
        print('cost4 $totalCost');
      }

      var cost = totalCost.toStringAsFixed(2);
      print('cost is$cost');
      setState(() {
        tripTotalCost = cost;
      });

      // this.totalCost!!.text = resources.getString(R.string.rs) + Helpers.currencyFormat(cost)
      // tripRequestModel!!.hireCost = totalCost.toDouble()

    } else {
      // Helpers.showAlertDialog(this, getString(R.string.service_not_available), Helpers.AlertDialogType.WARNING){
      // onBackPressed()
      // }
    }
    return totalCost;
  }
}

class mapMarkerModel {
  double latitude;
  double longitude;

  mapMarkerModel(this.latitude, this.longitude);
}

class Utils {
  static String mapStyles = '''[
  {
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#f5f5f5"
      }
    ]
  },
  {
    "elementType": "labels.icon",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#616161"
      }
    ]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#f5f5f5"
      }
    ]
  },
  {
    "featureType": "administrative.land_parcel",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#bdbdbd"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#eeeeee"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#757575"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#e5e5e5"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#ffffff"
      }
    ]
  },
  {
    "featureType": "road.arterial",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#757575"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#dadada"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#616161"
      }
    ]
  },
  {
    "featureType": "road.local",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  },
  {
    "featureType": "transit.line",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#e5e5e5"
      }
    ]
  },
  {
    "featureType": "transit.station",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#eeeeee"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#c9c9c9"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  }
]''';
}
class PolylineModel {
  PolylineModel(this.points, this.width,this.color);
  final List<MapLatLng> points;
  final double width;
  final Color color;
}
