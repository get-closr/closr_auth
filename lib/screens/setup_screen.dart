import 'package:closrauth/utils/auth.dart';
import 'package:flutter/material.dart';

class SetupScreen extends StatefulWidget {
  final BaseAuth auth;
  final VoidCallback onSignedOut;

  SetupScreen({Key key, this.auth, this.onSignedOut}) : super(key: key);

  _SetupScreenState createState() => _SetupScreenState();
}

enum SetupStages { PROFILE, DEVICE, PARTNER }

class _SetupScreenState extends State<SetupScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          color: Colors.green[50],
          child: Column(
            children: <Widget>[
              CircleAvatar(
                radius: 50,
              ),
              Icon(Icons.add_a_photo),
              Text("Username"),
              Icon(Icons.monetization_on),
              Text("Device"),
              Icon(Icons.bluetooth),
              Text("Partner"),
              Icon(Icons.add),
              RaisedButton(
                child: Text("Sign Out"),
                onPressed: _signOut,
              )
            ],
          ),
        ),
      ),
    );
  }

  void _signOut() async {
    try {
      await widget.auth.signOut();
      widget.onSignedOut();
    } catch (e) {}
  }
}