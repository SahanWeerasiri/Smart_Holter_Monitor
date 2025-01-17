import 'package:flutter/material.dart';

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
      title: const Text("Add Emergency Contact"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            TextField(
              controller: mobileController,
              decoration: const InputDecoration(labelText: "Mobile"),
              keyboardType: TextInputType.phone,
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
          child: const Text("Add"),
        ),
      ],
    );
  }
}
