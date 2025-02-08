import 'package:flutter/material.dart';
import 'package:health_care_web/components/buttons/custom_button_1/custom_button.dart';
import 'package:health_care_web/constants/consts.dart';
import 'package:health_care_web/pages/additional/report/fixed_section.dart';
import 'package:health_care_web/pages/additional/report/header.dart';
import 'package:health_care_web/pages/additional/report/section.dart';
import 'package:health_care_web/pages/services/firestore_db_service.dart';

class MedicalReport extends StatefulWidget {
  final UserProfile profile;
  final UserProfile doctor;
  final ReportModel? report;
  final List<ReportModel> reportsList;
  const MedicalReport(
      {super.key,
      required this.profile,
      required this.doctor,
      required this.report,
      required this.reportsList});

  @override
  State<MedicalReport> createState() => _MedicalReportState();
}

class _MedicalReportState extends State<MedicalReport> {
  ReportModel? selectedReport;
  final TextEditingController headerController = TextEditingController();
  final TextEditingController footerController = TextEditingController();
  final TextEditingController summaryController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController anomaliesController = TextEditingController();
  final TextEditingController suggestionsController = TextEditingController();
  final TextEditingController aiOpinionController = TextEditingController();

  Future<void> saveReport(String uid) async {
    // Handle saving logic
    selectedReport!.aiSuggestions = aiOpinionController.text;
    selectedReport!.brief = summaryController.text;
    selectedReport!.description = descriptionController.text;
    selectedReport!.docSuggestions = suggestionsController.text;
    selectedReport!.anomalies = anomaliesController.text;
    selectedReport!.isEditing = false;
    selectedReport!.graph = "";
    selectedReport!.timestamp = DateTime.now().toString();

    Map<String, dynamic> res =
        await FirestoreDbService().saveReport(uid, selectedReport!);
    if (res['success']) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['message']),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['message']),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> saveDraftReport(String uid) async {
    // Handle saving logic
    selectedReport!.aiSuggestions = aiOpinionController.text;
    selectedReport!.brief = summaryController.text;
    selectedReport!.description = descriptionController.text;
    selectedReport!.docSuggestions = suggestionsController.text;
    selectedReport!.anomalies = anomaliesController.text;
    selectedReport!.isEditing = false;
    selectedReport!.graph = "";
    selectedReport!.timestamp = DateTime.now().toString();

    Map<String, dynamic> res =
        await FirestoreDbService().saveReportData(uid, selectedReport!);
    if (res['success']) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['message']),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['message']),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.report != null) {
      selectedReport = widget.report;
      summaryController.text = widget.report!.brief;
      descriptionController.text = widget.report!.description;
      aiOpinionController.text = widget.report!.aiSuggestions;
      suggestionsController.text = widget.report!.docSuggestions;
      anomaliesController.text = widget.report!.anomalies;
      widget.reportsList.add(widget.report!);
    }
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
              color: StyleSheet().uiBackground,
              child: ListView(
                children: widget.reportsList.isNotEmpty
                    ? widget.reportsList.map((r) {
                        return Container(
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            color: selectedReport != null &&
                                    selectedReport!.reportId == r.reportId
                                ? StyleSheet().btnBackground
                                : StyleSheet().uiBackground,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Icon(
                                Icons.history,
                                color: selectedReport == null ||
                                        selectedReport!.reportId != r.reportId
                                    ? StyleSheet().btnBackground
                                    : StyleSheet().uiBackground,
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${r.brief.length > 15 ? r.brief.substring(0, 15) : r.brief}...',
                                    style: TextStyle(
                                      color: selectedReport == null ||
                                              selectedReport!.reportId !=
                                                  r.reportId
                                          ? StyleSheet().btnBackground
                                          : StyleSheet().uiBackground,
                                    ),
                                  ),
                                  Text(
                                    r.timestamp,
                                    style: TextStyle(
                                      color: selectedReport == null ||
                                              selectedReport!.reportId !=
                                                  r.reportId
                                          ? StyleSheet().btnBackground
                                          : StyleSheet().uiBackground,
                                    ),
                                  ),
                                ],
                              ),
                              IconButton(
                                  onPressed: () {
                                    setState(() {
                                      selectedReport = r;
                                    });
                                  },
                                  icon: Icon(
                                    Icons.check,
                                    color: selectedReport == null ||
                                            selectedReport!.reportId !=
                                                r.reportId
                                        ? StyleSheet().btnBackground
                                        : StyleSheet().uiBackground,
                                  ))
                            ],
                          ),
                        );
                      }).toList()
                    : [Text("No reports available")],
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: selectedReport != null && selectedReport!.isEditing
                    ? [
                        MedicalReportHeader(
                            doctorName: selectedReport!.docName,
                            doctorSpecialization: selectedReport!.docEmail,
                            patientName: widget.profile.name,
                            patientAge: selectedReport!.age,
                            avgHeartRate: widget.report!.avgHeart,
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            CustomButton(
                              label: "Save Report",
                              onPressed: () async {
                                await saveReport(widget.profile.id);
                              },
                              backgroundColor: StyleSheet().btnBackground,
                              textColor: StyleSheet().btnText,
                              icon: Icons.save,
                            ),
                            CustomButton(
                              label: "Save Darft",
                              onPressed: () async {
                                await saveDraftReport(widget.profile.id);
                              },
                              backgroundColor: StyleSheet().btnBackground,
                              textColor: StyleSheet().btnText,
                              icon: Icons.save,
                            ),
                          ],
                        )
                      ]
                    : selectedReport != null && !selectedReport!.isEditing
                        ? [
                            MedicalReportHeader(
                                doctorName: selectedReport!.docName,
                                doctorSpecialization: selectedReport!.docEmail,
                                patientName: widget.profile.name,
                                patientAge: selectedReport!.age,
                                avgHeartRate: selectedReport!.avgHeart,
                                patientId: widget.profile.id,
                                reportDate: DateTime.now()),
                            FixedSection(
                                title: "Overall Summary",
                                text: selectedReport!.brief),
                            FixedSection(
                                title: "Description",
                                text: selectedReport!.description),
                            FixedSection(
                                title: "Anomaly Details",
                                text: selectedReport!.anomalies),
                            FixedSection(
                                title: "Doctor Suggestions",
                                text: selectedReport!.docSuggestions),
                            FixedSection(
                                title: "AI Second Opinion",
                                text: selectedReport!.aiSuggestions),
                          ]
                        : [Text("Select a Report")],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
