import 'package:flutter/material.dart';
import 'package:health_care_web/components/buttons/custom_button_1/custom_button.dart';
import 'package:health_care_web/components/dropdown/CustomDropDown.dart';

typedef DeviceSubmitCallback = void Function(String code);

class ConnectDevicePopup extends StatefulWidget {
  final String id;
  final List<String> devices;
  final DeviceSubmitCallback onSubmit;

  const ConnectDevicePopup({
    super.key,
    required this.id,
    required this.devices,
    required this.onSubmit,
  });
  @override
  State<StatefulWidget> createState() => _StateConnectDevicePopup();
}

class _StateConnectDevicePopup extends State<ConnectDevicePopup> {
  String device = "";

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: StyleSheet().uiBackground,
      title: Text(
        "Connect Device",
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
            CustomDropdown(
                label: "Select a device",
                options: widget.devices,
                onChanged: (value) {
                  setState(() {
                    device = value;
                  });
                })
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
              backgroundColor: StyleSheet().uiBackground,
              fontSize: 20,
              color: StyleSheet().doctorDetailsPopPrimary,
            ),
          ),
        ),
        CustomButton(
          label: "Add",
          onPressed: () => widget.onSubmit(device),
          backgroundColor: StyleSheet().btnBackground,
          textColor: StyleSheet().btnText,
          icon: Icons.add,
        ),
      ],
    );
  }
}
