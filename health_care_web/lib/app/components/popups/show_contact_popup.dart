import 'package:flutter/material.dart';
import 'package:health_care_web/models/contact_profile_model.dart';
import 'package:health_care_web/models/style_sheet.dart';
import 'package:iconly/iconly.dart';

class ShowContactPopup extends StatelessWidget {
  final ContactProfileModel profile;
  const ShowContactPopup({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: Icon(
        IconlyLight.profile,
        color: StyleSheet.doctorDetailsPopPrimary,
      ),
      backgroundColor: StyleSheet.uiBackground,
      title: Text(
        profile.name,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Mobile:",
                style: TextStyle(
                  backgroundColor: StyleSheet.uiBackground,
                  fontSize: 18,
                  color: StyleSheet.doctorDetailsPopPSecondary,
                )),
            Text(profile.mobile,
                style: TextStyle(
                  backgroundColor: StyleSheet.uiBackground,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: StyleSheet.doctorDetailsPopPSecondary,
                )),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
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
      ],
    );
  }
}
