import 'package:flutter/material.dart';

class CurrentUserProfile extends StatelessWidget {
  final Widget child;

  CurrentUserProfile({Key key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: child,
    );
  }
}