import 'package:flutter/material.dart';
import 'package:health_care_web/app/components/popups/connect_device_patient_popup.dart';
import 'package:health_care_web/components/buttons/custom_button_1/custom_button.dart';
import 'package:health_care_web/models/app_sizes.dart';
import 'package:health_care_web/models/patient_profile_model.dart';
import 'package:health_care_web/models/return_model.dart';
import 'package:health_care_web/models/style_sheet.dart';
import 'package:health_care_web/services/firestore_db_service.dart';
import 'package:health_care_web/services/real_db_service.dart';
import 'package:health_care_web/services/util.dart';

class ExpandableProfileCardUpdatedDevices extends StatefulWidget {
  final String code;
  final String detail;
  final String deadline;
  final int state;
  final VoidCallback onRemove;

  const ExpandableProfileCardUpdatedDevices({
    super.key,
    required this.code,
    required this.detail,
    required this.deadline,
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
  List<PatientProfileModel> patients = [];
  double _cardHeight = 70;
  final List<Color> _stateColors = [
    StyleSheet.availableDevices,
    StyleSheet.unavailableDevices,
    StyleSheet.pendingDevices,
  ];

  Future<void> showPatients(String device, String detail) async {
    setState(() {
      isLoading = true;
    });
    ReturnModel res = await RealDbService().connectDevicePending(device);
    await fetchPatients();

    setState(() {
      isLoading = false;
    });
    if (res.state) {
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Device is in pending state')));
      showDialog(
          context: context,
          builder: (context) => ConnectDevicePatientPopup(
                id: device,
                profiles: patients,
                onSubmit: (userProfile) {
                  setState(() {
                    isLoading = true;
                  });
                  if (userProfile == null) {
                    setState(() {
                      isLoading = false;
                    });
                    return;
                  }
                  RealDbService().connectDeviceData(
                    device,
                    "Assigned to: ${userProfile.name}\nmobile: ${userProfile.mobile}\nemail: ${userProfile.email}",
                  );
                  FirestoreDbService().addDeviceToPatient(
                    userProfile.id,
                    device,
                  );
                  setState(() {
                    isLoading = false;
                  });
                  Navigator.pop(context);
                },
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
      patients = [];
    });
    ReturnModel res = await FirestoreDbService().fetchPatientsUnassigned();
    if (res.state) {
      final pl = res.patients;
      setState(() {
        patients = pl;
      });
    } else {
      showMessages(res.state, res.message, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    AppSizes().initSizes(context);

    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(color: StyleSheet.btnBackground),
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
                    textColor: StyleSheet.uiBackground,
                    backgroundColor: StyleSheet.btnBackground,
                    onPressed: () {
                      showPatients(widget.code, widget.detail);
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
                      _cardHeight = 250;
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
                        widget.deadline.isNotEmpty
                            ? Text("Deadline: ${widget.deadline}")
                            : const Text("No Deadline"),
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
