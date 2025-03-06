import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:health_care_web/app/components/cards/expandable_profile_card_updated.dart';
import 'package:health_care_web/models/app_sizes.dart';
import 'package:health_care_web/models/doctor_profile_model.dart';
import 'package:health_care_web/models/patient_profile_model.dart';
import 'package:health_care_web/models/return_model.dart';
import 'package:health_care_web/models/style_sheet.dart';
import 'package:health_care_web/services/firestore_db_service.dart';
import 'package:health_care_web/services/util.dart';
import 'package:iconly/iconly.dart';

class AllPatients extends StatefulWidget {
  const AllPatients({super.key});

  @override
  State<AllPatients> createState() => _AllPatientsState();
}

class _AllPatientsState extends State<AllPatients> {
  DoctorProfileModel? _userProfile =
      DoctorProfileModel(id: "", name: "Name", email: "Email");
  final TextEditingController controller = TextEditingController();
  List<PatientProfileModel> profiles = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchPatients();
  }

  void refresh() {
    setState(() {
      profiles = [];
      isLoading = false;
    });
    fetchPatients();
  }

  Future<void> fetchPatients() async {
    setState(() {
      isLoading = true;
      profiles = [];
    });
    _userProfile = await _userProfile!.initDoctor(context);
    final List<PatientProfileModel> patients =
        await _userProfile!.fetchAllPatients(context);
    // showMessages(false, patients.length.toString(), context);

    setState(() {
      profiles = patients;
    });

    // showMessages(true, profiles[0].doctorProfileModel!.id, context);

    setState(() => isLoading = false);
  }

  Future<void> fetchSearch(String name) async {
    setState(() {
      profiles = [];
      isLoading = true;
    });
    final List<PatientProfileModel> patients =
        await _userProfile!.fetchSearchPatients(name, context);
    // showMessages(false, patients.length.toString(), context);
    setState(() {
      profiles = patients;
    });
    setState(() => isLoading = false);
  }

  Future<void> addPatients(String ind) async {
    ReturnModel res = await FirestoreDbService()
        .addPatient(ind, FirebaseAuth.instance.currentUser!.uid);
    showMessages(res.state, res.message, context);
    refresh();
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
                    color: StyleSheet.myPatients),
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
                      patientProfileModel: p,
                      myId: _userProfile!.id,
                      onRemove: () {
                        p.doctorProfileModel!.removePatients(p.id, context);
                        refresh();
                      },
                      onAdd: () => addPatients(p.id),
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }
}
