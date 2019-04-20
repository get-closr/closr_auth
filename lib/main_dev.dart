//Dart import
import 'dart:io';

//Flutter Packages
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

//Project Utils
import 'package:closrauth/utils/auth.dart';
import 'package:closrauth/utils/app_config.dart';

//Project Screens
import 'package:closrauth/closr_auth.dart';
//Others
import 'untracked/specs.dart';


//Settings for setting up Firebase App.
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
  AppConfig().setAppConfig(
    appEnvironment: AppEnvironmet.DEV,
    appName: 'Closr Auth',
    description: 'This is the Developmental version of Closr Auth',
    baseUrl: "",
    themeData: ThemeData(
      primarySwatch: Colors.red,
      primaryColor: Colors.blueGrey
    )
  );

  final FirebaseApp app =
      await FirebaseApp.configure(options: _options(), name: 'closrauth');

  runApp(MaterialApp(
      home: ClosrAuth(
    app: app,
    auth: Auth(),
  )));
}