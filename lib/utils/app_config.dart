import 'package:flutter/material.dart';

enum AppEnvironmet {DEV, STAGE, PROD}

class AppConfig {
  static final AppConfig _singleton = AppConfig._internal();

  factory AppConfig(){
    return _singleton;
  }

  AppConfig._internal();

  AppEnvironmet appEnvironment;
  String appName;
  String description;
  String baseUrl;
  ThemeData themeData;

  void setAppConfig({
    AppEnvironmet appEnvironment,
    String appName,
    String description,
    String baseUrl,
    ThemeData themeData
  }){
    this.appEnvironment = appEnvironment;
    this.appName = appName;
    this.description = description;
    this.baseUrl = baseUrl;
    this.themeData = themeData;
  }
}