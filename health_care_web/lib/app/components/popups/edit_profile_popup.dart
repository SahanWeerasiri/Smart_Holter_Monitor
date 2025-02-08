import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:health_care_web/components/buttons/custom_button_1/custom_button.dart';
import 'package:health_care_web/models/style_sheet.dart';
import 'package:iconly/iconly.dart';
import 'package:image_picker/image_picker.dart';

class EditProfilePopup extends StatefulWidget {
  final TextEditingController mobileController;
  final TextEditingController addressController;
  final TextEditingController languageController;
  final TextEditingController picController;
  final VoidCallback onSubmit;

  const EditProfilePopup({
    super.key,
    required this.mobileController,
    required this.addressController,
    required this.languageController,
    required this.picController,
    required this.onSubmit,
  });
  @override
  State<StatefulWidget> createState() => _StateEditProfile();
}

class _StateEditProfile extends State<EditProfilePopup> {
  Future<void> onPick() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      // Read the file as bytes
      final bytes = await image.readAsBytes();

      // Encode the bytes to a Base64 string
      final base64String = base64Encode(bytes);

      setState(() {
        widget.picController.text = base64String; // Store the Base64 string
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: StyleSheet.uiBackground,
      title: Text(
        "Edit Profile",
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
            Container(
              clipBehavior: Clip.hardEdge,
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                  color: StyleSheet.btnBackground,
                  borderRadius: BorderRadius.circular(60)),
              child: widget.picController.text.isNotEmpty
                  ? Image.memory(
                      base64Decode(widget.picController.text),
                      fit: BoxFit
                          .cover, // Ensures the image fills the CircleAvatar nicely
                    )
                  : const Icon(
                      Icons.person,
                      size: 40, // Optional: Adjust size as needed
                      color: Colors.white, // Optional: Adjust icon color
                    ),
            ),
            TextField(
              style: TextStyle(
                backgroundColor: StyleSheet.uiBackground,
                fontSize: 20,
                color: StyleSheet.doctorDetailsPopPrimary,
              ),
              controller: widget.mobileController,
              decoration: const InputDecoration(labelText: "Mobile"),
            ),
            TextField(
              style: TextStyle(
                backgroundColor: StyleSheet.uiBackground,
                fontSize: 20,
                color: StyleSheet.doctorDetailsPopPrimary,
              ),
              controller: widget.addressController,
              decoration: const InputDecoration(labelText: "Address"),
            ),
            TextField(
              style: TextStyle(
                backgroundColor: StyleSheet.uiBackground,
                fontSize: 20,
                color: StyleSheet.doctorDetailsPopPrimary,
              ),
              controller: widget.languageController,
              decoration: const InputDecoration(labelText: "Language"),
            ),
            const SizedBox(height: 10),
            CustomButton(
              label: "Change Picture",
              onPressed: () {
                onPick();
              },
              backgroundColor: StyleSheet.btnBackground,
              textColor: StyleSheet.btnText,
              icon: IconlyLight.image,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            widget.mobileController.clear();
            widget.addressController.clear();
            widget.languageController.clear();
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
          label: "Update",
          onPressed: widget.onSubmit,
          backgroundColor: StyleSheet.btnBackground,
          textColor: StyleSheet.btnText,
          icon: Icons.update,
        ),
      ],
    );
  }
}
