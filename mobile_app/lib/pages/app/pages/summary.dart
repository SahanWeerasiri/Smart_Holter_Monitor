// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
// import 'package:health_care/components/buttons/custom_button_1/custom_button.dart';
import 'package:health_care/components/dialogues/simple_dialogue_profile.dart';
// import 'package:health_care/components/list/design1/list1.dart';
// import 'package:health_care/components/list/design1/list_item_data.dart';
import 'package:health_care/constants/consts.dart';
import 'package:flutter/material.dart';
import 'package:health_care/models/user.dart';
// import 'package:health_care/pages/app/services/firestore_db_service.dart';
// import 'package:iconly/iconly.dart';
// import 'package:url_launcher/url_launcher.dart';

class Summary extends StatefulWidget {
  const Summary({super.key});

  @override
  State<Summary> createState() => _SummaryState();
}

class _SummaryState extends State<Summary> {
  Account patient = Account.instance;
  bool isLoading =
      true; // Start with isLoading true to show a loading indicator
  int currentHeartRate = 0;
  num avgHeartRate = 0.0;
  Color stateBoxColor = StyleSheet().stateHeartBoxBad;
  String msg = "";
  bool state = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() {
      isLoading = true;
    });

    await patient.initialize(); // Wait for the account data to be initialized

    setState(() {
      isLoading = false;
    });

    fetchDeviceData(patient.deviceId);
  }

  // Future<void> fetchProfileData() async {
  //   setState(() {
  //     isLoading = true;
  //   });
  //   Map<String, dynamic> res =
  //       await FirestoreDbService().fetchAccount(widget.user!.uid);
  //   if (res['success']) {
  //     setState(() {
  //       _userProfile.name = res['data']['name'];
  //       _userProfile.email = res['data']['email'];
  //       _userProfile.address = res['data']['address'];
  //       _userProfile.color = res['data']['color'];
  //       _userProfile.device = res['data']['deviceId'];
  //       _userProfile.isDone = res['data']['isDone'];
  //       _userProfile.language = res['data']['language'];
  //       _userProfile.mobile = res['data']['mobile'];
  //       _userProfile.pic = res['data']['pic'];
  //       _userProfile.birthday = res['data']['birthday'] ?? "";
  //       _userProfile.doctorId = res['data']['docId'];
  //     });
  //     if (res['data']['deviceId'] != "Device") {
  //       fetchDeviceData(res['data']['deviceId']);
  //     } else {
  //       setState(() {
  //         currentHeartRate = 0;
  //         avgHeartRate = 0.0;
  //       });
  //     }
  //     if (res['data']['doctor_id'] != "") {
  //       Map<String, dynamic> resDoc =
  //           await FirestoreDbService().fetchDoctor(res['data']['docId']);
  //       if (resDoc['success']) {
  //         setState(() {
  //           doctorProfile.name = resDoc['data']['name'];
  //           doctorProfile.email = resDoc['data']['email'];
  //           doctorProfile.address = resDoc['data']['address'];
  //           doctorProfile.mobile = resDoc['data']['mobile'];
  //           doctorProfile.pic = resDoc['data']['pic'];
  //         });
  //       }
  //     } else {
  //       setState(() {
  //         currentHeartRate = 0;
  //         avgHeartRate = 0.0;
  //       });
  //     }
  //   } else {
  //     WidgetsBinding.instance.addPostFrameCallback((_) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text(res['error']),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //     });
  //   }
  //   setState(() {
  //     isLoading = false;
  //   });
  // }

  Future<void> fetchDeviceData(String device) async {
    final FirebaseDatabase database = FirebaseDatabase.instance;
    // Reference to the device's data
    final ref = database.ref('devices').child(device).child('beats');

    // Listen for real-time updates
    ref.onValue.listen((DatabaseEvent event) {
      if (!mounted) return;

      // Safely handle the snapshot value
      final data = event.snapshot.value;

      if (data is List) {
        // Filter out null values and ensure each item is a Map
        final validData = data.whereType<Map<dynamic, dynamic>>().toList();

        if (validData.isNotEmpty) {
          // Sort the list by timestamp in descending order
          validData.sort((a, b) {
            final timestampA = a['timestamp'] as String? ?? '';
            final timestampB = b['timestamp'] as String? ?? '';
            return timestampB.compareTo(timestampA); // Descending order
          });

          // Create a map of timestamp to value
          final Map<String, int> testMap = {};
          for (final entry in validData) {
            final timestamp = entry['timestamp'] as String? ?? '';
            final value = entry['value'] as int? ?? 0;
            testMap[timestamp] = value;
          }

          // Sort the map by timestamp in ascending order
          final sortedMap = Map.fromEntries(
            testMap.entries.toList()
              ..sort((a, b) =>
                  DateTime.parse(a.key).compareTo(DateTime.parse(b.key))),
          );
          // Calculate the current heart rate and average heart rate
          final currentHeartRate = sortedMap.values.last;
          final avgHeartRate = currentHeartRate + 2; // Example calculation

          // Update the state
          setState(() {
            this.currentHeartRate = currentHeartRate;
            this.avgHeartRate = avgHeartRate;
            if (60 <= currentHeartRate && currentHeartRate <= 100) {
              stateBoxColor = StyleSheet().stateHeartBoxGood;
            } else {
              stateBoxColor = StyleSheet().stateHeartBoxBad;
            }
          });
        } else {
          // If no valid data is available, reset the values
          setState(() {
            currentHeartRate = 0;
            avgHeartRate = 0.0;
          });
        }
      } else {
        // If the data is not a List, reset the values
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

    final ref2 = database.ref('devices').child(device).child('isDone');

    // Listen for real-time updates
    ref2.onValue.listen((DatabaseEvent event) {
      if (!mounted) return;

      // Safely handle the snapshot value
      final data = event.snapshot.value as bool;
      if (data) {
        setState(() {
          patient.deviceState = true;
        });
      } else {
        setState(() {
          patient.deviceState = false;
        });
      }
    }, onError: (error) {
      if (!mounted) return;
    });
  }

  Future<void> showDoctorDetails() async {
    showDialog(
      context: context,
      builder: (context) => ProfileDialogue(
        name: patient.doctorName,
        email: patient.doctorEmail,
        phone: patient.doctorMobile,
        address: patient.doctorAddress,
        imageUrl: patient.doctorImageURL,
        specialization: "",
      ),
    );
  }

  // @override
  // void initState() {
  //   super.initState,
  //       email: doctorProfile.email,
  //       phone: doctorProfile.mobile,
  //       address: doctorProfile.address,
  //       imageUrl: doctorProfile.pic,
  //       specialization: "",
  //     ),
  //   );
  // }
  @override
  Widget build(BuildContext context) {
    final patientData = Account.instance;

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
                setState(() {
                  patient = Account.instance;
                });
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // if (patient == null) {
    //   return const Center(
    //     child: Text('No data available'),
    //   );
    // }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Heart Health Summary',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          _buildHeartRateCard(patientData),
          const SizedBox(height: 24),
          _buildDoctorCard(context, patientData),
        ],
      ),
    );
  }

  Widget _buildHeartRateCard(Account patientData) {
    Color statusColor;
    IconData statusIcon;

    // switch (patientData.deviceState) {
    //   case 'good':
    //     statusColor = Colors.green;
    //     statusIcon = Icons.check_circle;
    //     break;
    //   case 'moderate':
    //     statusColor = Colors.orange;
    //     statusIcon = Icons.warning;
    //     break;
    //   case 'bad':
    //     statusColor = Colors.red;
    //     statusIcon = Icons.error;
    //     break;
    //   default:
    //     statusColor = Colors.grey;
    //     statusIcon = Icons.help;
    // }

    if (patientData.deviceState) {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
    } else {
      statusColor = Colors.orange;
      statusIcon = Icons.monitor;
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildHeartRateItem(
                    'Heart Rate (BPM)',
                    currentHeartRate.toString(),
                    Icons.favorite,
                    Colors.red,
                  ),
                ),
                // const SizedBox(width: 16),
                // Expanded(
                //   child: _buildHeartRateItem(
                //     'Average BPM',
                //     avgHeartRate.toString(),
                //     Icons.favorite_border,
                //     Colors.red,
                //   ),
                // ),
              ],
            ),
            const Divider(height: 32),
            Row(
              children: [
                Icon(
                  statusIcon,
                  color: statusColor,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Status',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        patientData.deviceState
                            ? 'Completed'
                            : 'Still Monitoring',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeartRateItem(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 40,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildDoctorCard(BuildContext context, Account patientData) {
    if (patientData.docId.isEmpty) {
      return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Assigned Doctor',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_off,
                      size: 60,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No doctor assigned',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          _showDoctorDetails(context);
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Assigned Doctor',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: patient.doctorImageURL != null
                        ? NetworkImage(patient.doctorImageURL)
                        : null,
                    child: patient.doctorImageURL == null
                        ? const Icon(Icons.person, size: 30)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          patient.doctorName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          patient.doctorMobile,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          patient.hoispitalName,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
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

  void _showDoctorDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 60,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: patient.doctorImageURL != null
                      ? NetworkImage(patient.doctorImageURL)
                      : null,
                  child: patient.doctorImageURL == null
                      ? const Icon(Icons.person, size: 50)
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  patient.doctorName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Center(
              //   child: Text(
              //     patient.docId,
              //     style: const TextStyle(
              //       fontSize: 16,
              //       color: Colors.grey,
              //     ),
              //   ),
              // ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              _buildDoctorDetailItem(
                  Icons.business, 'Hospital', patient.hoispitalName),
              const SizedBox(height: 16),
              _buildDoctorDetailItem(
                  Icons.phone, 'Phone', patient.doctorMobile),
              const SizedBox(height: 16),
              _buildDoctorDetailItem(Icons.email, 'Email', patient.doctorEmail),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Implement call functionality
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.phone),
                  label: const Text('Call Doctor'),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Implement email functionality
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.email),
                  label: const Text('Send Email'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDoctorDetailItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.teal,
          size: 24,
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
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

  //   return Padding(
  //     padding: EdgeInsets.all(AppSizes().getBlockSizeHorizontal(8)),
  //     child: Column(
  //       mainAxisAlignment: MainAxisAlignment.start,
  //       crossAxisAlignment: CrossAxisAlignment.center,
  //       children: [
  //         Container(
  //             decoration: BoxDecoration(
  //               borderRadius: BorderRadius.all(Radius.circular(10)),
  //               color: StyleSheet().currentHeartBox,
  //             ),
  //             width: AppSizes().getBlockSizeHorizontal(90),
  //             height: AppSizes().getBlockSizeVertical(20),
  //             child: Padding(
  //               padding: EdgeInsets.all(AppSizes().getBlockSizeHorizontal(5)),
  //               child: Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //                 crossAxisAlignment: CrossAxisAlignment.center,
  //                 children: [
  //                   Column(
  //                     mainAxisAlignment: MainAxisAlignment.spaceAround,
  //                     children: [
  //                       Text(
  //                         "Heart Rate",
  //                         style: TextStyle(
  //                           fontWeight: FontWeight.bold,
  //                           fontSize: AppSizes().getBlockSizeHorizontal(5),
  //                         ),
  //                       ),
  //                       Text(
  //                         currentHeartRate.toString(),
  //                         style: TextStyle(
  //                           fontWeight: FontWeight.bold,
  //                           fontSize: AppSizes().getBlockSizeHorizontal(17),
  //                         ),
  //                       ),
  //                       Text(
  //                         "bpm",
  //                         style: TextStyle(
  //                           fontSize: AppSizes().getBlockSizeHorizontal(4),
  //                         ),
  //                       )
  //                     ],
  //                   ),
  //                   Image.asset('assetes/icons/logo.png')
  //                 ],
  //               ),
  //             )),
  //         SizedBox(
  //           height: AppSizes().getBlockSizeVertical(2),
  //         ),
  //         Container(
  //             decoration: BoxDecoration(
  //               borderRadius: BorderRadius.all(Radius.circular(10)),
  //             ),
  //             child: Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //               crossAxisAlignment: CrossAxisAlignment.center,
  //               children: [
  //                 Container(
  //                     width: AppSizes().getBlockSizeHorizontal(40),
  //                     decoration: BoxDecoration(
  //                       borderRadius: BorderRadius.all(Radius.circular(10)),
  //                       color: StyleSheet().avgHeartBox,
  //                     ),
  //                     height: AppSizes().getBlockSizeVertical(20),
  //                     child: Padding(
  //                       padding: EdgeInsets.all(
  //                           AppSizes().getBlockSizeHorizontal(5)),
  //                       child: Column(
  //                         mainAxisAlignment: MainAxisAlignment.center,
  //                         children: [
  //                           Text(
  //                             "Avg Heart Rate",
  //                             style: TextStyle(
  //                               fontWeight: FontWeight.bold,
  //                               fontSize: AppSizes().getBlockSizeHorizontal(5),
  //                             ),
  //                           ),
  //                           Text(
  //                             avgHeartRate.toString().split(".")[0],
  //                             style: TextStyle(
  //                               fontWeight: FontWeight.bold,
  //                               fontSize: AppSizes().getBlockSizeHorizontal(17),
  //                             ),
  //                           ),
  //                           Text(
  //                             "bpm",
  //                             style: TextStyle(
  //                               fontSize: AppSizes().getBlockSizeHorizontal(4),
  //                             ),
  //                           )
  //                         ],
  //                       ),
  //                     )),
  //                 Container(
  //                     width: AppSizes().getBlockSizeHorizontal(40),
  //                     decoration: BoxDecoration(
  //                       borderRadius: BorderRadius.all(Radius.circular(10)),
  //                       color: stateBoxColor,
  //                     ),
  //                     height: AppSizes().getBlockSizeVertical(20),
  //                     child: Padding(
  //                       padding: EdgeInsets.all(
  //                           AppSizes().getBlockSizeHorizontal(5)),
  //                       child: Column(
  //                         mainAxisAlignment: MainAxisAlignment.center,
  //                         children: [
  //                           Text(
  //                             "Status",
  //                             style: TextStyle(
  //                               fontWeight: FontWeight.bold,
  //                               fontSize: AppSizes().getBlockSizeHorizontal(5),
  //                             ),
  //                           ),
  //                           Text(
  //                             (60 < currentHeartRate && currentHeartRate < 100)
  //                                 ? "Good"
  //                                 : "Bad",
  //                             style: TextStyle(
  //                               fontWeight: FontWeight.bold,
  //                               fontSize: AppSizes().getBlockSizeHorizontal(10),
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                     ))
  //               ],
  //             )),
  //         SizedBox(
  //           height: AppSizes().getBlockSizeVertical(3),
  //         ),
  //         Container(
  //           padding:
  //               EdgeInsets.only(left: AppSizes().getBlockSizeHorizontal(3)),
  //           child: Row(
  //             mainAxisAlignment: MainAxisAlignment.start,
  //             children: [
  //               Text(
  //                 "Assigned Doctor",
  //                 style: TextStyle(
  //                   fontWeight: FontWeight.bold,
  //                   fontSize: 15,
  //                 ),
  //               )
  //             ],
  //           ),
  //         ),
  //         Expanded(
  //             child: List1(
  //                 color: StyleSheet().uiBackground,
  //                 data: List.of([
  //                   doctorProfile.name != "Name"
  //                       ? ListItem1Data(
  //                           title: doctorProfile.name,
  //                           icon: IconlyLight.heart,
  //                           onPressed: () {
  //                             showDoctorDetails();
  //                           })
  //                       : ListItem1Data(
  //                           title: "No Doctor has assigned",
  //                           icon: Icons.hourglass_empty,
  //                           onPressed: () {}),
  //                 ]))),
  //         SizedBox(
  //           height: AppSizes().getBlockSizeVertical(3),
  //         ),
  //         CustomButton(
  //           backgroundColor: StyleSheet().btnBackground,
  //           textColor: StyleSheet().uiBackground,
  //           icon: IconData(Icons.health_and_safety.codePoint,
  //               fontFamily: Icons.health_and_safety.fontFamily),
  //           label: "Insuarance",
  //           onPressed: () async {
  //             // Navigator.pushNamed(context, '/insurance');
  //             // showDialog(
  //             //   context: context,
  //             //   builder: (context) => AlertDialog(
  //             //     title: Text("Insuarance"),
  //             //     content: Text("Coming Soon"),
  //             //   ),
  //             // );
  //             final Uri url = Uri.parse(
  //                 'https://www.careinsurance.com/health-insurance/heart-health-insurance/');
  //             if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
  //               throw Exception('Could not launch $url');
  //             }
  //           },
  //         ),
  //       ],
  //     ),
  //   );
  // }
