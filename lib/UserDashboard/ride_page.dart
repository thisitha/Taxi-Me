import 'package:flutter/material.dart';
import 'package:flutter_cab/UserDashboard/user_dashboard_styles.dart';

class RidePage extends StatefulWidget {
  const RidePage({Key key}) : super(key: key);

  @override
  _RidePageState createState() => _RidePageState();
}

class _RidePageState extends State<RidePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Text(
        "Ride Page",
        style: UserDashBoardStyles().textHeading1(),
      )),
    );
  }
}
