import 'package:closr_auth/screens/login_screen.dart';
import 'package:flutter/material.dart';

void main() => runApp(ClosrAuth());

class ClosrAuth extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Closr Auth",
      theme: ThemeData(primarySwatch: Colors.amber),
      home: LoginSignupScreen(),
    );
  }
}
