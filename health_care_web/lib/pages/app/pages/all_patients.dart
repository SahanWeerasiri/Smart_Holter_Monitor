import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:health_care_web/constants/consts.dart';
import 'package:health_care_web/pages/app/cards/expandable_profile_card_updated.dart';
import 'package:health_care_web/pages/app/services/firestore_db_service.dart';

class AllPatients extends StatefulWidget {
  const AllPatients({super.key});

  @override
  State<AllPatients> createState() => _AllPatientsState();
}

class _AllPatientsState extends State<AllPatients> {
  List<UserProfile> profiles = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchPatients();
  }

  Future<void> fetchPatients() async {
    setState(() => isLoading = true);

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

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    AppSizes().initSizes(context);
    return profiles.isEmpty
        ? Padding(
            padding: const EdgeInsets.all(16.0),
            child: const Center(
              child: Text(
                "No profiles available",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              spacing: 10,
              children: [
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
                          color: StyleSheet().stateHeartBoxGood),
                      child: Row(
                        spacing: 3,
                        children: [Icon(Icons.people), Text("My Patients")],
                      ),
                    ),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: profiles.map((p) {
                    return ExpandableProfileCardUpdated(
                      name: p.name,
                      profilePic: p.pic,
                      email: p.email,
                      address: p.address,
                      mobile: p.mobile,
                      device: p.device,
                      docId: p.doctorId,
                      myId: FirebaseAuth.instance.currentUser!.uid,
                    );
                  }).toList(),
                ),
              ],
            ));
  }
}
