import 'package:flutter/material.dart';
import 'package:health_care_web/components/buttons/custom_button_1/custom_button.dart';
import 'package:health_care_web/constants/consts.dart';

class AddDevicePopup extends StatefulWidget {
  final TextEditingController deviceCode;
  final TextEditingController otherDetails;
  final VoidCallback onSubmit;

  const AddDevicePopup({
    super.key,
    required this.deviceCode,
    required this.otherDetails,
    required this.onSubmit,
  });
  @override
  State<StatefulWidget> createState() => _StateAddDevicePopup();
}

class _StateAddDevicePopup extends State<AddDevicePopup> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: StyleSheet().uiBackground,
      title: Text(
        "Add Device",
        textAlign: TextAlign.center,
        style: TextStyle(
          backgroundColor: StyleSheet().uiBackground,
          fontSize: 25,
          fontWeight: FontWeight.bold,
          color: StyleSheet().doctorDetailsPopPrimary,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              style: TextStyle(
                backgroundColor: StyleSheet().uiBackground,
                fontSize: 20,
                color: StyleSheet().doctorDetailsPopPrimary,
              ),
              controller: widget.deviceCode,
              decoration: const InputDecoration(labelText: "Device Code"),
            ),
            TextField(
              style: TextStyle(
                backgroundColor: StyleSheet().uiBackground,
                fontSize: 20,
                color: StyleSheet().doctorDetailsPopPrimary,
              ),
              controller: widget.otherDetails,
              decoration: const InputDecoration(labelText: "Other Details"),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            widget.deviceCode.clear();
            widget.otherDetails.clear();
            Navigator.pop(context);
          },
          child: Text(
            "Cancel",
            style: TextStyle(
              backgroundColor: StyleSheet().uiBackground,
              fontSize: 20,
              color: StyleSheet().doctorDetailsPopPrimary,
            ),
          ),
        ),
        CustomButton(
          label: "Update",
          onPressed: widget.onSubmit,
          backgroundColor: StyleSheet().btnBackground,
          textColor: StyleSheet().btnText,
          icon: Icons.update,
        ),
      ],
    );
  }
}
