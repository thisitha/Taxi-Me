import 'package:flutter/material.dart';
import 'package:flutter_cab/home/pickup_user.dart';
import 'package:flutter_cab/menu/menu.dart';
import 'package:flutter_cab/utils/CustomTextStyle.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_place_picker/google_maps_place_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:socket_io_client/socket_io_client.dart'as IO;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var _currentLocation = LatLng(6.965176, 79.922377);
  Set<Marker> markers = new Set();
  PickResult selectedPlace;
  GoogleMapController mapController;
  BitmapDescriptor bitmapDescriptor;
  IO.Socket socket;
  @override
  void initState() {

    // TODO: implement initState

    super.initState();
    createSocketConnection();
    getCurrentLocation();

    markers.add(Marker(
        markerId: MarkerId("ahmedabad"),
        position: _currentLocation,
        icon: bitmapDescriptor));

  }
  createSocketConnection() {

    socket= IO.io('ws://173.82.95.250:8101', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });
    socket.connect();
   // print(socket.connected);
    socket.emit('/test', 'test');

  }
void getCurrentLocation()async{
  Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  print(position);
  // _currentLocation=position
}
  void _onMapCreated(GoogleMapController mapController) {
    this.mapController = mapController;
  }

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      home: Scaffold(
        //resizeToAvoidBottomPadding: false,
        resizeToAvoidBottomInset: true,
        body: Builder(
          builder: (context) {
            return Container(
              child: Stack(
                children: <Widget>[
                  SizedBox(
                    height: 20,
                  ),
                  selectedPlace == null ? Container() : Text(selectedPlace.formattedAddress ?? ""),
                  PlacePicker(
                    apiKey: 'AIzaSyCtg102uMuplrssv_sk_FD-IcKI5hxnnSw',
                    useCurrentLocation: true,
                    selectInitialPosition: true,
                    initialPosition: _currentLocation,
                    usePlaceDetailSearch: true,
                    onPlacePicked: (result) {
                      selectedPlace = result;
                      Navigator.of(context).pop();
                      setState(() {});
                    },
                    forceSearchOnZoomChanged: true,
                    automaticallyImplyAppBarLeading: false,
                    autocompleteLanguage: "si",
                    region: 'LK',
                    //selectInitialPosition: true,
                    selectedPlaceWidgetBuilder: (_, selectedPlace, state, isSearchBarFocused) {
                      print("state: $state, isSearchBarFocused: $isSearchBarFocused");
                      return isSearchBarFocused
                          ? Container()
                          : FloatingCard(
                        bottomPosition: 20.0, // MediaQuery.of(context) will cause rebuild. See MediaQuery document for the information.
                        leftPosition: 80.0,
                        rightPosition: 80.0,
                        width: 500,
                        borderRadius: BorderRadius.circular(12.0),
                        child: state == SearchingState.Searching
                            ? Center(child: CircularProgressIndicator())
                            :            RaisedButton(
                          onPressed: () {
                            print(selectedPlace.geometry.location);
                            // Navigator.of(context).push(new MaterialPageRoute(builder: (context)=>PickupUser(selectedPlace)));
                          },
                          child: Column(children: [
                            selectedPlace == null ? Container() : Text(selectedPlace.formattedAddress ?? ""),
                            SizedBox(
                              height: 20,
                            ),
                            Container(
                              height: 50.0,
                              margin: EdgeInsets.all(10),
                              child: RaisedButton(
                                onPressed: () {
                                  // Navigator.of(context).push(new MaterialPageRoute(builder: (context)=>PickupUser(selectedPlace)));
                                },
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(80.0)),
                                padding: EdgeInsets.all(0.0),
                                child: Ink(
                                  decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [Color(0xff374ABE), Color(0xff64B6FF)],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ),
                                      borderRadius: BorderRadius.circular(20.0)),
                                  child: Container(
                                    alignment: Alignment.centerLeft,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        Text(
                                          'Select Location',
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Icon(
                                          Icons.arrow_forward,
                                          color: Colors.white,
                                        )
                                      ],
                                    ),
                                ),
                              ),
                            ),
                            )
                        // RaisedButton(child: Text(
                        //     "Select Here",
                        //     style: CustomTextStyle.regularTextStyle
                        //         .copyWith(color: Colors.white),
                        //   ),),
                            // Text(
                            //   "Select Here",
                            //   style: CustomTextStyle.regularTextStyle
                            //       .copyWith(color: Colors.black),
                            // ),
                          ],),
                          padding:
                          EdgeInsets.symmetric(horizontal: 40, vertical: 4),
                          color: Colors.amber,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(24))),
                        ),
                      );
                    },
                    pinBuilder: (context, state) {
                      if (state == PinState.Idle) {
                        // return Icon(Icons.location_on,size: 40,color: Colors.pinkAccent,);
                        return Image.asset('images/green_location_icon.png',height:50,);
                      } else {
                        //return Icon(Icons.location_on_outlined,size: 40,color: Colors.pinkAccent,);
                        return Image.asset('images/pickup_location_marker.png',height: 100,);
                      }
                    },
                  ),
                  // selectedPlace == null ? Container() : Text(selectedPlace.formattedAddress ?? ""),
                  // GoogleMap(
                  //   initialCameraPosition:
                  //       CameraPosition(target: _ahmedabad, zoom: 14),
                  //   myLocationEnabled: true,
                  //   myLocationButtonEnabled: true,
                  //   markers: markers,
                  //   onMapCreated: _onMapCreated,
                  // ),
                  //CustomPlacePicker(),
                  Column(
                    children: <Widget>[

                      SizedBox(
                        height: 20,
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          child: IconButton(
                              icon: Icon(Icons.menu), onPressed: () {
                                showDialog(context: context,builder: (context){
                                  return Menu();
                                });
                          }),
                        ),
                      ),
                      // Card(
                      //   margin:
                      //       EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      //   child: Container(
                      //     child: Row(
                      //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //       children: <Widget>[
                      //         Container(
                      //           width: 10,
                      //           margin: EdgeInsets.only(left: 16),
                      //           decoration: BoxDecoration(
                      //             shape: BoxShape.circle,
                      //             color: Colors.green,
                      //           ),
                      //           height: 10,
                      //         ),
                      //         Expanded(
                      //           child: Container(
                      //             margin: EdgeInsets.only(left: 16),
                      //             child: Text(
                      //               "Dalugama Kelaniya",
                      //               style: CustomTextStyle.regularTextStyle
                      //                   .copyWith(color: Colors.grey.shade800),
                      //             ),
                      //           ),
                      //           flex: 100,
                      //         ),
                      //         IconButton(
                      //             icon: Icon(
                      //               Icons.favorite_border,
                      //               color: Colors.grey,
                      //               size: 18,
                      //             ),
                      //             onPressed: () {})
                      //       ],
                      //     ),
                      //   ),
                      // ),
                      Expanded(
                        child: Container(
                          width: double.infinity,
                           alignment: Alignment.centerRight,
                           child: Column(
                             mainAxisAlignment: MainAxisAlignment.center,
                             crossAxisAlignment: CrossAxisAlignment.end,
                             children: <Widget>[
                               Container(
                                 decoration: BoxDecoration(
                                     borderRadius: BorderRadius.only(topLeft: Radius.circular(8),bottomLeft: Radius.circular(8)),
                                   boxShadow: [
                                     BoxShadow(color: Colors.grey.shade400,blurRadius: 20,offset: Offset(-6, -10)),
                                     BoxShadow(color: Colors.grey.shade400,blurRadius: 20,offset: Offset(-6, 10))
                                   ]
                                 ),
                                 child: Card(
                                   elevation: 1,
                                   margin: EdgeInsets.all(0),
                                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(8),bottomLeft: Radius.circular(8))),
                                   child: Container(
                                     margin: EdgeInsets.all(24),
                                     child: Column(
                                       children: <Widget>[

                                         Text("Tuk",style: CustomTextStyle.mediumTextStyle.copyWith(color: Colors.grey),),
                                         SizedBox(height: 2,),
                                         Image(image: AssetImage("images/tuk.png"),),
                                         SizedBox(height: 12,),
                                         Text("Nano",style: CustomTextStyle.mediumTextStyle,),
                                         SizedBox(height: 2,),
                                         Image(image: AssetImage("images/car.png"),),
                                         SizedBox(height: 12,),
                                         Text("Mini",style: CustomTextStyle.mediumTextStyle.copyWith(color: Colors.grey),),
                                         SizedBox(height: 2,),
                                         Image(image: AssetImage("images/hatchback.png"),),
                                         SizedBox(height: 12,),
                                         Text("Sedan",style: CustomTextStyle.mediumTextStyle.copyWith(color: Colors.grey),),
                                         SizedBox(height: 2,),
                                         Image(image: AssetImage("images/city.png"),),
                                         SizedBox(height: 12,),
                                         Text("Van",style: CustomTextStyle.mediumTextStyle.copyWith(color: Colors.grey),),
                                         SizedBox(height: 2,),
                                         Image(image: AssetImage("images/van.png"),),
                                       ],
                                     ),
                                   ),
                                 ),
                               )
                             ],
                           ),
                        ),
                        flex: 100,
                      ),
                      // Container(
                      //   width: 36,
                      //   height: 36,
                      //   decoration: BoxDecoration(
                      //       color: Colors.black.withOpacity(0.4),
                      //       shape: BoxShape.circle,
                      //       image: DecorationImage(
                      //         image: AssetImage("images/navigation.png"),
                      //       )),
                      // ),
                      SizedBox(
                        height: 20,
                      ),

                      // RaisedButton(
                      //   onPressed: () {
                      //     Navigator.of(context).push(new MaterialPageRoute(builder: (context)=>PickupUser()));
                      //   },
                      //   child: selectedPlace == null ? Container() : Text(selectedPlace.formattedAddress ?? "",style: CustomTextStyle.regularTextStyle
                      //       .copyWith(color: Colors.brown.shade400)),
                      //   padding:
                      //       EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                      //   color: Colors.amber,
                      //   shape: RoundedRectangleBorder(
                      //       borderRadius: BorderRadius.all(Radius.circular(24))),
                      // ),
                      SizedBox(
                        height:80,
                      )
                    ],
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
