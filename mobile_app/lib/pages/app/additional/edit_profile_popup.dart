import 'package:flutter/material.dart';
import 'package:health_care/components/buttons/custom_button_1/custom_button.dart';
import 'package:health_care/constants/consts.dart';
import 'package:iconly/iconly.dart';

class EditProfilePopup extends StatelessWidget {
  final TextEditingController mobileController;
  final TextEditingController addressController;
  final TextEditingController languageController;
  final VoidCallback onPickImage;
  final VoidCallback onSubmit;

  const EditProfilePopup({
    super.key,
    required this.mobileController,
    required this.addressController,
    required this.languageController,
    required this.onPickImage,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: StyleSheet().uiBackground,
      title: Text(
        "Edit Profile",
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
              controller: mobileController,
              decoration: const InputDecoration(labelText: "Mobile"),
            ),
            TextField(
              style: TextStyle(
                backgroundColor: StyleSheet().uiBackground,
                fontSize: 20,
                color: StyleSheet().doctorDetailsPopPrimary,
              ),
              controller: addressController,
              decoration: const InputDecoration(labelText: "Address"),
            ),
            TextField(
              style: TextStyle(
                backgroundColor: StyleSheet().uiBackground,
                fontSize: 20,
                color: StyleSheet().doctorDetailsPopPrimary,
              ),
              controller: languageController,
              decoration: const InputDecoration(labelText: "Language"),
            ),
            const SizedBox(height: 10),
            CustomButton(
              label: "Change Picture",
              onPressed: onPickImage,
              backgroundColor: StyleSheet().btnBackground,
              textColor: StyleSheet().btnText,
              icon: IconlyLight.image,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
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
          onPressed: onSubmit,
          backgroundColor: StyleSheet().btnBackground,
          textColor: StyleSheet().btnText,
          icon: Icons.update,
        ),
      ],
    );
  }
}
