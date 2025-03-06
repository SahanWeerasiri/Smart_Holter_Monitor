import 'package:flutter/material.dart';
import 'package:health_care_web/components/buttons/custom_button_1/custom_button.dart';
import 'package:health_care_web/models/app_sizes.dart';
import 'package:health_care_web/models/patient_profile_model.dart';
import 'package:health_care_web/models/style_sheet.dart';
import 'package:iconly/iconly.dart';

class ExpandableProfileCardUpdated extends StatefulWidget {
  final PatientProfileModel patientProfileModel;
  final String myId;
  final VoidCallback onRemove;
  final VoidCallback onAdd;

  const ExpandableProfileCardUpdated({
    super.key,
    required this.patientProfileModel,
    required this.myId,
    required this.onRemove,
    required this.onAdd,
  });

  @override
  State<ExpandableProfileCardUpdated> createState() =>
      _ExpandableProfileCardUpdatedState();
}

class _ExpandableProfileCardUpdatedState
    extends State<ExpandableProfileCardUpdated> {
  bool _isExpanded = false;
  double _cardHeight = 70;
  final List<Color> _stateColors = [
    StyleSheet.myPatients,
    StyleSheet.avgHeartBox
  ];

  @override
  Widget build(BuildContext context) {
    AppSizes().initSizes(context);
    return Container(
      height: _cardHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        color: widget.patientProfileModel.docId == widget.myId
            ? _stateColors[0]
            : _stateColors[1],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: ListTile(
              title: Text(
                widget.patientProfileModel.name,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
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
                      _cardHeight = 230;
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
                        Text("Email: ${widget.patientProfileModel.email}"),
                        const SizedBox(height: 4),
                        Text("Address: ${widget.patientProfileModel.address}"),
                        const SizedBox(height: 4),
                        Text("Mobile: ${widget.patientProfileModel.mobile}"),
                        const SizedBox(height: 4),
                        Text(
                            "Device: ${widget.patientProfileModel.deviceId} | deadline: ${widget.patientProfileModel.deviceId == 'Device' ? '-' : widget.patientProfileModel.device!.deadline}"),
                        const SizedBox(height: 4),
                        widget.myId == widget.patientProfileModel.docId
                            ? CustomButton(
                                label: "Remove",
                                icon: IconlyLight.delete,
                                textColor: StyleSheet.uiBackground,
                                backgroundColor: StyleSheet.patientsDelete,
                                onPressed: widget.onRemove)
                            : CustomButton(
                                label: "Add",
                                textColor: StyleSheet.uiBackground,
                                icon: IconlyLight.add_user,
                                backgroundColor: StyleSheet.patientsAdd,
                                onPressed: widget.onAdd)
                      ],
                    ),
                    // widget.patientProfileModel.pic.isNotEmpty
                    // ?
                    Image.asset(
                      "assetes/icons/logo.png",
                      scale: 5,
                    ),
                  ],
                )),
        ],
      ),
    );
  }
}
