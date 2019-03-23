import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

// import 'package:firebase_database/firebase_database.dart';
// import 'package:closrauth/models/user.dart';

abstract class BaseAuth {
  Future<bool> signInEmail(String email, String password);
  Future<bool> signUpEmail(String email, String password);
  Future<bool> signInGoogle();
  Future<void> signOut();
  Future<String> username();
  Future<FirebaseUser> currentUser();
}

class Auth implements BaseAuth {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<bool> signOut() async {
    await _auth.signOut();
    return true;
  }

  Future<bool> ensureLoggedIn() async {
    FirebaseUser firebaseUser = await _auth.currentUser();
    assert(firebaseUser != null);
    assert(firebaseUser.isAnonymous == false);
    print("We are logged into Firebase");
    return true;
  }

  Future<bool> signInEmail(String email, String password) async {
    FirebaseUser user = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
    if (user != null && user.isAnonymous == false) {
      return true;
    } else {
      return false;
    }
    //Perform database check/retrieve user details
  }

  signUpEmail(String email, String password) async {
    List<String> providers = await _auth.fetchSignInMethodsForEmail(email: email);
    if (providers != null && providers.length >0){
      print("Already has providers: ${providers.toString()}");
      // return handleProviders(providers);
      return false;
    }

    FirebaseUser newuser = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    // await newuser.sendEmailVerification();
    // var userUdpdateInfo =UserUpdateInfo();
    // userUdpdateInfo.displayName = name;
    if (newuser != null && newuser.isAnonymous == false) {
      return true;
    } else {
      return false;
    }
    //Create user entry in database
  }

  Future<bool> signInGoogle() async {
    GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);
    final FirebaseUser user = await _auth.signInWithCredential(credential);

    if (user != null && user.isAnonymous == false) {
      return true;
    } else {
      return false;
    }
  }

  Future<String> username() async {
    await ensureLoggedIn();
    FirebaseUser firebaseUser = await _auth.currentUser();
    return firebaseUser.uid;
  }

  Future<FirebaseUser> currentUser() async {
    FirebaseUser user = await _auth.currentUser();
    return user;
  }
}
