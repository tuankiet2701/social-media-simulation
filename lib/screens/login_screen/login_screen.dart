import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';
import 'package:social_media_simulation/components/password_text_field.dart';
import 'package:social_media_simulation/components/text_form_builder.dart';
import 'package:social_media_simulation/screens/forgot_password_screen/forgot_password_screen.dart';
import 'package:social_media_simulation/screens/login_screen/login_model/login_model.dart';
import 'package:social_media_simulation/screens/register_screen/register_screen.dart';
import 'package:social_media_simulation/utils/validation.dart';
import 'package:social_media_simulation/widgets/indicator.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    LoginModel loginModel = Provider.of<LoginModel>(context);
    return LoadingOverlay(
      progressIndicator: circularProgress(context),
      isLoading: loginModel.loading,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          key: loginModel.scaffoldKey,
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
            children: [
              SizedBox(height: MediaQuery.of(context).size.height / 10),
              Container(
                height: 170,
                width: MediaQuery.of(context).size.width,
                child: Image.asset(
                  'assets/images/new1.png',
                ),
              ),
              const Center(
                child: Text(
                  'Welcome Back!',
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Center(
                child: Text(
                  'Login your account and get started!',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w300,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              buildForm(loginModel, context),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Don\'t have an account?'),
                  const SizedBox(width: 5),
                  GestureDetector(
                    child: Text(
                      'Sign Up',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    onTap: () => Navigator.of(context).pushReplacement(
                      CupertinoPageRoute(
                        builder: (_) => const RegisterScreen(),
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  buildForm(LoginModel loginModel, BuildContext context) {
    return Form(
      key: loginModel.formKey,
      child: Column(
        children: [
          TextFormBuilder(
            enabled: !loginModel.loading,
            prefix: Ionicons.mail_outline,
            hintText: 'Email',
            textInputAction: TextInputAction.next,
            validateFunction: Validations.validateEmail,
            onSaved: (String val) {
              loginModel.setEmail(val);
            },
            focusNode: loginModel.emailFN,
            nextFocusNode: loginModel.passFN,
          ),
          const SizedBox(height: 15),
          PasswordFormBuilder(
            enabled: !loginModel.loading,
            prefix: Ionicons.lock_closed_outline,
            suffix: Ionicons.eye_outline,
            hintText: 'Password',
            textInputAction: TextInputAction.done,
            validateFunction: Validations.validatePassword,
            submitAction: () => loginModel.login(context),
            obscureText: true,
            onSaved: (String val) {
              loginModel.setPassword(val);
            },
            focusNode: loginModel.passFN,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: EdgeInsets.only(right: 10.0),
              child: InkWell(
                onTap: () => Navigator.push(
                  context,
                  CupertinoPageRoute(builder: (_) => ForgotPassword()),
                ),
                child: Container(
                  width: 130,
                  height: 40,
                  child: const Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
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
                'Login'.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () => loginModel.login(context),
            ),
          ),
        ],
      ),
    );
  }
}
