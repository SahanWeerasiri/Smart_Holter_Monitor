import 'package:flutter/material.dart';
import 'package:health_care_web/app/components/cards/signup_card.dart';
import 'package:health_care_web/models/style_sheet.dart';

class DoctorSignupSection extends StatelessWidget {
  const DoctorSignupSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: StyleSheet.uiBackground,
      child: SignupCard(),
    );
  }
}
