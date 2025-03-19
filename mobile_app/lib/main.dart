import 'package:flutter/material.dart';
import 'package:health_care/pages/app/before_login.dart';
import 'package:health_care/pages/app/home.dart';
import 'package:health_care/pages/app/login.dart';
import 'package:health_care/pages/app/signup.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:health_care/pages/app/splash_screen.dart';

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
      title: 'SmartCare',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        fontFamily: 'Poppins',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.teal,
          elevation: 0,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          contentPadding: const EdgeInsets.all(15),
        ),
      ),
      home: const SplashScreen(),
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
