import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:health_care_web/constants/consts.dart';
import 'package:health_care_web/pages/app/cards/expandable_profile_card.dart';
import 'package:health_care_web/pages/app/cards/mobile_home_popup.dart';
import 'package:health_care_web/pages/app/services/firestore_db_service.dart';
import 'package:iconly/iconly.dart';

class Summary extends StatefulWidget {
  const Summary({super.key});

  @override
  State<Summary> createState() => _SummaryState();
}

class _SummaryState extends State<Summary> {
  List<UserProfile> currentProfiles = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchCurrentPatients();
  }

  Future<void> fetchCurrentPatients() async {
    setState(() => isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("User is not logged in.");
      }

      Map<String, dynamic> res =
          await FirestoreDbService().fetchCurrentPatient(user.uid);

      if (res['success']) {
        setState(() {
          currentProfiles = res['data'] as List<UserProfile>;
        });
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(res['error'] ?? 'Unknown error occurred'),
              backgroundColor: Colors.red,
            ),
          );
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  void refresh() {
    setState(() {
      currentProfiles = [];
      isLoading = false;
    });
    fetchCurrentPatients();
  }

  Future<void> createReport() async {}
  Future<void> addDevice() async {}
  Future<void> removeDevice(String uid, String deviceId) async {
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> res =
        await FirestoreDbService().removeDeviceFromPatient(uid, deviceId);
    if (res['success']) {
      refresh();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('done'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['error'] ?? 'Unknown error occurred'),
          backgroundColor: Colors.red,
        ),
      );
    }
    setState(() {
      isLoading = false;
    });
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
                              color: StyleSheet().step4),
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
                              color: StyleSheet().step3),
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
                              color: StyleSheet().step2),
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
                              color: StyleSheet().step1),
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
                          device: p.device,
                          isDone: p.isDone,
                          onAddDevice: addDevice,
                          onCreateReport: createReport,
                          onPending: () {
                            pendingData(p.device);
                          },
                          onRemoveDevice: () {
                            removeDevice(p.id, p.device);
                          },
                        );
                      }).toList(),
                    ),
                  ],
                )),
          ]);
  }
}
