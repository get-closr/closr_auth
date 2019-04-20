import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

enum AuthStatus {
  NOT_DETERMINED,
  NOT_LOGGED_IN,
  LOGGED_IN_NOT_SETUP,
  LOGGED_IN_SETUP
}

abstract class BaseAuth {
  Future<String> signInEmail(String email, String password);
  Future<String> signInGoogle();
  Future<String> signUpEmail(String email, String password);
  Future<void> signOut();
  Future<String> userId();
  Future<FirebaseUser> currentUser();
}

class Auth implements BaseAuth {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<Null> _ensureLoggedIn() async {
    FirebaseUser firebaseUser = await _auth.currentUser();
    if (firebaseUser == null) {
      print("Not logged in");
    } else {
      print("We are logged into Firebase, ${firebaseUser.displayName}");

      if (crossCheckDatabase(firebaseUser)) {
        Firestore.instance
            .collection('users')
            .document(firebaseUser.uid)
            .setData({
          'username': firebaseUser.displayName,
          'photoUrl': firebaseUser.photoUrl,
          'id': firebaseUser.uid,
          'email': firebaseUser.email,
          'partnerId': null,
          'deviceId': null,
        });
      } else {
        print("User exists in database");
      }
    }
  }

  crossCheckDatabase(FirebaseUser firebaseUser) async {
    final QuerySnapshot result = await Firestore.instance
    .collection('users')
    .where('id', isEqualTo: firebaseUser.uid)
    .getDocuments();

    final List<DocumentSnapshot> documents = result.documents;

    return (documents.length==0);

  }

  Future<String> signInEmail(String email, String password) async {
    FirebaseUser user = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
     _ensureLoggedIn();
    return user.uid;
  }

  Future<String> signUpEmail(String email, String password) async {
    List<String> providers =
        await _auth.fetchSignInMethodsForEmail(email: email);
    if (providers != null && providers.length > 0) {
      print("Already has providers: ${providers.toString()}");
    }

    FirebaseUser newuser = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    newuser.sendEmailVerification();
    _ensureLoggedIn();
    return newuser.uid;
  }

  Future<String> signInGoogle() async {
    GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);
    final FirebaseUser user = await _auth.signInWithCredential(credential);

     _ensureLoggedIn();
    return user.uid;
  }

  Future<String> userId() async {
     _ensureLoggedIn();
    FirebaseUser firebaseUser = await _auth.currentUser();
    return firebaseUser.uid;
  }

  Future<FirebaseUser> currentUser() async {
     _ensureLoggedIn();
    FirebaseUser user = await _auth.currentUser();
    return user;
  }

  Future<bool> signOut() async {
    await _auth.signOut();
    print("Loging out");
    return true;
  }
}
