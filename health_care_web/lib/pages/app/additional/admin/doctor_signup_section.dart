import 'package:flutter/material.dart';
import 'package:health_care_web/constants/consts.dart';
import 'package:health_care_web/pages/app/cards/signup_card.dart';

class DoctorSignupSection extends StatelessWidget {
  const DoctorSignupSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: StyleSheet().uiBackground,
      child: SignupCard(),
    );
  }
}
