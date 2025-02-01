import 'package:flutter/material.dart';
import 'package:health_care_web/components/buttons/custom_button_1/custom_button.dart';
import 'package:health_care_web/constants/consts.dart';
import 'package:health_care_web/pages/app/additional/contacts_popup.dart';

class ExpandableProfileCard extends StatefulWidget {
  final String name;
  final String profilePic;
  final String email;
  final String address;
  final String mobile;
  final String device;
  final bool isDone;
  final List<ContactProfile> contactProfiles;
  final VoidCallback onCreateReport;
  final VoidCallback onViewReport;
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
    required this.onViewReport,
    required this.contactProfiles,
  });

  @override
  State<ExpandableProfileCard> createState() => _ExpandableProfileCardState();
}

class _ExpandableProfileCardState extends State<ExpandableProfileCard> {
  bool _isExpanded = false;
  double _cardHeight = 70;
  final List<Color> _stateColors = [
    StyleSheet().step1,
    StyleSheet().step2,
    StyleSheet().step3,
    StyleSheet().step4,
  ];

  void showContacts() {
    showDialog(
        context: context,
        builder: (context) => ContactsPopup(contacts: widget.contactProfiles));
  }

  @override
  Widget build(BuildContext context) {
    AppSizes().initSizes(context);
    return Container(
      height: _cardHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        color: (widget.isDone &&
                widget.device == "Device") //wait for report(4 step)
            ? _stateColors[3]
            : (widget.isDone &&
                    widget.device !=
                        "Device") // device is still there. but the work is done(3 step)
                ? _stateColors[2]
                : (!widget.isDone &&
                        widget.device == "Device") //No device assigned.(1 step)
                    ? _stateColors[0]
                    : _stateColors[1], //Device is assigned. pending... (2 step)
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
                      _cardHeight = 260;
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
                        const SizedBox(height: 4),
                        CustomButton(
                            label: "View Contacts",
                            icon: Icons.contact_emergency,
                            backgroundColor: StyleSheet().btnBackground,
                            textColor: StyleSheet().btnText,
                            onPressed: () {
                              showContacts();
                            }),
                        const SizedBox(height: 4),
                        CustomButton(
                            label: "View Reports",
                            icon: Icons.history,
                            backgroundColor: StyleSheet().btnBackground,
                            textColor: StyleSheet().btnText,
                            onPressed: () {
                              widget.onViewReport();
                            })
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
                      children: (widget.isDone &&
                              widget.device ==
                                  "Device") //wait for report(4 step)
                          ? [
                              CustomButton(
                                  label: "Create the report",
                                  icon: Icons.create,
                                  backgroundColor: StyleSheet().btnBackground,
                                  textColor: StyleSheet().btnText,
                                  onPressed: () {
                                    widget.onCreateReport();
                                  })
                            ]
                          : (widget.isDone &&
                                  widget.device !=
                                      "Device") // device is still there. but the work is done(3 step)
                              ? [
                                  CustomButton(
                                      label: "Remove the device",
                                      icon: Icons.remove_circle,
                                      backgroundColor:
                                          StyleSheet().patientsDelete,
                                      textColor: StyleSheet().btnText,
                                      onPressed: () {
                                        widget.onRemoveDevice();
                                      })
                                ]
                              : (!widget.isDone &&
                                      widget.device ==
                                          "Device") //No device assigned.(1 step)
                                  ? [
                                      CustomButton(
                                          label: "Add a device",
                                          icon: Icons.add,
                                          backgroundColor:
                                              StyleSheet().btnBackground,
                                          textColor: StyleSheet().btnText,
                                          onPressed: () {
                                            widget.onAddDevice();
                                          })
                                    ]
                                  : [
                                      CustomButton(
                                        label: "Pending...",
                                        icon: Icons.pending_actions,
                                        backgroundColor:
                                            StyleSheet().btnBackground,
                                        textColor: StyleSheet().btnText,
                                        onPressed: () {
                                          widget.onPending();
                                        },
                                      )
                                    ], //Device is assigned. pending... (2 step)
                    ),
                  ],
                )),
        ],
      ),
    );
  }
}
