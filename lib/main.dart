import 'dart:io';
import 'package:closrauth/screens/login_screen.dart';
import 'package:closrauth/screens/setup_screen.dart';

// import 'package:cloud_firestore/cloud_firestore.dart';
import 'screens/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:closrauth/utils/auth.dart';
import 'untracked/specs.dart';

enum AuthStatus {
  NOT_DETERMINED,
  NOT_LOGGED_IN,
  LOGGED_IN_NOT_SETUP,
  LOGGED_IN_SETUP
}

FirebaseOptions _options() {
  var apiKey;
  var googleAppId;

  if (Platform.isIOS) {
    apiKey = apiKeyIos;
    googleAppId = googleAppIDIos;
  } else if (Platform.isAndroid) {
    apiKey = apiKeyAndroid;
    googleAppId = googleAppIDAndroid;
  }
  return FirebaseOptions(
      gcmSenderID: gcmSenderID,
      apiKey: apiKey,
      googleAppID: googleAppId,
      projectID: projectID);
}

void main() async {
  final FirebaseApp app =
      await FirebaseApp.configure(options: _options(), name: 'closrauth');

  runApp(MaterialApp(
      home: ClosrAuth(
    app: app,
    auth: Auth(),
  )));
}

class ClosrAuth extends StatefulWidget {
  final BaseAuth auth;
  final FirebaseApp app;

  ClosrAuth({Key key, this.auth, this.app}) : super(key: key);

  _ClosrAuthState createState() => _ClosrAuthState(app: app, auth: auth);
}

class _ClosrAuthState extends State<ClosrAuth> {
  _ClosrAuthState({this.app, this.auth});
  final FirebaseApp app;
  final BaseAuth auth;

  AuthStatus authStatus = AuthStatus.NOT_DETERMINED;
  String _userId = "";

  @override
  void initState() {
    super.initState();
    widget.auth.currentUser().then((user) {
      setState(() {
        if (user != null) {
          _userId = user?.uid;
        }
        authStatus = user?.uid == null
            ? AuthStatus.NOT_LOGGED_IN
            : AuthStatus.LOGGED_IN_SETUP;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (authStatus) {
      case AuthStatus.NOT_DETERMINED:
        return _buildWaitingScreen();
        break;
      case AuthStatus.NOT_LOGGED_IN:
        return LoginSignupScreen(
          auth: widget.auth,
          onSignedIn: _onLoggedIn,
          onSignedUp: _onSignedUp,
        );
      case AuthStatus.LOGGED_IN_NOT_SETUP:
        return SetupScreen(
          auth: widget.auth,
          onSignedOut: _onSignedOut,
        );
      case AuthStatus.LOGGED_IN_SETUP:
        // return HomeScreen(
        //   auth: widget.auth,
        //   onSignedOut: _onSignedOut,
        // );
        // TODO: For Testing Purpose
        return SetupScreen(
          auth: widget.auth,
          onSignedOut: _onSignedOut,
          onSetupComplete: _onSetupComplete,
        );
        break;
      default:
        return _buildWaitingScreen();
    }
  }

  void _onLoggedIn() {
    widget.auth.currentUser().then((user) {
      setState(() {
        _userId = user.uid.toString();
      });
    });
    setState(() {
      authStatus = AuthStatus.LOGGED_IN_SETUP;
    });
  }

  void _onSignedUp() {
    widget.auth.currentUser().then((user) {
      setState(() {
        _userId = user.uid.toString();
      });
    });
    setState(() {
      authStatus = AuthStatus.LOGGED_IN_NOT_SETUP;
    });
  }

  void _onSignedOut() {
    setState(() {
      authStatus = AuthStatus.NOT_LOGGED_IN;
      _userId = "";
    });
  }

  void _onSetupComplete() {
    setState(() {
      authStatus = AuthStatus.LOGGED_IN_SETUP;
    });
  }

  Widget _buildWaitingScreen() {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ),
    );
  }
}
