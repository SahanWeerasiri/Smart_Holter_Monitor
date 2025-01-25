import 'package:flutter/material.dart';
import 'package:health_care_web/components/buttons/custom_button_1/custom_button.dart';
import 'package:health_care_web/constants/consts.dart';

class ExpandableProfileCard extends StatefulWidget {
  final String name;
  final String profilePic;
  final String email;
  final String address;
  final String mobile;
  final String device;
  final bool isDone;
  final VoidCallback onCreateReport;
  final VoidCallback onRemoveDevice;
  final VoidCallback onAddDevice;
  final VoidCallback onPending;

  const ExpandableProfileCard({
    super.key,
    required this.name,
    required this.profilePic,
    required this.email,
    required this.address,
    required this.mobile,
    required this.device,
    required this.isDone,
    required this.onCreateReport,
    required this.onRemoveDevice,
    required this.onAddDevice,
    required this.onPending,
  });

  @override
  State<ExpandableProfileCard> createState() => _ExpandableProfileCardState();
}

class _ExpandableProfileCardState extends State<ExpandableProfileCard> {
  bool _isExpanded = false;
  double _cardHeight = 70;
  final List<Color> _stateColors = [
    StyleSheet().stateHeartBoxGood,
    StyleSheet().avgHeartBox,
    StyleSheet().stateHeartBoxBad,
  ];

  @override
  Widget build(BuildContext context) {
    AppSizes().initSizes(context);
    return Container(
      height: _cardHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        color: widget.isDone
            ? _stateColors[0]
            : (widget.device == "Device" ? _stateColors[2] : _stateColors[1]),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: ListTile(
              title: Text(
                widget.name,
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
                      _cardHeight = 200;
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
                        Text("Email: ${widget.email}"),
                        const SizedBox(height: 4),
                        Text("Address: ${widget.address}"),
                        const SizedBox(height: 4),
                        Text("Mobile: ${widget.mobile}"),
                        const SizedBox(height: 4),
                        Text("Device: ${widget.device}"),
                      ],
                    ),
                    widget.profilePic.isNotEmpty
                        ? Image.network(
                            widget.profilePic,
                            scale: 5,
                            errorBuilder: (context, error, stackTrace) {
                              // Fallback to a placeholder if the image fails to load
                              return Image.asset(
                                "assetes/icons/logo.png",
                                scale: 5,
                              );
                            },
                          )
                        : Image.asset(
                            "assetes/icons/logo.png",
                            scale: 5,
                          ),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        spacing: 10,
                        children: widget.isDone
                            ? [
                                CustomButton(
                                    label: "Create the report",
                                    icon: Icons.create,
                                    backgroundColor: StyleSheet().btnBackground,
                                    textColor: StyleSheet().btnText,
                                    onPressed: () => widget.onCreateReport),
                                CustomButton(
                                    label: "Remove the device",
                                    icon: Icons.remove_circle,
                                    backgroundColor:
                                        StyleSheet().patientsDelete,
                                    textColor: StyleSheet().btnText,
                                    onPressed: () => widget.onRemoveDevice),
                              ]
                            : (widget.device == "Device"
                                ? [
                                    CustomButton(
                                        label: "Add a device",
                                        icon: Icons.add,
                                        backgroundColor:
                                            StyleSheet().btnBackground,
                                        textColor: StyleSheet().btnText,
                                        onPressed: () => widget.onAddDevice),
                                  ]
                                : [
                                    CustomButton(
                                      label: "Pending...",
                                      icon: Icons.pending_actions,
                                      backgroundColor:
                                          StyleSheet().btnBackground,
                                      textColor: StyleSheet().btnText,
                                      onPressed: () => widget.onPending,
                                    ),
                                  ])),
                  ],
                )),
        ],
      ),
    );
  }
}
