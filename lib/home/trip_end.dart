import 'package:flutter/material.dart';
import 'package:flutter_cab/GetBothLocation/getbothlocations.dart';
import 'package:flutter_cab/utils/CustomTextStyle.dart';
import 'package:flutter_cab/utils/DottedLine.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../complaint.dart';

class TripEnd extends StatefulWidget {
  var tripEndDetails;
  var currentLoaction;
  var destionationLocation;
  var driverDetails;
  var passengerPickupData;
  List passengerDropData = [];
  TripEnd({this.tripEndDetails,this.driverDetails,this.currentLoaction,this.destionationLocation,this.passengerPickupData,this.passengerDropData});
  @override
  _TripEndState createState() => _TripEndState();
}

class _TripEndState extends State<TripEnd> {
  var _ahmedabad  ;
  var _lal_darwaja  ;

  Set<Marker> markers = new Set();

  GoogleMapController mapController;
  BitmapDescriptor bitmapDescriptor;
  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey();

  _TripEndState();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
     _ahmedabad = widget.destionationLocation;
     _lal_darwaja = widget.currentLoaction;
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(), "images/map-marker.png")
        .then((bitmap) {
      bitmapDescriptor = bitmap;
    });
    print(widget.tripEndDetails);
    markers.add(Marker(
        markerId: MarkerId("ahmedabad"),
        position: _ahmedabad,
        infoWindow: InfoWindow(title: "Title", snippet: "Content"),
        icon: bitmapDescriptor));

    /*WidgetsBinding.instance
          .addPostFrameCallback((_) => showTripEndBottomSheet());*/
  }

  void _onMapCreated(GoogleMapController mapController) {
    this.mapController = mapController;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: (){
        Navigator.of(context)
            .push(new MaterialPageRoute(builder: (context) => PickupBothLocationsUser()));
      },
      child: MaterialApp(
        theme: ThemeData(
            primarySwatch: Colors.green,
            dialogTheme: DialogTheme(backgroundColor: Colors.white),
            canvasColor: Colors.transparent,
            accentColor: Colors.amber),
        home: WillPopScope(
          onWillPop: (){
            Navigator.of(context)
                .push(new MaterialPageRoute(builder: (context) => PickupBothLocationsUser()));

          },
          child: Scaffold(
            key: scaffoldKey,
            backgroundColor: Colors.grey,
            //resizeToAvoidBottomPadding: false,
            resizeToAvoidBottomInset: true,
            body: showTripEndBottomSheet(),
            // body: Builder(
            //   builder: (context) {
            //     return Container(
            //       child: Stack(
            //         children: <Widget>[
            //           //  GoogleMap(
            //           //   key: Key("AIzaSyCtg102uMuplrssv_sk_FD-IcKI5hxnnSw"),
            //           //   initialCameraPosition:
            //           //   CameraPosition(target: _ahmedabad, zoom: 14),
            //           //   myLocationEnabled: true,
            //           //   myLocationButtonEnabled: true,
            //           //   markers: markers,
            //           //   onMapCreated: _onMapCreated,
            //           // ),
            //           showTripEndBottomSheet(),
            //         ],
            //       ),
            //     );
            //   },
            // ),
          ),
        ),
      ),
    );
  }

  showTripEndBottomSheet() {
    return Container(
      child: Column(
        children: <Widget>[
          // Expanded(
          //   child: Container(),
          //   flex: 7,
          // ),
          // Expanded(
          //   child: Container(),
          //   flex: 20,
          // ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  // borderRadius: BorderRadius.only(
                  //     topRight: Radius.circular(16),
                  //     topLeft: Radius.circular(16))
                ),
              child: Column(
                children: <Widget>[
                  tripEnd(),
                  driveSection(),
                  DottedLine(12, 12, 4),
                  SizedBox(height: 8,),
                  addressSection(),
                  DottedLine(12, 12, 4),
                  tripFare(),
                  DottedLine(12, 12, 4),
                  rate(),
                  getSizedBox(),
                  getSizedBox(),
                  actionButton()
                ],
              ),
            ),
            flex: 70,
          ),
        ],
      ),
    );
  }

  tripEnd() {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 20, left: 16, right: 16),
            child: RichText(
              text: TextSpan(children: [
                TextSpan(
                    text: "Trip ID :",
                    style: CustomTextStyle.boldTextStyle
                        .copyWith(color: Colors.black)),
                TextSpan(
                    text: widget.driverDetails['tripId'].toString(),
                    style: CustomTextStyle.boldTextStyle
                        .copyWith(color: Colors.grey)),
              ]),
            ),
          ),
          Container(
            child: Icon(
              Icons.close,
              color: Colors.black,
            ),
            margin: EdgeInsets.only(top: 12, right: 8),
          ),
        ],
      ),
    );
  }

  driveSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 80,
          height: 80,
          margin: EdgeInsets.only(top: 16, left: 10),
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            image: DecorationImage(image: NetworkImage(
                widget.driverDetails[
                'driverPic'])),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        SizedBox(
          width: 16,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 20,
            ),
            Container(
              child: Text(
                widget.driverDetails['driverName'].toString(),
                style: CustomTextStyle.mediumTextStyle,
              ),
            ),
            SizedBox(height: 6),
            Container(
              child: Text(
                "Trip end",
                style: CustomTextStyle.mediumTextStyle
                    .copyWith(color: Colors.grey.shade400),
              ),
            ),
            Container(
              padding: EdgeInsets.all(6),
              margin: EdgeInsets.only(top: 6),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.grey, width: 1)),
              child: RichText(
                text: TextSpan(children: [
                  TextSpan(
                      text: widget.driverDetails['vehicleRegistrationNo'].toString(),
                      style: CustomTextStyle.boldTextStyle
                          .copyWith(color: Colors.black)),
                  TextSpan(
                      text: " - ",
                      style: CustomTextStyle.mediumTextStyle
                          .copyWith(color: Colors.grey)),
                  TextSpan(
                      text: widget.driverDetails['vehicleBrand'].toString()+"  "+widget.driverDetails['vehicleModel'].toString()+"("+widget.driverDetails['vehicleColor'].toString()+")",
                      style: CustomTextStyle.regularTextStyle
                          .copyWith(color: Colors.grey)),
                ]),
              ),
            )
          ],
        )
      ],
    );
  }

  addressSection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          height: 4,
        ),
        addressRow(Colors.tealAccent.shade700, widget.passengerPickupData['address'],
            " "),
        SizedBox(
          height: 12,
        ),
        addressRow(Colors.redAccent.shade700, widget.passengerDropData[0]['address'],
            " ")
      ],
    );
  }

  addressRow(Color color, String address, String dateTime) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          height: 10,
          width: 10,
          margin: EdgeInsets.only(left: 16, top: 3),
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(
          width: 12,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(bottom: 4),
              child: Text(
                address,
                style: CustomTextStyle.boldTextStyle,
              ),
            ),
            Container(
              child: Text(
                dateTime,
                style: CustomTextStyle.regularTextStyle
                    .copyWith(color: Colors.grey, fontSize: 12),
              ),
            )
          ],
        )
      ],
    );
  }

  fareDetails() {
    return Column(
      key: Key("ColumnFareDetails"),
      children: <Widget>[
        Container(
          key: Key("ContainerFareDetails"),
          margin: EdgeInsets.only(left: 8, right: 8),
          child: Row(
            key: Key("RowFareDetails"),
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                key: Key("ContainerCashFare"),
                margin: EdgeInsets.only(left: 8, top: 4),
                child: Text(
                  "Cash",
                  key: Key("tvCash"),
                  style:
                      CustomTextStyle.mediumTextStyle.copyWith(fontSize: 12),
                ),
              ),
              Container(
                key: Key("ContainerCashAmountFare"),
                margin: EdgeInsets.only(right: 8, top:4),
                child: Text(
                  "LKR "+widget.tripEndDetails['totalPrice'].toString(),
                  key: Key("tvCashAmount"),
                  style: CustomTextStyle.regularTextStyle
                      .copyWith(color: Colors.grey, fontSize: 12),
                ),
              )
            ],
          ),
        ),
        Container(
          key: Key("ContainerDiscount"),
          margin: EdgeInsets.only(left: 8, right: 8),
          child: Row(
            key: Key("RowDiscount"),
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                key: Key("ContainerDiscountFare"),
                margin: EdgeInsets.only(left: 8, top: 4),
                child: Text(
                  "Discount",
                  key: Key("tvDiscount"),
                  style:
                      CustomTextStyle.mediumTextStyle.copyWith(fontSize: 12),
                ),
              ),
              Container(
                key: Key("ContainerDiscountAmount"),
                margin: EdgeInsets.only(right: 8, top: 8, bottom: 8),
                child: Text(
                  "LKR 0.00",
                  key: Key("tvDiscountAmount"),
                  style: CustomTextStyle.regularTextStyle
                      .copyWith(color: Colors.grey, fontSize: 12),
                ),
              )
            ],
          ),
        ),
        Container(
          key: Key("ContainerPaidAmount"),
          margin: EdgeInsets.only(left: 8, right: 8),
          child: Row(
            key: Key("RowPaidAmount"),
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                key: Key("ContainerPaidAmountFare"),
                margin: EdgeInsets.only(left: 8, top: 4),
                child: Text(
                  "Paid Amount",
                  key: Key("tvPaidAmountFare"),
                  style:
                      CustomTextStyle.mediumTextStyle.copyWith(fontSize: 12),
                ),
              ),
              Container(
                key: Key("ContainerPaidAmountFareAmount"),
                margin: EdgeInsets.only(right: 8, top:4),
                child: Text(
                  "LKR "+widget.tripEndDetails['totalPrice'].toString(),
                  key: Key("tvPaidAmount"),
                  style: CustomTextStyle.regularTextStyle
                      .copyWith(color: Colors.grey, fontSize: 12),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  SizedBox getSizedBox() {
    return SizedBox(
      height: 4,
    );
  }

  tripFare() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          key: Key("tvTripFare"),
          margin: EdgeInsets.only(left: 16, top: 8),
          child: Text(
            "Trip Fare",
            style: CustomTextStyle.boldTextStyle,
          ),
        ),
        Container(
          key: Key("tvPaidBy"),
          margin: EdgeInsets.only(left: 16, top: 4),
          child: Text(
            "Paid By",
            style: CustomTextStyle.regularTextStyle
                .copyWith(color: Colors.grey, fontSize: 12),
          ),
        ),
        getSizedBox(),
        getSizedBox(),
        fareDetails()
      ],
    );
  }

  rate(){
    return Container(
      key: Key("ContainerRate"),
      width: double.infinity,
      child: Column(
        key: Key("ColumnRate"),
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            key: Key("ContainerRateLabel"),
            margin: EdgeInsets.only(left: 16, top: 8),
            child: Text(
              "Let's Rate",
              key: Key("tvRate"),
              style: CustomTextStyle.mediumTextStyle,
            ),
          ),
          Container(
            key: Key("ContainerRateMessage"),
            margin: EdgeInsets.only(left: 16, top: 4),
            child: Text(
              "What do you think about the driver performance?",
              key: Key("tvRateMessage"),
              style: CustomTextStyle.regularTextStyle
                  .copyWith(
                  color: Colors.grey, fontSize: 12),
            ),
          ),
          Container(
            key: Key("ContainerRating"),
            margin: EdgeInsets.only(left: 12, top: 8),
            child: FlutterRatingBar(
              fillColor: Colors.amber,
              initialRating: 0,
              borderColor: Colors.grey.shade400,
              allowHalfRating: true,
              itemPadding: EdgeInsets.all(0),
              itemSize: 24,
              onRatingUpdate: (double rating) {},
            ),
          ),
        ],
      ),
    );
  }

  actionButton(){
    return Container(
      key: Key("ContainerButton"),
      alignment: Alignment.bottomCenter,
      child: Row(
        key: Key("RowButton"),
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            key: Key("ExpandedComplaint"),
            flex: 50,
            child: Container(
              key: Key("ContainerComplaint"),
              margin: EdgeInsets.only(left: 16),
              child: RaisedButton(
                key: Key("BtnComplaint"),
                onPressed: () {
                  Navigator.of(context).push(new MaterialPageRoute(builder: (context)=>Complaint()));
                },
                shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.all(Radius.circular(100)),
                    side: BorderSide(
                        color: Colors.grey.shade400, width: 1)),
                color: Colors.white,
                child: Text(
                  "Complaint",
                  style: CustomTextStyle.mediumTextStyle
                      .copyWith(color: Colors.black),
                ),
              ),
            ),
          ),
          Expanded(
            key: Key("ExpandedResendReceipt"),
            flex: 50,
            child: Container(
              key: Key("ContainerResendReceipt"),
              margin: EdgeInsets.only(left: 4, right: 16),
              child: RaisedButton(
                key: Key("BtnResendReceipt"),
                onPressed: () {},
                shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.all(Radius.circular(100)),
                    side: BorderSide(
                        color: Colors.grey.shade400, width: 1)),
                color: Colors.white,
                child: Text(
                  "Resend Receipt",
                  style: CustomTextStyle.mediumTextStyle
                      .copyWith(color: Colors.black),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
