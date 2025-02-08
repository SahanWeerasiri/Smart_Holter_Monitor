import 'package:flutter/material.dart';
import 'package:health_care_web/pages/cards/login_card.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    AppSizes().initSizes(context);
    return Scaffold(
        backgroundColor: StyleSheet().uiBackground,
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
                      children: [LoginCard()],
                    )))));
  }
}
