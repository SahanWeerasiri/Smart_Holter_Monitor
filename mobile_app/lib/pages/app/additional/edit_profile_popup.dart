import 'package:flutter/material.dart';

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
      title: const Text("Edit Profile"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: mobileController,
              decoration: const InputDecoration(labelText: "Mobile"),
            ),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(labelText: "Address"),
            ),
            TextField(
              controller: languageController,
              decoration: const InputDecoration(labelText: "Language"),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              icon: const Icon(Icons.photo),
              label: const Text("Change Picture"),
              onPressed: onPickImage,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: onSubmit,
          child: const Text("Submit"),
        ),
      ],
    );
  }
}
