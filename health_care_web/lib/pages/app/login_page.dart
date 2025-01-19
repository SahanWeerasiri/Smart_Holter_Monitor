import 'package:health_care_web/constants/consts.dart';
import 'package:health_care_web/controllers/textController.dart';
import 'package:flutter/material.dart';
import 'package:health_care_web/pages/app/cards/login_card.dart';
import 'package:health_care_web/pages/app/services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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
    setState(() {
      credentialController.clear();
    });
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
    setState(() {
      credentialController.clear();
    });
    Navigator.pushNamed(context, '/home');
  }

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
