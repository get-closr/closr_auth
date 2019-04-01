import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';


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
    // 1. currentuser, confirm logged in, firebaseUser!=null
    // 2. crosscheck database with currentUser()
    // 3. safe to shared SharedPreferences

    // SharedPreferences prefs;
    // prefs = await SharedPreferences.getInstance();
    FirebaseUser firebaseUser = await _auth.currentUser();
    if (firebaseUser == null) {
      print("Not logged in");
    } else {
      print("We are logged into Firebase, ${firebaseUser.displayName}");

      //check if user exists
      final QuerySnapshot result = await Firestore.instance
          .collection('users')
          .where('id', isEqualTo: firebaseUser.uid)
          .getDocuments();

      final List<DocumentSnapshot> documents = result.documents;

      //if user does not exist
      if (documents.length == 0) {
        Firestore.instance
            .collection('users')
            .document(firebaseUser.uid)
            .setData({
          'username': firebaseUser.displayName,
          'photoUrl': firebaseUser.photoUrl, //make list of random initial photos
          'id': firebaseUser.uid,
          'email': firebaseUser.email,
          'partnerId': "",
          'deviceId': "",
          //add other fields
        });
      } else {
        print(documents);
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

  Future<String> userId() async {
    await _ensureLoggedIn();
    FirebaseUser firebaseUser = await _auth.currentUser();
    return firebaseUser.uid;
  }

  Future<FirebaseUser> currentUser() async {
    await _ensureLoggedIn();
    FirebaseUser user = await _auth.currentUser();
    return user;
  }

  Future<bool> signOut() async {
    await _auth.signOut();
    print("Loging out");
    return true;
  }
}
