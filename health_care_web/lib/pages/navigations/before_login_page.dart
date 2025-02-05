import 'package:flutter/material.dart';
import 'package:health_care_web/app/components/cards/before_login_card.dart';
import 'package:health_care_web/models/app_sizes.dart';
import 'package:health_care_web/models/style_sheet.dart';

class BeforeLoginPage extends StatelessWidget {
  const BeforeLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    AppSizes().initSizes(context);
    return Scaffold(
        backgroundColor: StyleSheet.uiBackground,
        body: Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assetes/icons/back.png'),
                    fit: BoxFit.cover)),
            child: Center(
                child: Padding(
                    padding: EdgeInsets.only(
                        top: AppSizes().getBlockSizeVertical(10),
                        bottom: AppSizes().getBlockSizeVertical(10),
                        left: AppSizes().getBlockSizeHorizontal(10)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [BeforeLoginCard()],
                    )))));
  }
}
