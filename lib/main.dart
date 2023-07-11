import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:social_media_simulation/components/life_cycle_event_handler.dart';
import 'package:social_media_simulation/firebase_options.dart';
import 'package:social_media_simulation/screens/landing_screen/landing_screen.dart';
import 'package:social_media_simulation/screens/login_screen/login_screen.dart';
import 'package:social_media_simulation/screens/main_screen/main_screen.dart';
import 'package:social_media_simulation/services/user_service.dart';
import 'package:social_media_simulation/view_model/theme_view.dart';
import 'package:social_media_simulation/utils/constants.dart';
import 'package:social_media_simulation/utils/firebase.dart';
import 'package:social_media_simulation/utils/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // SystemChrome.setEnabledSystemUIOverlays([]);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(LifeCycleEventHandler(
      detachedCallBack: () => UserService().setUserStatus(false),
      resumeCallBack: () => UserService().setUserStatus(false),
    ));
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: providers,
      child: Consumer<ThemeView>(
        builder: (context, ThemeView notifier, Widget? child) {
          return MaterialApp(
            title: Constants.appName,
            debugShowCheckedModeBanner: false,
            theme: themeData(
              notifier.dark ? Constants.darkTheme : Constants.lightTheme,
            ),
            home: StreamBuilder(
              stream: firebaseAuth.authStateChanges(),
              builder: (BuildContext context, snapshot) {
                if (snapshot.hasData) {
                  return const MainScreen();
                } else {
                  return const LandingScreen();
                }
              },
            ),
          );
        },
      ),
    );
  }

  ThemeData themeData(ThemeData theme) {
    return theme.copyWith(
      textTheme: GoogleFonts.nunitoSansTextTheme(theme.textTheme),
    );
  }
}
