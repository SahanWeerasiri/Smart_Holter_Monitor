import 'package:flutter/material.dart';
import 'package:health_care_web/components/buttons/custom_button_1/custom_button.dart';
import 'package:health_care_web/components/dropdown/CustomDropDown.dart';
import 'package:health_care_web/models/patient_profile_model.dart';
import 'package:health_care_web/models/style_sheet.dart';

typedef DeviceSubmitCallback = void Function(PatientProfileModel? profile);

class ConnectDevicePatientPopup extends StatefulWidget {
  final String id;
  final List<PatientProfileModel> profiles;
  final DeviceSubmitCallback onSubmit;
  final VoidCallback onClose;

  const ConnectDevicePatientPopup(
      {super.key,
      required this.id,
      required this.onSubmit,
      required this.profiles,
      required this.onClose});
  @override
  State<StatefulWidget> createState() => _StateConnectDevicePatientPopup();
}

class _StateConnectDevicePatientPopup extends State<ConnectDevicePatientPopup> {
  String device = "";
  PatientProfileModel? selectedPatient;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: StyleSheet.uiBackground,
      title: Text(
        "Connect Device",
        textAlign: TextAlign.center,
        style: TextStyle(
          backgroundColor: StyleSheet.uiBackground,
          fontSize: 25,
          fontWeight: FontWeight.bold,
          color: StyleSheet.doctorDetailsPopPrimary,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomDropdown(
                label: "Select a patient",
                options:
                    widget.profiles.map((e) => ('${e.name}\n${e.id}')).toList(),
                onChanged: (value) {
                  setState(() {
                    device = value.split('\n')[1].trim();
                    selectedPatient = widget.profiles
                        .firstWhere((element) => element.id == device);
                  });
                })
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
              backgroundColor: StyleSheet.uiBackground,
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
