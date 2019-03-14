import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

// TODO  stick to one way of writing auth. Prefer fbAuth type.
// TODO  then implement fbDatabase as well as fbStorage

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
