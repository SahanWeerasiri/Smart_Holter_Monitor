// import 'package:flutter/material.dart';
// import 'package:health_care/models/user.dart';

// class SummaryTab extends StatelessWidget {
//   const SummaryTab({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final patientData = Account.instance;

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

//     if (patientData == null) {
//       return const Center(
//         child: Text('No data available'),
//       );
//     }

//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Heart Health Summary',
//             style: TextStyle(
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 24),
//           _buildHeartRateCard(patientData),
//           const SizedBox(height: 24),
//           _buildDoctorCard(context, patientData),
//         ],
//       ),
//     );
//   }

//   Widget _buildHeartRateCard(PatientData patientData) {
//     Color statusColor;
//     IconData statusIcon;

//     switch (patientData.status.toLowerCase()) {
//       case 'good':
//         statusColor = Colors.green;
//         statusIcon = Icons.check_circle;
//         break;
//       case 'moderate':
//         statusColor = Colors.orange;
//         statusIcon = Icons.warning;
//         break;
//       case 'bad':
//         statusColor = Colors.red;
//         statusIcon = Icons.error;
//         break;
//       default:
//         statusColor = Colors.grey;
//         statusIcon = Icons.help;
//     }

//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             Row(
//               children: [
//                 Expanded(
//                   child: _buildHeartRateItem(
//                     'Current BPM',
//                     patientData.currentBpm.toString(),
//                     Icons.favorite,
//                     Colors.red,
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: _buildHeartRateItem(
//                     'Average BPM',
//                     patientData.averageBpm.toString(),
//                     Icons.favorite_border,
//                     Colors.red,
//                   ),
//                 ),
//               ],
//             ),
//             const Divider(height: 32),
//             Row(
//               children: [
//                 Icon(
//                   statusIcon,
//                   color: statusColor,
//                   size: 28,
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         'Status',
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: Colors.grey,
//                         ),
//                       ),
//                       Text(
//                         patientData.status,
//                         style: TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                           color: statusColor,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildHeartRateItem(
//       String label, String value, IconData icon, Color color) {
//     return Column(
//       children: [
//         Icon(
//           icon,
//           color: color,
//           size: 40,
//         ),
//         const SizedBox(height: 8),
//         Text(
//           value,
//           style: const TextStyle(
//             fontSize: 32,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         Text(
//           label,
//           style: const TextStyle(
//             fontSize: 14,
//             color: Colors.grey,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildDoctorCard(BuildContext context, PatientData patientData) {
//     if (patientData.assignedDoctor == null) {
//       return Card(
//         elevation: 4,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16),
//         ),
//         child: const Padding(
//           padding: EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Assigned Doctor',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               SizedBox(height: 16),
//               Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(
//                       Icons.person_off,
//                       size: 60,
//                       color: Colors.grey,
//                     ),
//                     SizedBox(height: 16),
//                     Text(
//                       'No doctor assigned',
//                       style: TextStyle(
//                         fontSize: 16,
//                         color: Colors.grey,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
//     }

//     final doctor = patientData.assignedDoctor!;

//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: InkWell(
//         onTap: () {
//           _showDoctorDetails(context, doctor);
//         },
//         borderRadius: BorderRadius.circular(16),
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 'Assigned Doctor',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 16),
//               Row(
//                 children: [
//                   CircleAvatar(
//                     radius: 30,
//                     backgroundImage: doctor.profileImage != null
//                         ? NetworkImage(doctor.profileImage!)
//                         : null,
//                     child: doctor.profileImage == null
//                         ? const Icon(Icons.person, size: 30)
//                         : null,
//                   ),
//                   const SizedBox(width: 16),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           doctor.name,
//                           style: const TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           doctor.specialization,
//                           style: const TextStyle(
//                             fontSize: 14,
//                             color: Colors.grey,
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           doctor.hospital,
//                           style: const TextStyle(
//                             fontSize: 14,
//                             color: Colors.grey,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
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

//   void _showDoctorDetails(BuildContext context, Doctor doctor) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) {
//         return Container(
//           padding: const EdgeInsets.all(24),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Center(
//                 child: Container(
//                   width: 60,
//                   height: 5,
//                   decoration: BoxDecoration(
//                     color: Colors.grey[300],
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 24),
//               Center(
//                 child: CircleAvatar(
//                   radius: 50,
//                   backgroundImage: doctor.profileImage != null
//                       ? NetworkImage(doctor.profileImage!)
//                       : null,
//                   child: doctor.profileImage == null
//                       ? const Icon(Icons.person, size: 50)
//                       : null,
//                 ),
//               ),
//               const SizedBox(height: 16),
//               Center(
//                 child: Text(
//                   doctor.name,
//                   style: const TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//               Center(
//                 child: Text(
//                   doctor.specialization,
//                   style: const TextStyle(
//                     fontSize: 16,
//                     color: Colors.grey,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 24),
//               const Divider(),
//               const SizedBox(height: 16),
//               _buildDoctorDetailItem(
//                   Icons.business, 'Hospital', doctor.hospital),
//               const SizedBox(height: 16),
//               _buildDoctorDetailItem(Icons.phone, 'Phone', doctor.phone),
//               const SizedBox(height: 16),
//               _buildDoctorDetailItem(Icons.email, 'Email', doctor.email),
//               const SizedBox(height: 24),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton.icon(
//                   onPressed: () {
//                     // Implement call functionality
//                     Navigator.pop(context);
//                   },
//                   icon: const Icon(Icons.phone),
//                   label: const Text('Call Doctor'),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               SizedBox(
//                 width: double.infinity,
//                 child: OutlinedButton.icon(
//                   onPressed: () {
//                     // Implement email functionality
//                     Navigator.pop(context);
//                   },
//                   icon: const Icon(Icons.email),
//                   label: const Text('Send Email'),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildDoctorDetailItem(IconData icon, String label, String value) {
//     return Row(
//       children: [
//         Icon(
//           icon,
//           color: Colors.teal,
//           size: 24,
//         ),
//         const SizedBox(width: 16),
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               label,
//               style: const TextStyle(
//                 fontSize: 14,
//                 color: Colors.grey,
//               ),
//             ),
//             Text(
//               value,
//               style: const TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }
