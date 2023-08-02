import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:social_media_simulation/utils/firebase.dart';

class UserViewModel extends ChangeNotifier {
  User? user;
  FirebaseAuth auth = FirebaseAuth.instance;

  setUser() {
    user = auth.currentUser;
    // notifyListeners();
  }
}
