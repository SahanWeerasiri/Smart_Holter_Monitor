import 'package:health_care/components/buttons/custom_text_button/custom_text_button.dart';
import 'package:health_care/constants/consts.dart';
import 'package:flutter/material.dart';

class BeforeLogin extends StatelessWidget {
  const BeforeLogin({super.key});

  @override
  Widget build(BuildContext context) {
    AppSizes().initSizes(context);
    return Scaffold(
      appBar: null,
      body: Padding(
        padding: EdgeInsets.all(AppSizes().getBlockSizeHorizontal(15)),
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
      backgroundColor: StyleSheet().uiBackground,
      bottomNavigationBar: null,
    );
  }
}
