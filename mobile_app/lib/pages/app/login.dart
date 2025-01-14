import 'package:health_care/components/buttons/custom_button_1/custom_button.dart';
import 'package:health_care/components/dialogues/simple_dialogue.dart';
import 'package:health_care/components/text_input/text_input_with_leading_icon.dart';
import 'package:health_care/components/top_app_bar/top_app_bar2.dart';
import 'package:health_care/constants/consts.dart';
import 'package:health_care/controllers/textController.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  late final CredentialController credentialController;
  late final TextStyle textStyleHeading;
  late final TextStyle textStyleTextInputTopic;
  late final TextStyle textStyleInputField;

  @override
  void initState() {
    super.initState();
    credentialController = CredentialController();
    textStyleHeading = TextStyle(
        color: CustomColors().blue, fontSize: 30, fontWeight: FontWeight.bold);
    textStyleTextInputTopic = const TextStyle(
        color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold);
    textStyleInputField = TextStyle(
        color: CustomColors().blueDark,
        fontSize: 15,
        fontWeight: FontWeight.bold);
  }

  bool checkCredentials() {
    return true;
  }

  void navigateToSignUp() {
    credentialController.clear();
    Navigator.pushNamed(context, '/signup');
  }

  void loginError() {
    showDialog(
        context: context,
        builder: (context) => DialogFb2(
              text: "Login Error!",
              subText: "Try Again",
              icon: Icons.error,
              basicColor: Colors.white,
              fontColor: Colors.red,
              subTextFontColor: CustomColors().greyHint,
              backgroundColor: Colors.white,
              onPressed: () {
                Navigator.pop(context);
              },
              btnText: "Close",
              btnBackColor: CustomColors().blue,
              btnTextColor: Colors.white,
            ));
  }

  void navigateToHome() {
    credentialController.clear();
    Navigator.pushNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    AppSizes().initSizes(context);
    return Scaffold(
      appBar: CustomTopAppBar2(
        title: "Sign In",
        backButton: true,
        backgroundColor: Colors.white,
        titleColor: Colors.black,
        backOnPressed: () {},
      ),
      body: SingleChildScrollView(
        child: Container(
          height: AppSizes().getScreenHeight(),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Sign In",
                  style: textStyleHeading,
                ),
                SizedBox(
                  height: 5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "Email",
                      style: textStyleTextInputTopic,
                    )
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),
                InputFieldFb3(
                    inputController: credentialController,
                    hint: "Email",
                    icon: Icons.email,
                    hintColor: CustomColors().greyHint,
                    textColor: CustomColors().blueDark,
                    shadowColor: CustomColors().blueLighter,
                    enableBorderColor: CustomColors().blueLight,
                    borderColor: CustomColors().blueDark,
                    focusedBorderColor: CustomColors().blueDark,
                    typeKey: CustomTextInputTypes().username),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [Text("Password", style: textStyleTextInputTopic)],
                ),
                const SizedBox(
                  height: 5,
                ),
                InputFieldFb3(
                    inputController: CredentialController(),
                    hint: "Password",
                    icon: Icons.key,
                    hintColor: CustomColors().greyHint,
                    textColor: CustomColors().blueDark,
                    shadowColor: CustomColors().blueLighter,
                    enableBorderColor: CustomColors().blueLight,
                    borderColor: CustomColors().blueDark,
                    focusedBorderColor: CustomColors().blueDark,
                    isPassword: true,
                    typeKey: CustomTextInputTypes().password),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CustomButton(
                      label: "Sign In",
                      onPressed: () {
                        if (checkCredentials()) {
                          navigateToHome();
                        } else {
                          loginError();
                        }
                      },
                      backgroundColor: CustomColors().blue,
                      textColor: Colors.white,
                      icon: Icons.login,
                    )
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Divider(
                  color: CustomColors().greyHint,
                  endIndent: 5,
                  height: 2,
                  thickness: 2,
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: AppSizes.blockSizeHorizontal * 10,
                  children: [
                    CustomButton(
                      label: "Google",
                      onPressed: () {},
                      icon: Icons.g_mobiledata_rounded,
                      textColor: Colors.white,
                      backgroundColor: CustomColors().blue,
                    ),
                    CustomButton(
                      label: "Facebook",
                      onPressed: () {},
                      icon: Icons.facebook_rounded,
                      textColor: Colors.white,
                      backgroundColor: CustomColors().blue,
                    ),
                  ],
                ),
                Divider(
                  color: CustomColors().greyHint,
                  endIndent: 5,
                  thickness: 2,
                ),
                const SizedBox(
                  height: 10,
                ),
                const Text("Don't you have an account?"),
                CustomButton(
                    label: "Sign up",
                    backgroundColor: CustomColors().blue,
                    textColor: Colors.white,
                    icon: Icons.create,
                    onPressed: () {
                      navigateToSignUp();
                    }),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: null,
    );
  }
}
