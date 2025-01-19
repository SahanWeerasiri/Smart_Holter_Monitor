import 'package:flutter/material.dart';
import 'package:health_care_web/constants/consts.dart';
import 'package:health_care_web/pages/app/before_login_page.dart';
import 'package:health_care_web/pages/app/home.dart';
import 'package:health_care_web/pages/app/login_page.dart';
import 'package:health_care_web/pages/app/signup.dart';
// import 'package:health_care_web/pages/app/splash.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Care',
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(seedColor: StyleSheet().btnBackground),
        useMaterial3: true,
      ),
      home: BeforeLoginPage(),
      routes: {
        // Sample routes
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const Signup(),
        '/before_login': (context) => const BeforeLoginPage(),
        '/home': (context) => const Home(),
      },
    );
  }
}
