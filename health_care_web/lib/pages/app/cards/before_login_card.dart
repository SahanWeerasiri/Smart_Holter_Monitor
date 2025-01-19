import 'package:health_care_web/components/buttons/custom_text_button/custom_text_button.dart';
import 'package:health_care_web/constants/consts.dart';
import 'package:flutter/material.dart';

class BeforeLoginCard extends StatelessWidget {
  const BeforeLoginCard({super.key});

  @override
  Widget build(BuildContext context) {
    AppSizes().initSizes(context);
    return SizedBox(
        width: 350,
        height: AppSizes().getBlockSizeVertical(80),
        child: Container(
          decoration: BoxDecoration(
              color: StyleSheet().uiBackground,
              borderRadius: BorderRadius.all(Radius.circular(20)),
              boxShadow: List.of([
                BoxShadow(
                  color: Colors.black,
                  blurRadius: 20,
                )
              ])),
          child: Padding(
            padding: EdgeInsets.all(AppSizes().getBlockSizeVertical(2)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: AppSizes().getBlockSizeVertical(20),
                  child: Image.asset(
                    'assetes/icons/logo.png', // Assuming `img` is a String path to an asset
                  ),
                ),
                Text("Smart Care",
                    style: TextStyle(
                      color: StyleSheet().titleText,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    )),
                SizedBox(
                  height: AppSizes().getBlockSizeVertical(3),
                ),
                Text(
                  "Let's get started!",
                  style: TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                Text(
                  "Login to stay healthy and fit",
                  style: TextStyle(
                    fontSize: 17,
                    color: StyleSheet().titleSupport,
                  ),
                ),
                SizedBox(
                  height: AppSizes().getBlockSizeVertical(3),
                ),
                CustomTextButton(
                  label: "Login",
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  backgroundColor: StyleSheet().btnBackground,
                  textColor: StyleSheet().btnText,
                ),
                SizedBox(
                  height: AppSizes().getBlockSizeVertical(1),
                ),
                CustomTextButton(
                  label: "Sign Up",
                  onPressed: () {
                    Navigator.pushNamed(context, '/signup');
                  },
                  backgroundColor: StyleSheet().uiBackground,
                  borderColor: StyleSheet().btnBackground,
                  textColor: StyleSheet().btnBackground,
                )
              ],
            ),
          ),
        ));
  }
}
