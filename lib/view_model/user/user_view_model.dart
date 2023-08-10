import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';

class UserViewModel extends ChangeNotifier {
  User? user;
  FirebaseAuth auth = FirebaseAuth.instance;

  setUser() {
    user = auth.currentUser;
    // notifyListeners();
  }
}
