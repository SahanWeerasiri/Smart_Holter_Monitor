import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:health_care_web/constants/consts.dart';
import 'package:health_care_web/pages/app/cards/expandable_profile_card_updated.dart';
import 'package:health_care_web/pages/app/services/firestore_db_service.dart';
import 'package:iconly/iconly.dart';

class Devices extends StatefulWidget {
  const Devices({super.key});

  @override
  State<Devices> createState() => _DevicesState();
}

class _DevicesState extends State<Devices> {
  final TextEditingController controller = TextEditingController();
  List<UserProfile> profiles = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // fetchPatients();
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

  Future<void> addPatients(id, docId) async {
    Map<String, dynamic> res = await FirestoreDbService().addPatiet(id, docId);
    if (res['success']) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Patient added successfully')));
      refresh();
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to add patient')));
    }
  }

  void refresh() {
    setState(() {
      profiles = [];
      isLoading = false;
    });
    // fetchPatients();
  }

  Future<void> fetchPatients() async {
    setState(() {
      isLoading = true;
      profiles = [];
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("User is not logged in.");
      }

      Map<String, dynamic> res = await FirestoreDbService().fetchPatient();

      if (res['success']) {
        setState(() {
          profiles = res['data'] as List<UserProfile>;
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

  Future<void> fetchSearch(String name) async {
    setState(() {
      profiles = [];
      isLoading = true;
    });
    try {
      Map<String, dynamic> res =
          await FirestoreDbService().fetchSearch(name.toLowerCase());

      if (res['success']) {
        setState(() {
          profiles = res['data'] as List<UserProfile>;
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
                value.isNotEmpty ? fetchSearch(value) : fetchPatients(),
            leading: Icon(IconlyLight.search),
            hintText: "Search...",
            controller: controller,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: 150,
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(12),
                    ),
                    color: StyleSheet().myPatients),
                child: Row(
                  spacing: 3,
                  children: [Icon(Icons.people), Text("My Patients")],
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
                  children: profiles.map((p) {
                    return ExpandableProfileCardUpdated(
                      id: p.id,
                      name: p.name,
                      profilePic: p.pic,
                      email: p.email,
                      address: p.address,
                      mobile: p.mobile,
                      device: p.device,
                      docId: p.doctorId,
                      myId: FirebaseAuth.instance.currentUser!.uid,
                      onRemove: () => removePatients(p.id),
                      onAdd: () => addPatients(
                          p.id, FirebaseAuth.instance.currentUser!.uid),
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }
}
