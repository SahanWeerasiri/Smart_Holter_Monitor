import 'package:flutter/material.dart';
import 'package:health_care_web/components/buttons/custom_button_1/custom_button.dart';
import 'package:health_care_web/constants/consts.dart';
import 'package:health_care_web/pages/app/additional/connect_device_patient_popup.dart';
import 'package:health_care_web/pages/app/services/firestore_db_service.dart';
import 'package:health_care_web/pages/app/services/real_db_service.dart';

class ExpandableProfileCardUpdatedDevices extends StatefulWidget {
  final String code;
  final String detail;
  final int state;
  final VoidCallback onRemove;

  const ExpandableProfileCardUpdatedDevices({
    super.key,
    required this.code,
    required this.detail,
    required this.onRemove,
    this.state = 0,
  });

  @override
  State<ExpandableProfileCardUpdatedDevices> createState() =>
      _ExpandableProfileCardUpdatedDevicesState();
}

class _ExpandableProfileCardUpdatedDevicesState
    extends State<ExpandableProfileCardUpdatedDevices> {
  bool _isExpanded = false;
  bool isLoading = false;
  List<String> patient = [];
  double _cardHeight = 70;
  final List<Color> _stateColors = [
    StyleSheet().availableDevices,
    StyleSheet().unavailableDevices,
    StyleSheet().pendingDevices,
  ];

  Future<void> showPatients(device) async {
    setState(() {
      isLoading = true;
    });
    await fetchPatients();
    Map<String, dynamic> res =
        await RealDbService().connectDevicePending(device);
    setState(() {
      isLoading = false;
    });
    if (res['success']) {
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Device is in pending state')));
      showDialog(
          context: context,
          builder: (context) => ConnectDevicePatientPopup(
                id: device,
                onSubmit: (uid) {
                  setState(() {
                    isLoading = true;
                  });
                  RealDbService().connectDeviceData(device);
                  FirestoreDbService().addDeviceToPatient(uid, device);
                  setState(() {
                    isLoading = false;
                  });
                  Navigator.pop(context);
                },
                patient: patient,
                onClose: () {
                  RealDbService().disconnectDevicePending(device);
                },
              ));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to add device')));
    }
  }

  Future<void> fetchPatients() async {
    setState(() {
      patient = [];
    });
    Map<String, dynamic> res = await FirestoreDbService().fetchPatient();
    if (res['success']) {
      final pl = res['data'] as List<UserProfile>;
      setState(() {
        for (UserProfile element in pl) {
          patient.add(element.id);
        }
      });
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: res['message']));
    }
  }

  @override
  Widget build(BuildContext context) {
    AppSizes().initSizes(context);

    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(color: StyleSheet().btnBackground),
      );
    }
    return Container(
      height: _cardHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        color: _stateColors[widget.state],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: ListTile(
              title: Row(children: [
                Text(
                  widget.code,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(
                  width: 8,
                ),
                if (widget.state == 0)
                  CustomButton(
                    label: "Add Patient",
                    icon: Icons.add,
                    textColor: StyleSheet().uiBackground,
                    backgroundColor: StyleSheet().btnBackground,
                    onPressed: () {
                      showPatients(widget.code);
                    },
                  ),
              ]),
              trailing: IconButton(
                icon: Icon(
                  _isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                ),
                onPressed: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                    if (_isExpanded) {
                      _cardHeight = 150;
                    } else {
                      _cardHeight = 70;
                    }
                  });
                },
              ),
            ),
          ),
          if (_isExpanded)
            Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.detail),
                        const SizedBox(height: 4),
                        // widget.myId == widget.docId
                        //     ? CustomButton(
                        //         label: "Remove",
                        //         icon: IconlyLight.delete,
                        //         textColor: StyleSheet().uiBackground,
                        //         backgroundColor: StyleSheet().patientsDelete,
                        //         onPressed: () => {widget.onRemove()})
                        //     : CustomButton(
                        //         label: "Add",
                        //         textColor: StyleSheet().uiBackground,
                        //         icon: IconlyLight.add_user,
                        //         backgroundColor: StyleSheet().patientsAdd,
                        //         onPressed: () => {widget.onAdd()})
                      ],
                    ),
                  ],
                )),
        ],
      ),
    );
  }
}
