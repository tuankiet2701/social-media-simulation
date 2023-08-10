import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';
import 'package:social_media_simulation/components/password_text_field.dart';
import 'package:social_media_simulation/components/text_form_builder.dart';
import 'package:social_media_simulation/screens/login_screen/login_screen.dart';
import 'package:social_media_simulation/view_model/register_view_model/register_model.dart';
import 'package:social_media_simulation/utils/validation.dart';
import 'package:social_media_simulation/widgets/indicator.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  @override
  Widget build(BuildContext context) {
    RegisterViewModel registerModel = Provider.of<RegisterViewModel>(context);
    return SafeArea(
      child: LoadingOverlay(
        progressIndicator: circularProgress(context),
        isLoading: registerModel.loading,
        child: SafeArea(
          child: Scaffold(
            key: registerModel.scaffoldKey,
            body: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              children: [
                Text(
                  'Welcome to Milo\nCreate a new account to connect your friends',
                  style: GoogleFonts.nunitoSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                  ),
                ),
                const SizedBox(height: 30),
                buildForm(registerModel, context),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        const Text('Already hava an account?'),
                        const SizedBox(width: 5),
                        GestureDetector(
                          onTap: () => Navigator.of(context).pushReplacement(
                            CupertinoPageRoute(
                              builder: (_) => LoginScreen(),
                            ),
                          ),
                          child: Text(
                            'Login',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  buildForm(RegisterViewModel registerModel, BuildContext context) {
    return Form(
      key: registerModel.formKey,
      // autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        children: [
          TextFormBuilder(
            enabled: !registerModel.loading,
            prefix: Ionicons.person_outline,
            hintText: 'Username',
            textInputAction: TextInputAction.next,
            validateFunction: Validations.validateName,
            onSaved: (String val) {
              registerModel.setName(val);
            },
            focusNode: registerModel.usernameFN,
            nextFocusNode: registerModel.emailFN,
          ),
          const SizedBox(height: 20),
          TextFormBuilder(
            enabled: !registerModel.loading,
            prefix: Ionicons.mail_outline,
            hintText: 'Email',
            textInputAction: TextInputAction.next,
            validateFunction: Validations.validateEmail,
            onSaved: (String val) {
              registerModel.setEmail(val);
            },
            focusNode: registerModel.emailFN,
            nextFocusNode: registerModel.passwordFN,
          ),
          const SizedBox(height: 20),
          PasswordFormBuilder(
            enabled: !registerModel.loading,
            prefix: Ionicons.lock_closed_outline,
            suffix: Ionicons.eye_outline,
            hintText: 'Password',
            textInputAction: TextInputAction.next,
            validateFunction: Validations.validatePassword,
            obscureText: true,
            onSaved: (String val) {
              registerModel.setPassword(val);
            },
            focusNode: registerModel.passwordFN,
            nextFocusNode: registerModel.cPasswordFN,
          ),
          const SizedBox(height: 20),
          PasswordFormBuilder(
            enabled: !registerModel.loading,
            prefix: Ionicons.lock_open_outline,
            suffix: Ionicons.eye_outline,
            hintText: 'Confirm Password',
            textInputAction: TextInputAction.done,
            validateFunction: Validations.validatePassword,
            obscureText: true,
            onSaved: (String val) {
              registerModel.setConfirmPass(val);
            },
            focusNode: registerModel.cPasswordFN,
            submitAction: () => registerModel.register(context),
          ),
          const SizedBox(height: 25),
          Container(
            height: 45,
            width: 180,
            child: ElevatedButton(
              style: ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                    40,
                  )),
                ),
                backgroundColor: MaterialStateProperty.all<Color>(
                  Theme.of(context).colorScheme.secondary,
                ),
              ),
              child: Text(
                'sign up'.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () => registerModel.register(context),
            ),
          ),
        ],
      ),
    );
  }
}
