import 'package:firebase_auth/firebase_auth.dart';
import 'package:health_care/components/list/design1/list1.dart';
import 'package:health_care/components/list/design1/list_item_data.dart';
import 'package:health_care/constants/consts.dart';
import 'package:flutter/material.dart';
import 'package:health_care/pages/app/additional/simple_dialogue_report_viewer.dart';
import 'package:health_care/pages/app/services/firestore_db_service.dart';
import 'package:iconly/iconly.dart';

class ReportList extends StatefulWidget {
  final User? user;
  const ReportList({super.key, required this.user});

  @override
  State<ReportList> createState() => _ReportListState();
}

class _ReportListState extends State<ReportList> {
  final List<Map<String, dynamic>> _oldReportList = [];
  final List<Map<String, dynamic>> _newReportList = [];
  bool isLoading = true;

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
    fetchReports();
  }

  Future<void> fetchReports() async {
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> res =
        await FirestoreDbService().fetchReportsV2(widget.user!.uid);
    if (res['success']) {
      setState(() {
        for (Map<String, dynamic> dataModel
            in res['data_new'] as List<Map<String, dynamic>>) {
          _newReportList.add(dataModel);
        }
        for (Map<String, dynamic> dataModel
            in res['data_old'] as List<Map<String, dynamic>>) {
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
    AppSizes().initSizes(context);

    if (isLoading) {
      return Center(
          child: CircularProgressIndicator(
        color: StyleSheet().btnBackground,
        backgroundColor: StyleSheet().uiBackground,
      ));
    }

    return Center(
        child: Container(
            color: StyleSheet().uiBackground,
            padding: EdgeInsets.all(AppSizes().getBlockSizeHorizontal(5)),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.only(
                      left: AppSizes().getBlockSizeHorizontal(3)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Latest Report",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      )
                    ],
                  ),
                ),
                Expanded(
                    child: List1(
                        color: StyleSheet().uiBackground,
                        data: _newReportList.map((report) {
                          return ListItem1Data(
                              title: truncateString(report['report']['brief']),
                              icon: IconlyLight.document,
                              onPressed: () {
                                showReport(report);
                              });
                        }).toList())),
                Container(
                  padding: EdgeInsets.only(
                      left: AppSizes().getBlockSizeHorizontal(3)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Old Reports",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      )
                    ],
                  ),
                ),
                Expanded(
                    child: List1(
                        color: StyleSheet().uiBackground,
                        data: _oldReportList.map((report) {
                          return ListItem1Data(
                              title: truncateString(report['report']['brief']),
                              icon: IconlyLight.document,
                              onPressed: () {
                                showOldReport(report);
                              });
                        }).toList())),
              ],
            )));
  }
}
