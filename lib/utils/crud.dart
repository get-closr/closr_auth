import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CrudMedthods {
  bool isLoggedIn() {
    if (FirebaseAuth.instance.currentUser() != null) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> addData(carData) async {
    if (isLoggedIn()) {
      Firestore.instance.collection('users').add(carData).catchError((e) {
        print(e);
      });
    } else {
      print('You need to be logged in');
    }
  }

  getCurrentUserData() async {
    FirebaseUser firebaseUser = await FirebaseAuth.instance.currentUser();
    return Firestore.instance
        .collection('users')
        .where('id', isEqualTo: firebaseUser.uid)
        .snapshots();
  }

  updateData(selectedDoc, newValues) async {
    Firestore.instance
        .collection('users')
        .document(selectedDoc)
        .updateData(newValues)
        .catchError((e) {
      print(e);
    });
  }

  deleteData(docId) async {
    Firestore.instance
        .collection('users')
        .document(docId)
        .delete()
        .catchError((e) {
      print(e);
    });
  }
}
