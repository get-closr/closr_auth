import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:closrauth/models/user.dart';

DatabaseReference userRef;

void init(FirebaseDatabase database) async {
  userRef =FirebaseDatabase.instance.reference().child('user');
  userRef.keepSynced(true);
  database.setPersistenceEnabled(true);
  database.setPersistenceCacheSizeBytes(1000000);
}

Future<User> getUser() async {
  User user;
  await userRef.once().then((DataSnapshot snapshot){
    print("Connected to the database and read ${snapshot.value}");
    user =snapshot.value;
    //Check current user = database user
  });
  return user;
}