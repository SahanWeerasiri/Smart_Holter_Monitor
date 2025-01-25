import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:health_care_web/constants/consts.dart';
import 'package:health_care_web/pages/app/cards/expandable_profile_card.dart';
import 'package:health_care_web/pages/app/services/firestore_db_service.dart';

class Summary extends StatefulWidget {
  const Summary({super.key});

  @override
  State<Summary> createState() => _SummaryState();
}

class _SummaryState extends State<Summary> {
  List<UserProfile> currentProfiles = [];
  UserProfile selectedProfile = UserProfile(
    id: "",
    name: "",
    email: "",
    pic: "",
    address: "",
    mobile: "",
    device: "",
    isDone: false,
  );

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
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
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
                );
              }).toList(),
            ),
          );
  }
}
