import 'package:flutter/material.dart';
import 'package:health_care_web/constants/consts.dart';

class ExpandableProfileCardUpdated extends StatefulWidget {
  final String name;
  final String profilePic;
  final String email;
  final String address;
  final String mobile;
  final String device;
  final String docId;
  final String myId;

  const ExpandableProfileCardUpdated({
    super.key,
    required this.name,
    required this.profilePic,
    required this.email,
    required this.address,
    required this.mobile,
    required this.device,
    required this.docId,
    required this.myId,
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
    StyleSheet().stateHeartBoxGood,
    StyleSheet().avgHeartBox
  ];

  @override
  Widget build(BuildContext context) {
    AppSizes().initSizes(context);
    return Container(
      height: _cardHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        color: widget.docId == widget.myId ? _stateColors[0] : _stateColors[1],
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
                  ],
                )),
        ],
      ),
    );
  }
}
