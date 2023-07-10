import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_media_simulation/utils/firebase.dart';

class AuthService {
  User getCurrentUser() {
    User user = firebaseAuth.currentUser!;
    return user;
  }

  //create a firebase user
  Future<bool> createUser({
    String? name,
    User? user,
    String? email,
    String? password,
  }) async {
    var res = await firebaseAuth.createUserWithEmailAndPassword(
        email: '$email', password: '$password');
    if (res.user != null) {
      await saveUserToFirestore(name!, res.user!, email!);
      return true;
    } else {
      return false;
    }
  }

  //save the details inputted by the user to firebase
  saveUserToFirestore(String name, User user, String email) async {
    await usersRef.doc(user.uid).set({
      'username': name,
      'email': email,
      'time': Timestamp.now(),
      'id': user.uid,
      'bio': "",
      'photoUrl':
          'https://cdn1.iconfinder.com/data/icons/user-pictures/100/unknown-512.png',
      'gender': '',
    });
  }

  //function to login a user with email and password
  Future<bool> LoginUser(
      {required String email, required String password}) async {
    var res = await firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
    return res.user != null ? true : false;
  }

  forgotPassword(String email) async {
    await firebaseAuth.sendPasswordResetEmail(email: email);
  }

  logOut() async {
    await firebaseAuth.signOut();
  }

  String handleFirebaseAuthError(String e) {
    if (e.contains("ERROR_WEAK_PASSWORD")) {
      return "Password is too weak";
    } else if (e.contains("invalid-email")) {
      return "Invalid Email";
    } else if (e.contains("ERROR_EMAIL_ALREADY_IN_USE") ||
        e.contains('email-already-in-use')) {
      return "The email address is already in use by another account.";
    } else if (e.contains("ERROR_NETWORK_REQUEST_FAILED")) {
      return "Network error occured!";
    } else if (e.contains("ERROR_USER_NOT_FOUND") ||
        e.contains('firebase_auth/user-not-found')) {
      return "Email or Password is incorrect.";
    } else if (e.contains("ERROR_WRONG_PASSWORD") ||
        e.contains('wrong-password')) {
      return "Email or Password is incorrect.";
    } else if (e.contains('firebase_auth/requires-recent-login')) {
      return 'This operation is sensitive and requires recent authentication.'
          ' Log in again before retrying this request.';
    } else {
      return e;
    }
  }
}
