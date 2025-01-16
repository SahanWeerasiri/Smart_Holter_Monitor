import 'package:health_care/components/buttons/custom_text_button/custom_text_button.dart';
import 'package:health_care/components/text_input/text_input_with_leading_icon.dart';
import 'package:health_care/components/top_app_bar/top_app_bar2.dart';
import 'package:health_care/constants/consts.dart';
import 'package:health_care/controllers/textController.dart';
import 'package:flutter/material.dart';
import 'package:health_care/pages/app/services/auth_service.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
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
    return Scaffold(
      appBar: CustomTopAppBar2(
        title: "Sign up",
        backButton: true,
        backOnPressed: () {
          credentialController.clear();
          Navigator.pop(context);
        },
        titleColor: StyleSheet().topbarText,
        backgroundColor: StyleSheet().topbarBackground,
      ),
      body: SingleChildScrollView(
        child: Container(
          height: AppSizes().getScreenHeight(),
          color: StyleSheet().uiBackground,
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
        ),
      ),
      bottomNavigationBar: null,
    );
  }
}
