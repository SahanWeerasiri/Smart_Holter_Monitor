import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:health_care_web/components/buttons/custom_button_1/custom_button.dart';
import 'package:health_care_web/constants/consts.dart';
import 'package:health_care_web/pages/app/additional/add_device_popup.dart';
import 'package:health_care_web/pages/app/cards/expandable_profile_card_updated_devices.dart';
import 'package:health_care_web/pages/app/services/firestore_db_service.dart';
import 'package:health_care_web/pages/app/services/real_db_service.dart';
import 'package:iconly/iconly.dart';

class Devices extends StatefulWidget {
  const Devices({super.key});

  @override
  State<Devices> createState() => _DevicesState();
}

class _DevicesState extends State<Devices> {
  final TextEditingController controller = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  List<DeviceProfile> profiles = [];
  bool isLoading = false;
  bool isOpen = false;

  @override
  void initState() {
    super.initState();
    fetcheDevices();
  }

  Future<void> removePatients(id) async {
    Map<String, dynamic> res = await FirestoreDbService().removePatiet(id);
    if (res['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Patient removed successfully')));
      refresh();
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to remove patient')));
    }
  }

  Future<void> addDevices(code, detail) async {
    Map<String, dynamic> res = await RealDbService().addDevice(code, detail);
    if (res['success']) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Device added successfully')));
      refresh();
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to add device')));
    }
  }

  void refresh() {
    setState(() {
      profiles = [];
      isLoading = false;
    });
    fetcheDevices();
  }

  Future<void> fetcheDevices() async {
    setState(() {
      isLoading = true;
      profiles = [];
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("User is not logged in.");
      }

      Map<String, dynamic> res = await RealDbService().fetchDevices();

      if (res['success']) {
        setState(() {
          profiles = res['data'] as List<DeviceProfile>;
        });
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('An error occurred: ${res["error"]}'),
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

  Future<void> fetchSearchDevices(value) async {
    setState(() {
      profiles = [];
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("User is not logged in.");
      }

      Map<String, dynamic> res = await RealDbService()
          .fetchSearchDevices(value.toString().toLowerCase());

      if (res['success']) {
        setState(() {
          profiles = res['data'] as List<DeviceProfile>;
        });
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('An error occurred: ${res["error"]}'),
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

  // Future<void> fetchSearch(String name) async {
  //   setState(() {
  //     profiles = [];
  //     isLoading = true;
  //   });
  //   try {
  //     Map<String, dynamic> res =
  //         await FirestoreDbService().fetchSearch(name.toLowerCase());

  //     if (res['success']) {
  //       setState(() {
  //         profiles = res['data'] as List<UserProfile>;
  //       });
  //     } else {
  //       WidgetsBinding.instance.addPostFrameCallback((_) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(
  //             content: Text('An error occurred: ${res["error"]}'),
  //             backgroundColor: Colors.red,
  //           ),
  //         );
  //       });
  //     }
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('An error occurred: $e'),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //   } finally {
  //     setState(() => isLoading = false);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    AppSizes().initSizes(context);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        spacing: 10,
        children: [
          SearchBar(
            onSubmitted: (value) =>
                value.isNotEmpty ? fetchSearchDevices(value) : fetcheDevices(),
            leading: Icon(IconlyLight.search),
            hintText: "Search...",
            controller: controller,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            spacing: 10,
            children: [
              CustomButton(
                label: "Add Device",
                icon: Icons.add,
                textColor: StyleSheet().uiBackground,
                backgroundColor: StyleSheet().btnBackground,
                onPressed: () {
                  setState(() {
                    isOpen = true;
                    showDialog(
                        context: context,
                        builder: (context) => AddDevicePopup(
                            deviceCode: TextEditingController(),
                            otherDetails: TextEditingController(),
                            onSubmit: (code, detail) {
                              addDevices(code, detail);
                              Navigator.pop(context);
                            }));
                  });
                },
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            spacing: 10,
            children: [
              Container(
                width: 180,
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(12),
                    ),
                    color: StyleSheet().availableDevices),
                child: Row(
                  spacing: 3,
                  children: [Icon(Icons.devices), Text("Available Devices")],
                ),
              ),
              Container(
                width: 180,
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(12),
                    ),
                    color: StyleSheet().unavailableDevices),
                child: Row(
                  spacing: 3,
                  children: [
                    Icon(Icons.device_unknown_sharp),
                    Text("Unavailable Devices")
                  ],
                ),
              ),
            ],
          ),
          profiles.isEmpty
              ? const Center(
                  child: Text(
                    "No profiles available",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 10,
                  children: profiles.map((p) {
                    return ExpandableProfileCardUpdatedDevices(
                      code: p.code,
                      detail: p.detail,
                      onRemove: () {},
                      state: p.state,
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }
}
