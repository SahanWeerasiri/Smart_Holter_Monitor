import 'package:flutter/material.dart';
import 'package:health_care_web/app/components/cards/expandable_profile_card.dart';
import 'package:health_care_web/app/components/cards/mobile_home_popup.dart';
import 'package:health_care_web/app/components/report/holter_graph.dart';
import 'package:health_care_web/models/app_sizes.dart';
import 'package:health_care_web/models/doctor_profile_model.dart';
import 'package:health_care_web/models/holter_data.dart';
import 'package:health_care_web/models/patient_profile_model.dart';
import 'package:health_care_web/models/report_model.dart';
import 'package:health_care_web/models/style_sheet.dart';
import 'package:health_care_web/services/util.dart';
import 'package:iconly/iconly.dart';

class Summary extends StatefulWidget {
  const Summary({super.key});

  @override
  State<Summary> createState() => _SummaryState();
}

class _SummaryState extends State<Summary> {
  List<PatientProfileModel> currentProfiles = [];
  bool isLoading = false;
  late DoctorProfileModel doctor;

  @override
  void initState() {
    super.initState();
    fetchCurrentPatients();
  }

  

  Future<void> fetchCurrentPatients() async {
    setState(() => isLoading = true);

    doctor = DoctorProfileModel(id: "", name: "",  email: "");
    doctor = await doctor.initDoctor(context);

    List<PatientProfileModel> res = await doctor.fetchCurrentPatient(context);

      setState(() {
        currentProfiles = res;
      });

    setState(() => isLoading = false);    
  }

  void refresh() {
    setState(() {
      currentProfiles = [];
      isLoading = false;
    });
    fetchCurrentPatients();
  }



  

  Future<void> pendingData(String device) async {
    showDialog(
        context: context,
        builder: (context) => MobileHomePopup(device: device));
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    AppSizes().initSizes(context);
    return currentProfiles.isEmpty
        ? Padding(
            padding: const EdgeInsets.all(16.0),
            child: const Center(
              child: Text(
                "No profiles available",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ))
        : Column(mainAxisAlignment: MainAxisAlignment.start, children: [
            SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  spacing: 10,
                  children: [
                    Row(
                      spacing: 20,
                      children: [
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(
                                Radius.circular(12),
                              ),
                              color: StyleSheet.step4),
                          child: Row(
                            spacing: 3,
                            children: [
                              Icon(IconlyLight.document),
                              Text("Report creation")
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(
                                Radius.circular(12),
                              ),
                              color: StyleSheet.step3),
                          child: Row(
                            spacing: 3,
                            children: [
                              Icon(Icons.done),
                              Text("Monitoring is done")
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(
                                Radius.circular(12),
                              ),
                              color: StyleSheet.step2),
                          child: Row(
                            spacing: 3,
                            children: [
                              Icon(IconlyLight.time_square),
                              Text("Pending"),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(
                                Radius.circular(12),
                              ),
                              color: StyleSheet.step1),
                          child: Row(
                            spacing: 3,
                            children: [
                              Icon(Icons.device_unknown),
                              Text("Device is not connected"),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Container(
                      height: 300,
                      width: double.infinity,
                      padding: EdgeInsets.all(16),
                      child: HolterGraph(
                        data: {
                          '2025-02-11 19:58:00': 3092,
                          '2025-02-11 19:58:01': 1874,
                          '2025-02-11 19:58:02': 395,
                          '2025-02-11 19:58:03': 2781,
                          '2025-02-11 19:58:04': 1420,
                          '2025-02-11 19:58:05': 3689,
                          '2025-02-11 19:58:06': 2034,
                          '2025-02-11 19:58:07': 412,
                          '2025-02-11 19:58:08': 3748,
                          '2025-02-11 19:58:09': 2560,
                          '2025-02-11 19:58:10': 981,
                          '2025-02-11 19:58:11': 3175,
                          '2025-02-11 19:58:12': 145,
                          '2025-02-11 19:58:13': 2934,
                          '2025-02-11 19:58:14': 2217,
                        }.entries.map((entry) => HolterData(DateTime.parse(entry.key), entry.value)).toList(),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: currentProfiles.map((p) {
                        return ExpandableProfileCard(
                          name: p.name,
                          profilePic: p.pic,
                          email: p.email,
                          address: p.address,
                          mobile: p.mobile,
                          device: p.deviceId,
                          isDone: p.isDone,
                          contactProfiles: p.contacts,
                          onViewReport: () async{
                            setState(() {
                              isLoading = true;
                            });
                            List<ReportModel>? res = await doctor.viewReports(p,context);
                            if(res==null){
                              showMessages(false, "No reports found", context);
                            }
                            setState(() {
                              isLoading = false;
                            });
                            if(res!=null){
                              Navigator.pushNamed(context, '/medical_report', arguments: {'doctor': doctor, 'report': null, 'reportsList': res}).then(
                                (value) => refresh(),
                              );
                            }
                          },
                          onCreateReport: () async{
                            setState(() {
                              isLoading = true;
                            });
                            AiReport res = await doctor.createReport(p,context);
                            if(!res.state){
                              setState(() {
                                isLoading = false;
                              });
                            }
                            if(res.state){
                              setState(() {
                                isLoading = false;
                              });
                              Navigator.pushNamed(context, '/medical_report', arguments: {'doctor': doctor, 'report': res.report, 'reportsList': res.reports}).then(
                                (value) => refresh(),
                              );
                            }
                          },
                          onPending: (){
                            pendingData(p.deviceId);
                          },
                          onRemoveDevice: () async{
                            setState(() {
                              isLoading = true;
                            });
                            await doctor.removeDevice(p.toPatientReportModel(), p.device!.code, context);
                            setState(() {
                              isLoading = false;
                              refresh();
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                )),
          ]);
  }
}
