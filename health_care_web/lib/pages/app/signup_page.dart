import 'package:health_care_web/constants/consts.dart';
import 'package:health_care_web/controllers/textController.dart';
import 'package:flutter/material.dart';
import 'package:health_care_web/pages/app/cards/signup_card.dart';
import 'package:health_care_web/pages/app/services/auth_service.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
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
                      children: [SignupCard()],
                    )))));
  }
}
