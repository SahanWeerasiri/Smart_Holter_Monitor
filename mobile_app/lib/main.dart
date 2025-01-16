import 'package:flutter/material.dart';
import 'package:health_care/constants/consts.dart';
import 'package:health_care/pages/app/before_login.dart';
import 'package:health_care/pages/app/home.dart';
import 'package:health_care/pages/app/login.dart';
import 'package:health_care/pages/app/signup.dart';
import 'package:firebase_core/firebase_core.dart';
import 'pages/app/splash.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: CustomColors().blue),
        useMaterial3: true,
      ),
      home: Splash(),
      routes: {
        // Sample routes
        '/login': (context) => const Login(),
        '/signup': (context) => const Signup(),
        '/before_login': (context) => const BeforeLogin(),
        '/home': (context) => const Home(),
      },
    );
  }
}
