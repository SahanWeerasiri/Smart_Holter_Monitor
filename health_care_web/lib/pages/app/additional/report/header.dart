import 'package:flutter/material.dart';
import 'package:health_care_web/constants/consts.dart';

class MedicalReportHeader extends StatelessWidget {
  final String doctorName;
  final String doctorSpecialization;
  final String patientName;
  final int patientAge;
  final String patientId;
  final DateTime reportDate;
  final String avgHeartRate;

  const MedicalReportHeader({
    super.key,
    required this.doctorName,
    required this.doctorSpecialization,
    required this.patientName,
    required this.patientAge,
    required this.patientId,
    required this.reportDate,
    required this.avgHeartRate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 100,
              height: 100,
              child: Image.asset(
                'assetes/icons/logo.png', // Assuming `img` is a String path to an asset
              ),
            ),
            Text("Smart Care - Health Report",
                style: TextStyle(
                  color: StyleSheet().titleText,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                )),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  doctorName,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  doctorSpecialization,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ],
            ),
          ],
        ),
        Divider(thickness: 1, color: Colors.grey[400]),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Patient: $patientName",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text("Age: $patientAge"),
                ],
              ),
              Text(
                "Avg Heart Rate: $avgHeartRate",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Text(
                "Date: ${reportDate.toLocal().toString().split(' ')[0]}",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Divider(thickness: 1, color: Colors.grey[400]),
      ],
    );
  }
}
