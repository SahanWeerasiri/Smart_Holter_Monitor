import 'package:health_care_web/components/buttons/custom_text_button/custom_text_button.dart';
import 'package:health_care_web/components/dropdown/CustomDropDown.dart';
import 'package:health_care_web/components/text_input/text_input_with_leading_icon.dart';
import 'package:health_care_web/controllers/textController.dart';
import 'package:flutter/material.dart';
import 'package:health_care_web/models/app_sizes.dart';
import 'package:health_care_web/models/custom_text_input_types.dart';
import 'package:health_care_web/models/return_model.dart';
import 'package:health_care_web/models/style_sheet.dart';
import 'package:health_care_web/services/auth_service.dart';

class LoginCard extends StatefulWidget {
  const LoginCard({super.key});

  @override
  State<LoginCard> createState() => _LoginCardState();
}

class _LoginCardState extends State<LoginCard> {
  late final CredentialController credentialController;
  late final TextStyle textStyleHeading;
  late final TextStyle textStyleTextInputTopic;
  late final TextStyle textStyleInputField;
  String role = "";
  String msg = "";

  @override
  void initState() {
    super.initState();
    credentialController = CredentialController();
    textStyleHeading = TextStyle(
        color: StyleSheet.btnBackground,
        fontSize: 30,
        fontWeight: FontWeight.bold);
    textStyleTextInputTopic = const TextStyle(
        color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold);
    textStyleInputField = TextStyle(
        color: StyleSheet.btnBackground,
        fontSize: 15,
        fontWeight: FontWeight.bold);
  }

  Future<bool> checkCredentials() async {
    AuthService auth = AuthService();
    ReturnModel result = await auth.loginUserWithEmailAndPassword(
        credentialController.username, credentialController.password, role);
    if (!result.state) {
      setState(() {
        msg = result.message;
      });
      return false;
    }
    setState(() {
      msg = result.message;
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
    setState(() {
      credentialController.clear();
    });
    Navigator.pushNamed(context, '/home');
  }

  void navigateToAdmin() {
    setState(() {
      credentialController.clear();
    });
    Navigator.pushNamed(context, '/admin_dashboard');
  }

  void navigateToHospital() {
    setState(() {
      credentialController.clear();
    });
    Navigator.pushNamed(context, '/hospital_dashboard');
  }

  void onDropDownSelected(value) {
    setState(() {
      role = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    AppSizes().initSizes(context);
    return SizedBox(
        width: 350,
        height: AppSizes().getBlockSizeVertical(70),
        child: Container(
          decoration: BoxDecoration(
              color: StyleSheet.uiBackground,
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
                    hintColor: StyleSheet.greyHint,
                    textColor: StyleSheet.text,
                    shadowColor: StyleSheet.textBackground,
                    enableBorderColor: StyleSheet.disabledBorder,
                    borderColor: StyleSheet.greyHint,
                    focusedBorderColor: StyleSheet.enableBorder,
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
                    hintColor: StyleSheet.greyHint,
                    textColor: StyleSheet.text,
                    shadowColor: StyleSheet.textBackground,
                    enableBorderColor: StyleSheet.disabledBorder,
                    borderColor: StyleSheet.greyHint,
                    focusedBorderColor: StyleSheet.enableBorder,
                    isPassword: true,
                    typeKey: CustomTextInputTypes().password),
                SizedBox(
                  height: AppSizes().getBlockSizeVertical(5),
                ),
                CustomDropdown(
                    label: 'Role',
                    options: ['Doctor', 'Admin', 'Hospital'],
                    onChanged: onDropDownSelected),
                SizedBox(
                  height: AppSizes().getBlockSizeVertical(5),
                ),
                CustomTextButton(
                  label: "Sign In",
                  onPressed: () async {
                    if (await checkCredentials()) {
                      setState(() {
                        credentialController.clear();
                      });
                      if (role == "Admin") {
                        navigateToAdmin();
                      } else if (role == "Hospital") {
                        navigateToHospital();
                      } else {
                        navigateToHome();
                      }
                    } else {
                      loginError();
                    }
                  },
                  backgroundColor: StyleSheet.btnBackground,
                  textColor: StyleSheet.btnText,
                  icon: Icons.login,
                ),
                CustomTextButton(
                  label: "Doctor",
                  onPressed: () async {
                    setState(() {
                      credentialController.username = "doctor@smartcare.com";
                      credentialController.password = "doctor123";
                      role = "Doctor";
                    });
                    if (await checkCredentials()) {
                      setState(() {
                        credentialController.clear();
                      });
                      if (role == "Admin") {
                        navigateToAdmin();
                      } else {
                        navigateToHome();
                      }
                    } else {
                      loginError();
                    }
                  },
                  backgroundColor: StyleSheet.btnBackground,
                  textColor: StyleSheet.btnText,
                  icon: Icons.login,
                ),
                CustomTextButton(
                  label: "Admin",
                  onPressed: () async {
                    setState(() {
                      credentialController.username = "admin@smartcare.com";
                      credentialController.password = "admin123";
                      role = "Admin";
                    });
                    if (await checkCredentials()) {
                      setState(() {
                        credentialController.clear();
                      });
                      if (role == "Admin") {
                        navigateToAdmin();
                      } else {
                        navigateToHome();
                      }
                    } else {
                      loginError();
                    }
                  },
                  backgroundColor: StyleSheet.btnBackground,
                  textColor: StyleSheet.btnText,
                  icon: Icons.login,
                ),
                CustomTextButton(
                  label: "Hospital",
                  onPressed: () async {
                    setState(() {
                      credentialController.username = "hospital@smartcare.com";
                      credentialController.password = "hospital123";
                      role = "Hospital";
                    });
                    if (await checkCredentials()) {
                      setState(() {
                        credentialController.clear();
                      });
                      if (role == "Admin") {
                        navigateToAdmin();
                      } else if (role == "Hospital") {
                        navigateToHospital();
                      } else {
                        navigateToHome();
                      }
                    } else {
                      loginError();
                    }
                  },
                  backgroundColor: StyleSheet.btnBackground,
                  textColor: StyleSheet.btnText,
                  icon: Icons.login,
                ),
                SizedBox(
                  height: AppSizes().getBlockSizeVertical(5),
                ),
              ],
            ),
          ),
        ));
  }
}
