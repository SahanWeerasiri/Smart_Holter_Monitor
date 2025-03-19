import 'package:flutter/material.dart';
import 'package:health_care/models/report.dart';
import 'package:health_care/models/user.dart';
import 'package:health_care/pages/app/additional/simple_dialogue_report_viewer.dart';
import 'package:health_care/pages/app/services/firestore_db_service.dart';
import 'package:health_care/pages/screens/report_detail_screen.dart';

class ReportList extends StatefulWidget {
  const ReportList({super.key});

  @override
  State<ReportList> createState() => _ReportListState();
}

class _ReportListState extends State<ReportList> {
  Account patient = Account.instance;
  final List<Map<String, dynamic>> _oldReportList = [];
  final List<Map<String, dynamic>> _newReportList = [];
  bool isLoading = true;
  String msg = "";
  bool state = false;

  Future<void> showReport(Map<String, dynamic> dataModel) async {
    showDialog(
      context: context,
      builder: (context) => DialogReport(
        reportId: dataModel['report']['reportId'],
        aiSuggestions: dataModel['report']['aiSuggestions'],
        anomalyDetails: dataModel['report']['anomalies'],
        overallSummary: dataModel['report']['brief'],
        description: dataModel['report']['description'],
        doctorName: dataModel['doctor']['doctorName'],
        doctorSpecialization: dataModel['doctor']['doctorEmail'],
        patientAge: dataModel['patient']['age'],
        patientId: dataModel['patient']['id'],
        patientName: dataModel['patient']['name'],
        avgHeartRate: dataModel['report']['avgHeart'],
        doctorSuggestions: dataModel['report']['docSuggestions'],
        reportDate: dataModel['report']['timestamp'],
        graphData: dataModel['data'],
        isNew: true,
      ),
    );
  }

  Future<void> showOldReport(Map<String, dynamic> dataModel) async {
    showDialog(
      context: context,
      builder: (context) => DialogReport(
        reportId: dataModel['report']['reportId'],
        aiSuggestions: dataModel['report']['aiSuggestions'],
        anomalyDetails: dataModel['report']['anomalies'],
        overallSummary: dataModel['report']['brief'],
        description: dataModel['report']['description'],
        doctorName: dataModel['doctor']['doctorName'],
        doctorSpecialization: dataModel['doctor']['doctorEmail'],
        patientAge: dataModel['patient']['age'],
        patientId: dataModel['patient']['id'],
        patientName: dataModel['patient']['name'],
        avgHeartRate: dataModel['report']['avgHeart'],
        doctorSuggestions: dataModel['report']['docSuggestions'],
        reportDate: dataModel['report']['timestamp'],
        graphData: dataModel['data'],
        isNew: false,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    Account().initialize();
    patient = Account.instance;
    fetchReports();
  }

  Future<void> fetchReports() async {
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> res =
        await FirestoreDbService().fetchReportsV2(patient.uid);
    if (res['success']) {
      setState(() {
        _newReportList.clear();
        _oldReportList.clear();
        for (Map<String, dynamic> dataModel in res['data_new']) {
          _newReportList.add(dataModel);
        }
        for (Map<String, dynamic> dataModel in res['data_old']) {
          _oldReportList.add(dataModel);
        }
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['error']),
            backgroundColor: Colors.red,
          ),
        );
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  String truncateString(String input) {
    return input.length > 25 ? '${input.substring(0, 25)}...' : input;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (msg.isNotEmpty && !state) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              'Error: $msg',
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                patient = Account.instance;
                fetchReports();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (patient.uid.isNotEmpty &&
        _newReportList.isEmpty &&
        _oldReportList.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description_outlined,
              color: Colors.grey,
              size: 80,
            ),
            SizedBox(height: 16),
            Text(
              'No reports available',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Your Reports',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        if (_newReportList.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'New Reports',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ..._newReportList
                  .map((report) => _buildReportCard(context, report)),
            ],
          ),
        if (_oldReportList.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const Text(
                'Old Reports',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ..._oldReportList
                  .map((report) => _buildReportCard(context, report)),
            ],
          ),
      ],
    );
  }

  Widget _buildReportCard(
      BuildContext context, Map<String, dynamic> reportData) {
    print("all good");

    final report = Report.fromMap(reportData['report']);
    final patient = Account.fromMap(reportData['patient']);
    final doctor = ReportDoctor.fromMap(reportData['doctor']);
    FirestoreDbService().updateReportSeen(patient.uid, report.reportId);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReportDetailScreen(
                  report: report, patient: patient, doctor: doctor),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.description,
                    color: Colors.teal,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "General Report - ${report.timestamp}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    color: Colors.grey,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    report.timestamp,
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey,
                    size: 16,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
