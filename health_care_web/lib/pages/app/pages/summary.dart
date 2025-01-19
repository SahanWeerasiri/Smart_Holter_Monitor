import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:health_care_web/components/dialogues/simple_dialogue_profile.dart';
import 'package:health_care_web/components/list/design1/list1.dart';
import 'package:health_care_web/components/list/design1/list_item_data.dart';
import 'package:health_care_web/constants/consts.dart';
import 'package:flutter/material.dart';
import 'package:health_care_web/pages/app/services/firestore_db_service.dart';
import 'package:iconly/iconly.dart';

class Summary extends StatefulWidget {
  final User? user;
  const Summary({super.key, required this.user});

  @override
  State<Summary> createState() => _SummaryState();
}

class _SummaryState extends State<Summary> {
  final UserProfile _userProfile = UserProfile(name: "Name", email: "Email");
  final UserProfile doctorProfile = UserProfile(name: "Name", email: "Email");
  bool isLoading = true;
  int currentHeartRate = 0;
  num avgHeartRate = 0.0;
  Color stateBoxColor = StyleSheet().stateHeartBoxBad;
  @override
  void initState() {
    super.initState();
    fetchProfileData();
  }

  Future<void> fetchProfileData() async {
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> res =
        await FirestoreDbService().fetchAccount(widget.user!.uid);
    if (res['success']) {
      setState(() {
        _userProfile.name = res['data']['name'];
        _userProfile.email = res['data']['email'];
        _userProfile.address = res['data']['address'];
        _userProfile.color = res['data']['color'];
        _userProfile.device = res['data']['device'];
        _userProfile.isDone = res['data']['is_done'];
        _userProfile.language = res['data']['language'];
        _userProfile.mobile = res['data']['mobile'];
        _userProfile.pic = res['data']['pic'];
        _userProfile.doctorId = res['data']['doctor_id'];
      });
      if (res['data']['device'] != "Device") {
        fetchDeviceData(res['data']['device']);
      } else {
        setState(() {
          currentHeartRate = 0;
          avgHeartRate = 0.0;
        });
      }
      if (res['data']['doctor_id'] != "") {
        Map<String, dynamic> resDoc =
            await FirestoreDbService().fetchPatient(res['data']['doctor_id']);
        if (resDoc['success']) {
          setState(() {
            doctorProfile.name = resDoc['data']['name'];
            doctorProfile.email = resDoc['data']['email'];
            doctorProfile.address = resDoc['data']['address'];
            doctorProfile.mobile = resDoc['data']['mobile'];
            doctorProfile.pic = resDoc['data']['pic'];
          });
        }
      } else {
        setState(() {
          currentHeartRate = 0;
          avgHeartRate = 0.0;
        });
      }
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

  Future<void> fetchDeviceData(String device) async {
    final FirebaseDatabase database = FirebaseDatabase.instance;
    // Reference to the device's data
    final ref = database.ref('devices').child(device).child('data');
    // Listen for real-time updates
    ref.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (!mounted) return;

      if (data != null && data.isNotEmpty) {
        // Convert the map to a sorted list of entries (descending by timestamp)
        final sortedEntries = data.entries.toList()
          ..sort((a, b) =>
              b.key.compareTo(a.key)); // Sort by key (time_stamp) descending

        final values =
            sortedEntries.map((entry) => entry.value as num).toList();
        final avgValue = values.isNotEmpty
            ? values.reduce((a, b) => a + b) / values.length
            : 0;

        // The latest entry will now be the first
        final latestEntry = sortedEntries.first;
        setState(() {
          currentHeartRate = latestEntry.value;
          avgHeartRate = avgValue;
          if (60 <= currentHeartRate && currentHeartRate <= 100) {
            stateBoxColor = StyleSheet().stateHeartBoxGood;
          } else {
            stateBoxColor = StyleSheet().stateHeartBoxBad;
          }
        });
      } else {
        setState(() {
          currentHeartRate = 0;
          avgHeartRate = 0.0;
        });
      }
    }, onError: (error) {
      if (!mounted) return;
      setState(() {
        currentHeartRate = 0;
        avgHeartRate = 0.0;
      });
    });
  }

