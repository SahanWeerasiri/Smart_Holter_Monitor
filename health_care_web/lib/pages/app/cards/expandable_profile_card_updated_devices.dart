import 'package:flutter/material.dart';
import 'package:health_care_web/constants/consts.dart';

class ExpandableProfileCardUpdatedDevices extends StatefulWidget {
  final String code;
  final String detail;
  final VoidCallback onRemove;

  const ExpandableProfileCardUpdatedDevices({
    super.key,
    required this.code,
    required this.detail,
    required this.onRemove,
  });

  @override
  State<ExpandableProfileCardUpdatedDevices> createState() =>
      _ExpandableProfileCardUpdatedDevicesState();
}

class _ExpandableProfileCardUpdatedDevicesState
    extends State<ExpandableProfileCardUpdatedDevices> {
  bool _isExpanded = false;
  double _cardHeight = 70;
  final List<Color> _stateColors = [
    StyleSheet().myPatients,
    StyleSheet().avgHeartBox
  ];

  @override
  Widget build(BuildContext context) {
    AppSizes().initSizes(context);
    return Container(
      height: _cardHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        color: _stateColors[1],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: ListTile(
              title: Text(
                widget.code,
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
