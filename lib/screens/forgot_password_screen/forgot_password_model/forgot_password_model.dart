import 'package:flutter/material.dart';
import 'package:social_media_simulation/services/auth_service.dart';
import 'package:social_media_simulation/utils/validation.dart';
import 'package:social_media_simulation/widgets/showInSnackbar.dart';

class ForgotPasswordModel extends ChangeNotifier {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool validate = false;
  bool loading = false;
  String? email;
  AuthService auth = AuthService();

  forgotPassword(BuildContext context) async {
    loading = true;
    notifyListeners();
    FormState form = formKey.currentState!;
    form.save();
    print(Validations.validateEmail(email));
    if (Validations.validateEmail(email) != null) {
      showInSnackBar(
          'Please input a valid email to reset your password.', context);
    } else {
      try {
        await auth.forgotPassword(email!);
        showInSnackBar(
          'Please check your email for instructions '
          'to reset your password',
          context,
        );
        Navigator.pop(context);
      } catch (e) {
        print(e.toString());
        showInSnackBar('Invalid Email', context);
      }
    }
    loading = false;
    notifyListeners();
  }

  setEmail(val) {
    email = val;
    notifyListeners();
  }
}
