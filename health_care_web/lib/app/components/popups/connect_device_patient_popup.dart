// import 'package:flutter/material.dart';
// import 'package:health_care_web/components/buttons/custom_button_1/custom_button.dart';
// import 'package:health_care_web/components/dropdown/CustomDropDown.dart';
// import 'package:health_care_web/models/patient_profile_model.dart';
// import 'package:health_care_web/models/style_sheet.dart';

// typedef DeviceSubmitCallback = void Function(PatientProfileModel? profile);

// class ConnectDevicePatientPopup extends StatefulWidget {
//   final String id;
//   final List<PatientProfileModel> profiles;
//   final DeviceSubmitCallback onSubmit;
//   final VoidCallback onClose;

//   const ConnectDevicePatientPopup(
//       {super.key,
//       required this.id,
//       required this.onSubmit,
//       required this.profiles,
//       required this.onClose});
//   @override
//   State<StatefulWidget> createState() => _StateConnectDevicePatientPopup();
// }

// class _StateConnectDevicePatientPopup extends State<ConnectDevicePatientPopup> {
//   String device = "";
//   PatientProfileModel? selectedPatient;

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       backgroundColor: StyleSheet.uiBackground,
//       title: Text(
//         "Connect Device",
//         textAlign: TextAlign.center,
//         style: TextStyle(
//           backgroundColor: StyleSheet.uiBackground,
//           fontSize: 25,
//           fontWeight: FontWeight.bold,
//           color: StyleSheet.doctorDetailsPopPrimary,
//         ),
//       ),
//       content: SingleChildScrollView(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             CustomDropdown(
//                 label: "Select a patient",
//                 options:
//                     widget.profiles.map((e) => ('${e.name}\n${e.id}')).toList(),
//                 onChanged: (value) {
//                   setState(() {
//                     device = value.split('\n')[1].trim();
//                     selectedPatient = widget.profiles
//                         .firstWhere((element) => element.id == device);
//                   });
//                 })
//           ],
//         ),
//       ),
//       actions: [
//         TextButton(
//           onPressed: () {
//             widget.onClose();
//             Navigator.pop(context);
//           },
//           child: Text(
//             "Cancel",
//             style: TextStyle(
//               backgroundColor: StyleSheet.uiBackground,
//               fontSize: 20,
//               color: StyleSheet.doctorDetailsPopPrimary,
//             ),
//           ),
//         ),
//         CustomButton(
//           label: "Add",
//           onPressed: () => widget.onSubmit(selectedPatient),
//           backgroundColor: StyleSheet.btnBackground,
//           textColor: StyleSheet.btnText,
//           icon: Icons.add,
//         ),
//       ],
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:health_care_web/components/buttons/custom_button_1/custom_button.dart';
import 'package:health_care_web/models/patient_profile_model.dart';
import 'package:health_care_web/models/style_sheet.dart';
import 'package:health_care_web/services/util.dart';

typedef DeviceSubmitCallback = void Function(PatientProfileModel? profile);

class ConnectDevicePatientPopup extends StatefulWidget {
  final String id;
  final DeviceSubmitCallback onSubmit;
  final VoidCallback onClose;
  final List<PatientProfileModel> profiles;

  const ConnectDevicePatientPopup({
    super.key,
    required this.id,
    required this.onSubmit,
    required this.profiles,
    required this.onClose,
  });

  @override
  State<StatefulWidget> createState() => _StateConnectDevicePatientPopup();
}

class _StateConnectDevicePatientPopup extends State<ConnectDevicePatientPopup> {
  final TextEditingController _searchController = TextEditingController();
  List<PatientProfileModel> _filteredPatients = [];
  PatientProfileModel? selectedPatient;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _filteredPatients = widget.profiles;
  }

  Future<void> _searchPatients() async {
    String searchKey = _searchController.text.trim();
    if (searchKey.isEmpty) return;

    setState(() {
      isLoading = true;
      _filteredPatients.clear();
    });

    final querySnapshot = await FirebaseFirestore.instance
        .collection('user_accounts')
        .where('name', isGreaterThanOrEqualTo: searchKey)
        .where('name', isLessThanOrEqualTo: '$searchKey\uf8ff')
        .get();

    setState(() {
      _filteredPatients = querySnapshot.docs
          .map((doc) => PatientProfileModel(
              id: doc.id,
              name: doc.data()['name'],
              mobile: doc.data()['mobile'],
              age: getAge(doc.data()['birthday']),
              email: doc.data()['email'],
              docId: doc.data()['docId'],
              deviceId: doc.data()['deviceId']))
          .toList();
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: StyleSheet.uiBackground,
      title: Text(
        "Connect Device",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.bold,
          color: StyleSheet.doctorDetailsPopPrimary,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: "Search Patient",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: _searchPatients,
                )
              ],
            ),
            SizedBox(height: 10),
            isLoading
                ? CircularProgressIndicator()
                : DropdownButtonFormField<PatientProfileModel>(
                    hint: Text("Select a patient"),
                    value: selectedPatient,
                    isExpanded: true,
                    items: _filteredPatients.map((patient) {
                      return DropdownMenuItem<PatientProfileModel>(
                        value: patient,
                        child: Text('${patient.name} (${patient.id})'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedPatient = value;
                      });
                    },
                  ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            widget.onClose();
            Navigator.pop(context);
          },
          child: Text(
            "Cancel",
            style: TextStyle(
              fontSize: 20,
              color: StyleSheet.doctorDetailsPopPrimary,
            ),
          ),
        ),
        CustomButton(
          label: "Add",
          onPressed: () => widget.onSubmit(selectedPatient),
          backgroundColor: StyleSheet.btnBackground,
          textColor: StyleSheet.btnText,
          icon: Icons.add,
        ),
      ],
    );
  }
}
