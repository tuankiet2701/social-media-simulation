import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:social_media_simulation/screens/edit_profile_screen/edit_profile_screen.dart';
import 'package:social_media_simulation/screens/main_screen/main_screen.dart';
import 'package:social_media_simulation/screens/profile_screen/profile_screen.dart';
import 'package:social_media_simulation/services/auth_service.dart';
import 'package:social_media_simulation/widgets/showInSnackbar.dart';

class LoginViewModel extends ChangeNotifier {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool validate = false;
  bool loading = false;
  String? email, password;
  FocusNode emailFN = FocusNode();
  FocusNode passFN = FocusNode();
  AuthService auth = AuthService();

  login(BuildContext context) async {
    FormState form = formKey.currentState!;
    form.save();

    if (!form.validate()) {
      validate = true;
      notifyListeners();
      showInSnackBar(
          'Please fix the errors in red before submitting!', context);
    } else {
      loading = true;
      notifyListeners();
      try {
        bool success = await auth.LoginUser(email: email!, password: password!);
        print(success);
        if (success) {
          Navigator.of(context).pushReplacement(
            CupertinoPageRoute(
              builder: (_) => MainScreen(),
            ),
          );
        }
      } catch (e) {
        loading = false;
        notifyListeners();
        print(e);
        showInSnackBar(auth.handleFirebaseAuthError(e.toString()), context);
      }
    }
  }

  setEmail(val) {
    email = val;
    notifyListeners();
  }

  setPassword(val) {
    password = val;
    notifyListeners();
  }
}
