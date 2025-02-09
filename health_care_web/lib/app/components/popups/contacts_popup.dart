import 'package:flutter/material.dart';
import 'package:health_care_web/models/contact_profile_model.dart';
import 'package:health_care_web/models/style_sheet.dart';

class ContactsPopup extends StatefulWidget {
  final List<ContactProfileModel> contacts;

  const ContactsPopup({
    super.key,
    required this.contacts,
  });
  @override
  State<StatefulWidget> createState() => _StateContactsPopup();
}

class _StateContactsPopup extends State<ContactsPopup> {
  String device = "";

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: StyleSheet.uiBackground,
      title: Text(
        "Contact Details",
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
            children: widget.contacts.isEmpty
                ? [
                    Container(
                        color: StyleSheet.uiBackground,
                        padding: EdgeInsets.all(8),
                        child: Text(
                          "No contacts available",
                          style: TextStyle(fontSize: 20, color: Colors.black),
                        ))
                  ]
                : widget.contacts.map((contact) {
                    return Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            color: StyleSheet.divider),
                        padding: EdgeInsets.all(8),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                contact.name,
                                style: TextStyle(
                                    fontSize: 20, color: Colors.black),
                              ),
                              Text(
                                contact.mobile,
                                style: TextStyle(
                                    fontSize: 15,
                                    color: StyleSheet.btnBackground),
                              ),
                            ]));
                  }).toList()),
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
