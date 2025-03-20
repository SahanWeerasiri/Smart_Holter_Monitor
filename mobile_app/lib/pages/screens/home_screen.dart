// import 'package:flutter/material.dart';
// import 'package:health_care/pages/screens/auth/login_screen.dart';
// import 'package:health_care/pages/screens/tabs/summary_tab.dart';
// import 'package:health_care/pages/screens/tabs/reports_tab.dart';
// import 'package:health_care/pages/screens/tabs/chat_tab.dart';
// import 'package:health_care/pages/screens/tabs/profile_tab.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   int _currentIndex = 0;
//   final List<Widget> _tabs = [
//     const SummaryTab(),
//     const ReportsTab(),
//     const ChatTab(),
//     const ProfileTab(),
//   ];

//   @override
//   void initState() {
//     super.initState();
//     // Fetch patient data when the home screen loads
//     Future.microtask(() {
//       Provider.of<PatientProvider>(context, listen: false).fetchPatientData();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final authProvider = Provider.of<AuthProvider>(context);

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('SmartCare'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.logout),
//             onPressed: () async {
//               await authProvider.logout();
//               if (mounted) {
//                 Navigator.of(context).pushReplacement(
//                   MaterialPageRoute(builder: (_) => const LoginScreen()),
//                 );
//               }
//             },
//           ),
//         ],
//       ),
//       body: _tabs[_currentIndex],
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _currentIndex,
//         onTap: (index) {
//           setState(() {
//             _currentIndex = index;
//           });
//         },
//         type: BottomNavigationBarType.fixed,
//         selectedItemColor: Colors.teal,
//         unselectedItemColor: Colors.grey,
//         items: const [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.dashboard),
//             label: 'Summary',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.description),
//             label: 'Reports',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.chat),
//             label: 'Chat',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.person),
//             label: 'Profile',
//           ),
//         ],
//       ),
//     );
//   }
// }
