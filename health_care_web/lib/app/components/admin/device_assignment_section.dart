import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:health_care_web/components/buttons/custom_button_1/custom_button.dart';
import 'package:health_care_web/pages/additional/popups/add_device_popup.dart';
import 'package:health_care_web/pages/cards/expandable_profile_card_updated_devices.dart';
import 'package:health_care_web/pages/services/firestore_db_service.dart';
import 'package:health_care_web/pages/services/real_db_service.dart';
import 'package:iconly/iconly.dart';

class DeviceAssignmentSection extends StatefulWidget {
  const DeviceAssignmentSection({super.key});

  @override
  State<DeviceAssignmentSection> createState() =>
      _DeviceAssignmentSectionState();
}

class _DeviceAssignmentSectionState extends State<DeviceAssignmentSection> {
  final TextEditingController controller = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  List<DeviceProfile> profiles = [];
  bool isLoading = true;
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
      isLoading = true;
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
      final FirebaseDatabase database = FirebaseDatabase.instance;
      try {
        final ref = database.ref('devices');

        ref.onValue.listen((DatabaseEvent event) {
          final data = event.snapshot.value;

          if (data != null && data is Map) {
            List<DeviceProfile> devices = [];

            data.forEach((key, value) {
              if (value is Map) {
                final other = (value)['other'] as String?;
                final state = (value)['assigned'] as int?;
                final deadline = (value)['deadline'] as String?;
                final useData = (value)['use'] as String?;

                if (other != null && state != null) {
                  devices.add(DeviceProfile(
                      deadline: deadline.toString(),
                      code: key,
                      detail: other,
                      state: state,
                      use: useData.toString()));
                } else {
                  // Handle missing 'other' or 'assigned' values as needed
                }
              } else {
                // Handle non-map values appropriately.
              }
            });

            setState(() {
              profiles = devices;
            });
          } else {
            // Handle cases where data is null or not a map
            setState(() {
              profiles = []; // Or handle the empty state as appropriate
            });
          }
        }, onError: (error) {
          // Handle errors
        });
      } catch (e) {
        setState(() {
          profiles = []; // Or handle the empty state as appropriate
        });
      } finally {
        setState(() => isLoading = false);
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

      final FirebaseDatabase database = FirebaseDatabase.instance;
      try {
        final ref = database.ref('devices');

        ref.onValue.listen((DatabaseEvent event) {
          final data = event.snapshot.value;

          if (data != null && data is Map) {
            List<DeviceProfile> devices = [];

            data.forEach((key, v) {
              if (v is Map) {
                final other = (v)['other'] as String?;
                final state = (v)['assigned'] as int?;
                final code = key;
                final useData = (v)['use'] as String?;
                final deadline = (v)['deadline'] as String?;

                if (other != null && state != null) {
                  if (code
                      .toLowerCase()
                      .contains(value.toLowerCase())) // Search by detail
                  {
                    devices.add(DeviceProfile(
                        code: key,
                        detail: other,
                        deadline: deadline.toString(),
                        state: state,
                        use: useData.toString()));
                  }
                }
              }
            });

            setState(() {
              profiles = devices;
            });
          } else {
            // Handle null or non-map data
            setState(() {
              profiles = []; // Clear the list to show an empty state
            });
          }
        }, onError: (error) {
          // Handle errors
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('An error occurred: $error'),
              backgroundColor: Colors.red,
            ),
          );
        });
      } catch (e) {
        setState(() {
          profiles = []; // Or handle the empty state as appropriate
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() => isLoading = false);
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
                    color: StyleSheet().pendingDevices),
                child: Row(
                  spacing: 3,
                  children: [
                    Icon(IconlyLight.time_circle),
                    Text("Pending Devices")
                  ],
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
                    "No Devices available",
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
                      detail: "${p.use}\n${p.detail}",
                      onRemove: () {},
                      deadline: p.deadline,
                      state: p.state,
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }
}
