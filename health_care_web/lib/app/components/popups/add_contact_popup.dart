import 'package:flutter/material.dart';
import 'package:health_care_web/components/buttons/custom_button_1/custom_button.dart';
import 'package:health_care_web/constants/consts.dart';

class AddContactPopup extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController mobileController;
  final VoidCallback onSubmit;

  const AddContactPopup({
    super.key,
    required this.nameController,
    required this.mobileController,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: StyleSheet().uiBackground,
      title: Text(
        "Add Emergency Contact",
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
              controller: nameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            TextField(
              style: TextStyle(
                backgroundColor: StyleSheet().uiBackground,
                fontSize: 20,
                color: StyleSheet().doctorDetailsPopPrimary,
              ),
              controller: mobileController,
              decoration: const InputDecoration(labelText: "Mobile"),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            mobileController.clear();
            nameController.clear();
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
          label: "Add Contact",
          onPressed: onSubmit,
          backgroundColor: StyleSheet().btnBackground,
          textColor: StyleSheet().btnText,
          icon: Icons.person_add,
        ),
      ],
    );
  }
}
