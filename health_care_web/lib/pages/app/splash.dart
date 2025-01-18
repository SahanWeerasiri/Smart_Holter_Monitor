import 'package:flame_splash_screen/flame_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:health_care_web/pages/app/before_login.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  SplashState createState() => SplashState();
}

class SplashState extends State<Splash> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlameSplashScreen(
        showBefore: (BuildContext context) {
          return const Text(
            'Before logo',
            style: TextStyle(color: Colors.white),
          );
        },
        showAfter: (BuildContext context) {
          return const Text(
            'After logo',
            style: TextStyle(color: Colors.white),
          );
        },
        theme: FlameSplashTheme.dark,
        onFinish: (context) => Navigator.pushReplacement<void, void>(
          context,
          MaterialPageRoute(builder: (context) => const BeforeLogin()),
        ),
      ),
    );
  }
}
