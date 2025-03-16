// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:health_care/components/list/design1/list1.dart';
// import 'package:health_care/components/list/design1/list_item_data.dart';
// import 'package:health_care/constants/consts.dart';
import 'package:flutter/material.dart';
import 'package:health_care/models/report.dart';
import 'package:health_care/models/user.dart';
import 'package:health_care/pages/app/additional/simple_dialogue_report_viewer.dart';
import 'package:health_care/pages/app/services/firestore_db_service.dart';
import 'package:health_care/pages/screens/report_detail_screen.dart';
// import 'package:iconly/iconly.dart';
import 'package:intl/intl.dart';

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
            )
        //
        // text: "Report",
        // reportModel: report,
        // basicColor: StyleSheet().uiBackground,
        // fontColor: StyleSheet().doctorDetailsPopPrimary,
        // subTextFontColor: StyleSheet().doctorDetailsPopPSecondary,
        // onPressed: () {
        //   FirestoreDbService()
        //       .updateReportSeen(widget.user!.uid, report.reportId);
        //   setState(() {
        //     _newReportList.clear();
        //     _oldReportList.clear();
        //   });
        //   fetchReports();
        //   Navigator.pop(context);
        // },
        // btnText: "Mark As Read",
        // btnBackColor: StyleSheet().btnBackground,
        // btnTextColor: StyleSheet().btnText,

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
            )
        // text: "Report",
        // reportModel: report,
        // basicColor: StyleSheet().uiBackground,
        // fontColor: StyleSheet().doctorDetailsPopPrimary,
        // subTextFontColor: StyleSheet().doctorDetailsPopPSecondary,
        // onPressed: () {
        //   Navigator.pop(context);
        // },
        // btnBackColor: StyleSheet().btnBackground,
        // btnTextColor: StyleSheet().btnText,
        );
  }

  @override
  void initState() {
    super.initState();
    Account().initialize();
    patient = Account.instance;
    print(patient.uid);
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

    if (patient.uid.isNotEmpty && patient.reports.isEmpty) {
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
        ...patient.reports
            .map((report) => _buildReportCard(context, report as Report)),
      ],
    );
  }

  Widget _buildReportCard(BuildContext context, Report report) {
    final dateFormat = DateFormat('MMM dd, yyyy');

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
              builder: (context) => ReportDetailScreen(report: report),
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
                      report.title,
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
                    dateFormat.format(report.date),
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


  // @override
  // Widget build(BuildContext context) {
  //   AppSizes().initSizes(context);

  //   if (isLoading) {
  //     return Center(
  //         child: CircularProgressIndicator(
  //       color: StyleSheet().btnBackground,
  //       backgroundColor: StyleSheet().uiBackground,
  //     ));
  //   }

  //   return Center(
  //       child: Container(
  //           color: StyleSheet().uiBackground,
  //           padding: EdgeInsets.all(AppSizes().getBlockSizeHorizontal(5)),
  //           child: Column(
  //             children: [
  //               Container(
  //                 padding: EdgeInsets.only(
  //                     left: AppSizes().getBlockSizeHorizontal(3)),
  //                 child: Row(
  //                   mainAxisAlignment: MainAxisAlignment.start,
  //                   children: [
  //                     Text(
  //                       "Latest Report",
  //                       style: TextStyle(
  //                         fontWeight: FontWeight.bold,
  //                         fontSize: 15,
  //                       ),
  //                     )
  //                   ],
  //                 ),
  //               ),
  //               Expanded(
  //                   child: List1(
  //                       color: StyleSheet().uiBackground,
  //                       data: _newReportList.map((report) {
  //                         return ListItem1Data(
  //                             title: truncateString(report['report']['brief']),
  //                             icon: IconlyLight.document,
  //                             onPressed: () {
  //                               showReport(report);
  //                             });
  //                       }).toList())),
  //               Container(
  //                 padding: EdgeInsets.only(
  //                     left: AppSizes().getBlockSizeHorizontal(3)),
  //                 child: Row(
  //                   mainAxisAlignment: MainAxisAlignment.start,
  //                   children: [
  //                     Text(
  //                       "Old Reports",
  //                       style: TextStyle(
  //                         fontWeight: FontWeight.bold,
  //                         fontSize: 15,
  //                       ),
  //                     )
  //                   ],
  //                 ),
  //               ),
  //               Expanded(
  //                   child: List1(
  //                       color: StyleSheet().uiBackground,
  //                       data: _oldReportList.map((report) {
  //                         return ListItem1Data(
  //                             title: truncateString(report['report']['brief']),
  //                             icon: IconlyLight.document,
  //                             onPressed: () {
  //                               showOldReport(report);
  //                             });
  //                       }).toList())),
  //             ],
  //           )));
  // }
