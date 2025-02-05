import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Import the dotenv package
import 'package:firebase_core/firebase_core.dart';
import 'package:health_care_web/constants/consts.dart';
import 'package:health_care_web/pages/navigations/admin_dashboard.dart';
import 'package:health_care_web/pages/navigations/before_login_page.dart';
import 'package:health_care_web/pages/navigations/home.dart';
import 'package:health_care_web/pages/navigations/login_page.dart';
import 'package:health_care_web/pages/pages/medical_report.dart';
import 'package:health_care_web/pages/navigations/signup_page.dart';

// import 'package:health_care_web/pages/app/splash.dart';
//
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load the .env file
  await dotenv.load(fileName: ".env");

  // Initialize Firebase
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: dotenv.env['API_KEY']!,
      authDomain: dotenv.env['AUTH_DOMAIN'],
      databaseURL: dotenv.env['DATABASE_URL'],
      projectId: dotenv.env['PROJECT_ID']!,
      storageBucket: dotenv.env['STORAGE_BUCKET'],
      messagingSenderId: dotenv.env['MESSAGING_SENDER_ID']!,
      appId: dotenv.env['APP_ID']!,
      measurementId: dotenv.env['MEASUREMENT_ID'],
    ),
  );

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
        '/signup': (context) => const SignupPage(),
        '/before_login': (context) => const BeforeLoginPage(),
        '/home': (context) => const Home(),
        '/admin_dashboard': (context) => const AdminDashboard(),
        '/medical_report': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map;
          return MedicalReport(
            profile: args['profile'],
            doctor: args['doctor'],
            report: args['report'],
            reportsList: args['reportsList'],
          );
        },
      },
    );
  }
}
