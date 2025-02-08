import 'package:flutter/material.dart';
import 'package:health_care_web/models/style_sheet.dart';
import 'package:health_care_web/pages/navigations/admin_dashboard.dart';
import 'package:health_care_web/pages/navigations/before_login_page.dart';
import 'package:health_care_web/pages/navigations/home.dart';
import 'package:health_care_web/pages/navigations/login_page.dart';
import 'package:health_care_web/pages/pages/medical_report.dart';
import 'package:health_care_web/services/firebase_init.dart';

// import 'package:health_care_web/pages/app/splash.dart';
//
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await FirebaseInit.init();

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
        colorScheme: ColorScheme.fromSeed(seedColor: StyleSheet.btnBackground),
        useMaterial3: true,
      ),
      home: BeforeLoginPage(),
      routes: {
        // Sample routes
        '/login': (context) => const LoginPage(),
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
