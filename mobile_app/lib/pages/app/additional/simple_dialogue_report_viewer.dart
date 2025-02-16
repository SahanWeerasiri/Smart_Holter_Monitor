import 'package:flutter/material.dart';
import 'package:health_care/constants/consts.dart';
import 'package:health_care/pages/app/additional/holter_graph.dart';
import 'package:health_care/pages/app/services/firestore_db_service.dart';

class DialogReport extends StatelessWidget {
  final String doctorName;
  final String doctorSpecialization;
  final String patientName;
  final String patientAge;
  final String avgHeartRate;
  final String reportId;
  final String patientId;
  final String reportDate;
  final Map<String, int> graphData;
  final String overallSummary;
  final String description;
  final String anomalyDetails;
  final String doctorSuggestions;
  final String aiSuggestions;
  final bool isNew;

  const DialogReport({
    super.key,
    required this.doctorName,
    required this.reportId,
    required this.doctorSpecialization,
    required this.patientName,
    required this.patientAge,
    required this.avgHeartRate,
    required this.patientId,
    required this.reportDate,
    required this.graphData,
    required this.overallSummary,
    required this.description,
    required this.anomalyDetails,
    required this.doctorSuggestions,
    required this.aiSuggestions,
    required this.isNew,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  Widget contentBox(context) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: Offset(0, 10),
            blurRadius: 10,
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildHeader(),
            SizedBox(height: 20),
            _buildGraph(),
            SizedBox(height: 20),
            _buildSection("Overall Summary", overallSummary),
            _buildSection("Description", description),
            _buildSection("Anomaly Details", anomalyDetails),
            _buildSection("Doctor Suggestions", doctorSuggestions),
            _buildSection("AI Second Opinion", aiSuggestions),
            SizedBox(height: 20),
            Align(
              alignment: Alignment.bottomRight,
              child: ElevatedButton(
                onPressed: () async {
                  if (isNew) {
                    await FirestoreDbService()
                        .updateReportSeen(patientId, reportId);
                  }
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: StyleSheet().btnBackground,
                  foregroundColor: StyleSheet().btnText,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: Text(isNew ? "Mark As Read" : "Close"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Medical Report",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Text("Doctor: $doctorName ($doctorSpecialization)"),
        Text("Patient: $patientName (Age: $patientAge)"),
        Text("Report ID: $reportId"),
        Text("Average Heart Rate: $avgHeartRate bpm"),
        Text("Report Date: $reportDate"),
      ],
    );
  }

  Widget _buildGraph() {
    return SizedBox(
      height: 400,
      child: graphData.isNotEmpty
          ? HolterGraph(data: graphData)
          : Center(child: Text("No graph data available")),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 5),
        Text(content),
        SizedBox(height: 15),
      ],
    );
  }
}
