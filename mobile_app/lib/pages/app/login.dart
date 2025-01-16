import 'package:health_care/components/buttons/custom_text_button/custom_text_button.dart';
import 'package:health_care/components/text_input/text_input_with_leading_icon.dart';
import 'package:health_care/components/top_app_bar/top_app_bar2.dart';
import 'package:health_care/constants/consts.dart';
import 'package:health_care/controllers/textController.dart';
import 'package:flutter/material.dart';
import 'package:health_care/pages/app/services/auth_service.dart';

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

  @override
  void dispose() {
    super.dispose();
    credentialController.clear();
  }

  Future<bool> checkCredentials() async {
    AuthService auth = AuthService();
    Map<String, dynamic> result = await auth.loginUserWithEmailAndPassword(
        credentialController.username, credentialController.password);
    if (result["status"] == "error") {
      setState(() {
        msg = result["message"];
      });
      return false;
    }
    setState(() {
      msg = result["message"];
    });
    credentialController.clear();
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

  Future<bool> checkGoogleCredentials() async {
    AuthService auth = AuthService();

    Map<String, dynamic> result = await auth.signUpWithGoogle();
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

  // bool checkFacebookCredentials() {
  //   return true;
  // }

  void navigateToSignUp() {
    credentialController.clear();
    Navigator.pushNamed(context, '/signup');
  }

  void loginError() {
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
    Navigator.pushNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    AppSizes().initSizes(context);
    return Scaffold(
      appBar: CustomTopAppBar2(
        title: "Sign In",
        backButton: true,
        backgroundColor: StyleSheet().topbarBackground,
        titleColor: StyleSheet().topbarText,
        backOnPressed: () {
          Navigator.pop(context);
        },
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
                  height: AppSizes().getBlockSizeVertical(5),
                ),
                CustomTextButton(
                  label: "Sign In",
                  onPressed: () async {
                    if (await checkCredentials()) {
                      navigateToHome();
                    } else {
                      loginError();
                    }
                  },
                  backgroundColor: StyleSheet().btnBackground,
                  textColor: StyleSheet().btnText,
                  icon: Icons.login,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text("Don't you have an account?",
                        style: TextStyle(
                          fontSize: 15,
                        )),
                    TextButton(
                        child: Text(
                          "Sign up",
                          style: TextStyle(
                              fontSize: 15,
                              color: StyleSheet().btnBackground,
                              fontWeight: FontWeight.w900),
                        ),
                        onPressed: () {
                          navigateToSignUp();
                        }),
                  ],
                ),
                SizedBox(
                  height: AppSizes().getBlockSizeVertical(5),
                ),
                Divider(
                  color: StyleSheet().divider,
                  endIndent: 5,
                  height: 2,
                  thickness: 2,
                ),
                SizedBox(
                  height: AppSizes().getBlockSizeVertical(5),
                ),
                CustomTextButton(
                  label: "Sign in with Google",
                  borderRadius: 5,
                  onPressed: () async {
                    if (await checkGoogleCredentials()) {
                      navigateToHome();
                    } else {
                      loginError();
                    }
                  },
                  borderColor: StyleSheet().elebtnBorder,
                  img: 'assetes/icons/google.png',
                  textColor: StyleSheet().elebtnText,
                  backgroundColor: StyleSheet().uiBackground,
                ),
                // SizedBox(
                //   height: AppSizes().getBlockSizeVertical(2),
                // ),
                // CustomTextButton(
                //   borderRadius: 5,
                //   label: "Sign in with Facebook",
                //   onPressed: () {},
                //   img: 'assetes/icons/facebook.png',
                //   textColor: StyleSheet().elebtnText,
                //   backgroundColor: StyleSheet().uiBackground,
                //   borderColor: StyleSheet().elebtnBorder,
                // ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: null,
    );
  }
}
