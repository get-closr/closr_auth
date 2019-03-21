import 'package:closrauth/utils/auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  final BaseAuth auth;
  final VoidCallback onSignedOut;
  final String userId;

  HomeScreen({Key key, this.auth, this.onSignedOut, this.userId})
      : super(key: key);

  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard"),
        leading: IconButton(
          icon: Icon(
            Icons.menu,
            semanticLabel: 'menu',
          ),
          onPressed: () {},
        ),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(
              bluetoothStatus(1),
              semanticLabel: 'bluetooth',
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(
              Icons.exit_to_app,
              semanticLabel: 'logout',
            ),
            onPressed: _signOut,
          )
        ],
      ),
      body: _dashboardWidgets(),
    );
  }

  IconData bluetoothStatus(int status) {
    List<IconData> iconList = [
      Icons.bluetooth_connected,
      Icons.bluetooth_disabled,
      Icons.bluetooth_searching,
      Icons.check_circle
    ];
    return iconList[status];
  }

  void _signOut() async {
    try {
      await widget.auth.signOut();
      widget.onSignedOut();
    } catch (e) {}
  }

  Widget _dashboardWidgets() {
    return SafeArea(
      bottom: true,
      child: Container(
        color: Colors.pink[100],
        child: ListView(
          children: <Widget>[
            Text("User profile"),
            Text("Bluetooth Status"),
            Text("Chat")
          ],
        ),
      ));
  }
}
