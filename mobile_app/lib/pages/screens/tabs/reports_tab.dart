// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:smartcare/providers/patient_provider.dart';
// import 'package:smartcare/models/patient_data.dart';
// import 'package:smartcare/screens/report_detail_screen.dart';
// import 'package:intl/intl.dart';

// class ReportsTab extends StatelessWidget {
//   const ReportsTab({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final patientProvider = Provider.of<PatientProvider>(context);
//     final patientData = patientProvider.patientData;

//     if (patientProvider.isLoading) {
//       return const Center(
//         child: CircularProgressIndicator(),
//       );
//     }

//     if (patientProvider.error != null) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(
//               Icons.error_outline,
//               color: Colors.red,
//               size: 60,
//             ),
//             const SizedBox(height: 16),
//             Text(
//               'Error: ${patientProvider.error}',
//               style: const TextStyle(color: Colors.red),
//             ),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: () {
//                 patientProvider.fetchPatientData();
//               },
//               child: const Text('Retry'),
//             ),
//           ],
//         ),
//       );
//     }

//     if (patientData == null || patientData.reports.isEmpty) {
//       return const Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.description_outlined,
//               color: Colors.grey,
//               size: 80,
//             ),
//             SizedBox(height: 16),
//             Text(
//               'No reports available',
//               style: TextStyle(
//                 fontSize: 18,
//                 color: Colors.grey,
//               ),
//             ),
//           ],
//         ),
//       );
//     }

//     return ListView(
//       padding: const EdgeInsets.all(16),
//       children: [
//         const Text(
//           'Your Reports',
//           style: TextStyle(
//             fontSize: 24,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         const SizedBox(height: 16),
//         ...patientData.reports
//             .map((report) => _buildReportCard(context, report)),
//       ],
//     );
//   }

//   Widget _buildReportCard(BuildContext context, Report report) {
//     final dateFormat = DateFormat('MMM dd, yyyy');

//     return Card(
//       margin: const EdgeInsets.only(bottom: 16),
//       elevation: 2,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: InkWell(
//         onTap: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => ReportDetailScreen(report: report),
//             ),
//           );
//         },
//         borderRadius: BorderRadius.circular(12),
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   const Icon(
//                     Icons.description,
//                     color: Colors.teal,
//                     size: 24,
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Text(
//                       report.title,
//                       style: const TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 12),
//               Row(
//                 children: [
//                   const Icon(
//                     Icons.calendar_today,
//                     color: Colors.grey,
//                     size: 16,
//                   ),
//                   const SizedBox(width: 8),
//                   Text(
//                     dateFormat.format(report.date),
//                     style: const TextStyle(
//                       color: Colors.grey,
//                     ),
//                   ),
//                   const Spacer(),
//                   const Icon(
//                     Icons.arrow_forward_ios,
//                     color: Colors.grey,
//                     size: 16,
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
