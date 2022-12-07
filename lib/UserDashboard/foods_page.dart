import 'package:flutter/material.dart';
import 'package:flutter_cab/UserDashboard/user_dashboard_styles.dart';

class FoodsPage extends StatefulWidget {
  const FoodsPage({Key key}) : super(key: key);

  @override
  _FoodsPageState createState() => _FoodsPageState();
}

class _FoodsPageState extends State<FoodsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Text(
        "Foods Page",
        style: UserDashBoardStyles().textHeading1(),
      )),
    );
  }
}