  Future<void> showDoctorDetails() async {
    showDialog(
      context: context,
      builder: (context) => ProfileDialogue(
        text: doctorProfile.name,
        email: doctorProfile.email,
        phone: doctorProfile.mobile,
        address: doctorProfile.address,
        basicColor: StyleSheet().uiBackground,
        fontColor: StyleSheet().doctorDetailsPopPrimary,
        subTextFontColor: StyleSheet().doctorDetailsPopPSecondary,
        btnText: "Close",
        icon: IconlyLight.profile,
        onPressed: () => {
          Navigator.of(context).pop(),
        },
      ),
    );
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

    return Padding(
      padding: EdgeInsets.all(AppSizes().getBlockSizeHorizontal(8)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                color: StyleSheet().currentHeartBox,
              ),
              width: AppSizes().getBlockSizeHorizontal(90),
              height: AppSizes().getBlockSizeVertical(20),
              child: Padding(
                padding: EdgeInsets.all(AppSizes().getBlockSizeHorizontal(5)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          "Heart Rate",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: AppSizes().getBlockSizeHorizontal(5),
                          ),
                        ),
                        Text(
                          currentHeartRate.toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: AppSizes().getBlockSizeHorizontal(17),
                          ),
                        ),
                        Text(
                          "bpm",
                          style: TextStyle(
                            fontSize: AppSizes().getBlockSizeHorizontal(4),
                          ),
                        )
                      ],
                    ),
                    Image.asset('assetes/icons/logo.png')
                  ],
                ),
              )),
          SizedBox(
            height: AppSizes().getBlockSizeVertical(2),
          ),
          Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                      width: AppSizes().getBlockSizeHorizontal(40),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        color: StyleSheet().avgHeartBox,
                      ),
                      height: AppSizes().getBlockSizeVertical(20),
                      child: Padding(
                        padding: EdgeInsets.all(
                            AppSizes().getBlockSizeHorizontal(5)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Avg Heart Rate",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: AppSizes().getBlockSizeHorizontal(5),
                              ),
                            ),
                            Text(
                              avgHeartRate.toString().split(".")[0],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: AppSizes().getBlockSizeHorizontal(17),
                              ),
                            ),
                            Text(
                              "bpm",
                              style: TextStyle(
                                fontSize: AppSizes().getBlockSizeHorizontal(4),
                              ),
                            )
                          ],
                        ),
                      )),
                  Container(
                      width: AppSizes().getBlockSizeHorizontal(40),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        color: stateBoxColor,
                      ),
                      height: AppSizes().getBlockSizeVertical(20),
                      child: Padding(
                        padding: EdgeInsets.all(
                            AppSizes().getBlockSizeHorizontal(5)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Status",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: AppSizes().getBlockSizeHorizontal(5),
                              ),
                            ),
                            Text(
                              (60 < currentHeartRate && currentHeartRate < 100)
                                  ? "Good"
                                  : "Bad",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: AppSizes().getBlockSizeHorizontal(10),
                              ),
                            ),
                          ],
                        ),
                      ))
                ],
              )),
          SizedBox(
            height: AppSizes().getBlockSizeVertical(3),
          ),
          Container(
            padding:
                EdgeInsets.only(left: AppSizes().getBlockSizeHorizontal(3)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "Assigned Doctor",
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
                  data: List.of([
                    doctorProfile.name != "Name"
                        ? ListItem1Data(
                            title: doctorProfile.name,
                            icon: IconlyLight.heart,
                            onPressed: () {
                              showDoctorDetails();
                            })
                        : ListItem1Data(
                            title: "No Doctor has assigned",
                            icon: Icons.hourglass_empty,
                            onPressed: () {}),
                  ])))
        ],
      ),
    );
  }
}
