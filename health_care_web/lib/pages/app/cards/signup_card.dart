import 'package:health_care_web/components/buttons/custom_text_button/custom_text_button.dart';
import 'package:health_care_web/components/text_input/text_input_with_leading_icon.dart';
import 'package:health_care_web/constants/consts.dart';
import 'package:health_care_web/controllers/textController.dart';
import 'package:flutter/material.dart';
import 'package:health_care_web/pages/app/services/auth_service.dart';

class SignupCard extends StatefulWidget {
  const SignupCard({super.key});

  @override
  State<SignupCard> createState() => _SignupCardState();
}

class _SignupCardState extends State<SignupCard> {
  late final CredentialController credentialController;
  late final TextStyle textStyleHeading;
  late final TextStyle textStyleTextInputTopic;
  late final TextStyle textStyleInputField;
  String msg = "";

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

  Future<bool> checkCredentials() async {
    if (credentialController.confirmPassword != credentialController.password) {
      setState(() {
        msg = "Passwords do not match";
      });
      return false;
    }
    if (credentialController.username.isEmpty) {
      setState(() {
        msg = "Email is required";
      });
      return false;
    }

    if (credentialController.password.isEmpty) {
      setState(() {
        msg = "Password is required";
      });
      return false;
    }

    if (credentialController.password.length < 8) {
      setState(() {
        msg = "Password required at least 8 characters";
      });
      return false;
    }

    AuthService auth = AuthService();
    Map<String, dynamic> result = await auth.createUserWithEmailAndPassword(
        credentialController.name,
        credentialController.username,
        credentialController.password);
    if (result["status"] == "error") {
      setState(() {
        msg = result["message"];
      });
      return false;
    }
    setState(() {
      msg = result["message"];
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: Colors.green,
        ),
      );
    });
    return true;
  }

  void signUpError() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: Colors.red,
        ),
      );
    });
  }

  void navigateToHome() {
    credentialController.clear();
    Navigator.pushNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    AppSizes appSizes = AppSizes();
    appSizes.initSizes(context);
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
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: AppSizes().getBlockSizeVertical(5),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "Name",
                      style: textStyleTextInputTopic,
                    )
                  ],
                ),
                SizedBox(
                  height: AppSizes().getBlockSizeVertical(1),
                ),
                InputFieldFb3(
                    inputController: credentialController,
                    hint: "Name",
                    icon: Icons.person,
                    hintColor: StyleSheet().greyHint,
                    textColor: StyleSheet().text,
                    shadowColor: StyleSheet().textBackground,
                    enableBorderColor: StyleSheet().disabledBorder,
                    borderColor: StyleSheet().greyHint,
                    focusedBorderColor: StyleSheet().enableBorder,
                    typeKey: CustomTextInputTypes().name),
                SizedBox(
                  height: AppSizes().getBlockSizeVertical(3),
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
                SizedBox(
                  height: AppSizes().getBlockSizeVertical(1),
                ),
                InputFieldFb3(
                    inputController: credentialController,
                    hint: "Email",
                    icon: Icons.email,
                    hintColor: StyleSheet().greyHint,
                    textColor: StyleSheet().text,
                    shadowColor: StyleSheet().textBackground,
                    enableBorderColor: StyleSheet().disabledBorder,
                    borderColor: StyleSheet().greyHint,
                    focusedBorderColor: StyleSheet().enableBorder,
                    typeKey: CustomTextInputTypes().username),
                SizedBox(
                  height: AppSizes().getBlockSizeVertical(3),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [Text("Password", style: textStyleTextInputTopic)],
                ),
                SizedBox(
                  height: AppSizes().getBlockSizeVertical(1),
                ),
                InputFieldFb3(
                    inputController: credentialController,
                    hint: "Password",
                    icon: Icons.key,
                    hintColor: StyleSheet().greyHint,
                    textColor: StyleSheet().text,
                    shadowColor: StyleSheet().textBackground,
                    enableBorderColor: StyleSheet().disabledBorder,
                    borderColor: StyleSheet().greyHint,
                    focusedBorderColor: StyleSheet().enableBorder,
                    isPassword: true,
                    typeKey: CustomTextInputTypes().password),
                SizedBox(
                  height: AppSizes().getBlockSizeVertical(3),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text("Confirm Password", style: textStyleTextInputTopic)
                  ],
                ),
                SizedBox(
                  height: AppSizes().getBlockSizeVertical(1),
                ),
                InputFieldFb3(
                    inputController: credentialController,
                    hint: "Confirm Password",
                    icon: Icons.key,
                    hintColor: StyleSheet().greyHint,
                    textColor: StyleSheet().text,
                    shadowColor: StyleSheet().textBackground,
                    enableBorderColor: StyleSheet().disabledBorder,
                    borderColor: StyleSheet().greyHint,
                    focusedBorderColor: StyleSheet().enableBorder,
                    isPassword: true,
                    typeKey: CustomTextInputTypes().confirmPassword),
                SizedBox(
                  height: AppSizes().getBlockSizeVertical(5),
                ),
                CustomTextButton(
                  label: "Sign Up",
                  onPressed: () async {
                    if (await checkCredentials()) {
                      navigateToHome();
                    } else {
                      signUpError();
                    }
                  },
                  backgroundColor: StyleSheet().btnBackground,
                  textColor: StyleSheet().btnText,
                  icon: Icons.login,
                ),
              ],
            ),
          ),
        ));
  }
}
