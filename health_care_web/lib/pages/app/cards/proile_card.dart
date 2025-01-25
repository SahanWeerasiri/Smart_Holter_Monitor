import 'package:flutter/material.dart';
import 'package:health_care_web/constants/consts.dart';

class ProfileCard extends StatefulWidget {
  final UserProfile profile;
  final VoidCallback onClick;
  const ProfileCard({super.key, required this.profile, required this.onClick});

  @override
  State createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
        onFocusChange: (value) {},
        autofocus: false,
        onHover: (value) {},
        onPressed: () => {widget.onClick},
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  StyleSheet().bottomNavigationBase,
                  StyleSheet().bottomNavigationShadow,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // CircleAvatar(
                //   radius: 50,
                //   backgroundImage: NetworkImage(
                //     widget.profile.pic == ""
                //         ? "https://via.placeholder.com/150"
                //         : widget.profile.pic, // Replace with your image URL
                //   ),
                // ),
                const SizedBox(height: 20),
                Text(
                  widget.profile.name == ""
                      ? "Sahan Lahiru"
                      : widget.profile.name,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.profile.mobile == ""
                      ? "0776053830"
                      : widget.profile.mobile,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
