import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';
import 'package:social_media_simulation/components/text_form_builder.dart';
import 'package:social_media_simulation/screens/forgot_password_screen/forgot_password_model/forgot_password_model.dart';
import 'package:social_media_simulation/utils/validation.dart';
import 'package:social_media_simulation/widgets/indicator.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  @override
  Widget build(BuildContext context) {
    ForgotPasswordModel forgotPasswordModel =
        Provider.of<ForgotPasswordModel>(context);
    return LoadingOverlay(
      isLoading: forgotPasswordModel.loading,
      progressIndicator: circularProgress(context),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
            children: [
              SizedBox(height: MediaQuery.of(context).size.height / 8),
              Container(
                height: 170,
                width: MediaQuery.of(context).size.width,
                child: Image.asset(
                  'assets/images/new1.png',
                ),
              ),
              Center(
                child: Text(
                  'Input Email to Reset Your Password',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w300,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),
              const SizedBox(height: 25),
              buildForm(forgotPasswordModel, context),
            ],
          ),
        ),
      ),
    );
  }

  buildForm(ForgotPasswordModel forgotPasswordModel, BuildContext context) {
    return Form(
      key: forgotPasswordModel.formKey,
      child: Column(
        children: [
          TextFormBuilder(
            enabled: !forgotPasswordModel.loading,
            prefix: Ionicons.mail_outline,
            hintText: "Email",
            textInputAction: TextInputAction.next,
            validateFunction: Validations.validateEmail,
            onSaved: (String val) {
              forgotPasswordModel.setEmail(val);
            },
            submitAction: () => forgotPasswordModel.forgotPassword(context),
          ),
          const SizedBox(height: 30),
          Container(
            height: 45,
            width: 180,
            child: ElevatedButton(
              style: ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                ),
                backgroundColor: MaterialStateProperty.all<Color>(
                  Theme.of(context).colorScheme.secondary,
                ),
              ),
              child: Text(
                'Confirm'.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () => forgotPasswordModel.forgotPassword(context),
            ),
          )
        ],
      ),
    );
  }
}
