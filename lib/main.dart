import 'package:app_28_pakacademy/form.dart';
import 'package:app_28_pakacademy/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import './constants/constants.dart';
import './ui/signin.dart';
import './ui/signup.dart';
import './ui/splashscreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Login",
      theme: ThemeData(primaryColor: Colors.orange[200]),
      routes: <String, WidgetBuilder>{
        SPLASH_SCREEN: (BuildContext context) => const SplashScreen(),
        SIGN_IN: (BuildContext context) => const SignInPage(),
        SIGN_UP: (BuildContext context) => const SignUpScreen(),
        GIGS_PAGE: (BuildContext context) => const GigsPage(),
      },
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (ctx, userSnapshot) {
          print('user found');
          if (userSnapshot.hasData) {
            return const GigsPage();
          }
          print('user lost');

          return SignInPage();
        },
      ),
    );
  }
}
