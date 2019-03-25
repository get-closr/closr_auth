import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class BaseAuth {
  Future<String> signInEmail(String email, String password);
  Future<String> signInGoogle();
  Future<String> signUpEmail(String email, String password);
  Future<void> signOut();
  Future<String> username();
  Future<FirebaseUser> currentUser();
}

class Auth implements BaseAuth {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<Null> _ensureLoggedIn() async {
    SharedPreferences prefs;
    prefs = await SharedPreferences.getInstance();
    FirebaseUser firebaseUser = await _auth.currentUser();
    if (firebaseUser == null) {
      print("Not logged in");
    } else {
      print("We are logged into Firebase, ${firebaseUser.displayName}");

      if (firebaseUser != null) {
        final QuerySnapshot result = await Firestore.instance
            .collection('users')
            .where('id', isEqualTo: firebaseUser.uid)
            .getDocuments();
        print("check1");
        final List<DocumentSnapshot> documents = result.documents;
        print("check2");
        if (documents.length == 0) {
          Firestore.instance
              .collection('users')
              .document(firebaseUser.uid)
              .setData({
            'username': firebaseUser.email
                .substring(0, firebaseUser.email.indexOf('@')),
            'photoUrl': firebaseUser.photoUrl,
            'id': firebaseUser.uid,
            'email': firebaseUser.email
          });
          prefs.setString("username", firebaseUser.displayName);
          prefs.setString("userid", firebaseUser.uid);
          prefs.setString("useremail", firebaseUser.email);
          prefs.setString("userphotourl", firebaseUser.photoUrl);
        } else {
          print("check3");
          print(documents);
          print("check4");
        }
      }
    }
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

    // _ensureLoggedIn();
    return user.uid;
  }

  Future<String> username() async {
    // await _ensureLoggedIn();
    FirebaseUser firebaseUser = await _auth.currentUser();
    return firebaseUser.displayName;
  }

  Future<FirebaseUser> currentUser() async {
    // await _ensureLoggedIn();
    FirebaseUser user = await _auth.currentUser();
    return user;
  }

  Future<bool> signOut() async {
    await _auth.signOut();
    print("Loging out");
    return true;
  }
}
