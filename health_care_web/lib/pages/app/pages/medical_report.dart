import 'package:flutter/material.dart';
import 'package:health_care_web/components/buttons/custom_button_1/custom_button.dart';
import 'package:health_care_web/constants/consts.dart';
import 'package:health_care_web/pages/app/additional/report/header.dart';
import 'package:health_care_web/pages/app/additional/report/section.dart';

class MedicalReport extends StatefulWidget {
  final UserProfile profile;
  final UserProfile doctor;
  final ReportModel report;
  const MedicalReport(
      {super.key,
      required this.profile,
      required this.doctor,
      required this.report});

  @override
  State<MedicalReport> createState() => _MedicalReportState();
}

class _MedicalReportState extends State<MedicalReport> {
  String selectedReport = "Report 1";
  final TextEditingController headerController = TextEditingController();
  final TextEditingController footerController = TextEditingController();
  final TextEditingController summaryController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController anomaliesController = TextEditingController();
  final TextEditingController suggestionsController = TextEditingController();
  final TextEditingController aiOpinionController = TextEditingController();

  void saveReport(controller) {
    // Handle saving logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Report Saved Successfully!")),
    );
  }

  @override
  void initState() {
    super.initState();
    summaryController.text = widget.report.brief;
    descriptionController.text = widget.report.description;
    aiOpinionController.text = widget.report.aiSuggestions;
    suggestionsController.text = widget.report.docSuggestions;
    anomaliesController.text = widget.report.anomalies;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Health Report Editor")),
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.grey[200],
              child: ListView(
                children: [
                  ListTile(
                    title: Text("Report 1"),
                    onTap: () => setState(() => selectedReport = "Report 1"),
                  ),
                  ListTile(
                    title: Text("Report 2"),
                    onTap: () => setState(() => selectedReport = "Report 2"),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  MedicalReportHeader(
                      doctorName: widget.doctor.name,
                      doctorSpecialization: widget.doctor.email,
                      patientName: widget.profile.name,
                      patientAge: 30,
                      avgHeartRate: widget.report.avgHeart,
                      patientId: widget.profile.id,
                      reportDate: DateTime.now()),
                  ReportSection(
                      title: "Overall Summary",
                      inputType: "text",
                      controller: summaryController),
                  ReportSection(
                      title: "Description",
                      inputType: "text",
                      controller: descriptionController),
                  ReportSection(
                      title: "Anomaly Details",
                      inputType: "bullet",
                      controller: anomaliesController),
                  ReportSection(
                      title: "Doctor Suggestions",
                      inputType: "numbered",
                      controller: suggestionsController),
                  ReportSection(
                      title: "AI Second Opinion",
                      inputType: "numbered",
                      controller: aiOpinionController),
                  CustomButton(
                    label: "Save Report",
                    onPressed: () {},
                    backgroundColor: StyleSheet().btnBackground,
                    textColor: StyleSheet().btnText,
                    icon: Icons.save,
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
