import 'package:flutter/material.dart';
import 'package:flutter_cab/UserDashboard/user_dashboard_styles.dart';

class PackagesPage extends StatefulWidget {
  const PackagesPage({Key key}) : super(key: key);

  @override
  _PackagesPageState createState() => _PackagesPageState();
}

class _PackagesPageState extends State<PackagesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Text(
        "Packages Page",
        style: UserDashBoardStyles().textHeading1(),
      )),
    );
  }
}
