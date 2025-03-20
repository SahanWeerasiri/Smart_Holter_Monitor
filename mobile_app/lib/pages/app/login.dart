import 'package:flutter/material.dart';
import 'package:health_care/pages/app/signup.dart';
import 'package:health_care/pages/app/services/auth_service.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  // late final CredentialController credentialController;
  // late final TextStyle textStyleHeading;
  // late final TextStyle textStyleTextInputTopic;
  // late final TextStyle textStyleInputField;
  String msg = "";
  bool state = true;
  bool isLoading = false;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // @override
  // void initState() {
  //   super.initState();
  //   credentialController = CredentialController();
  //   textStyleHeading = TextStyle(
  //       color: CustomColors().blue, fontSize: 30, fontWeight: FontWeight.bold);
  //   textStyleTextInputTopic = const TextStyle(
  //       color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold);
  //   textStyleInputField = TextStyle(
  //       color: CustomColors().blueDark,
  //       fontSize: 15,
  //       fontWeight: FontWeight.bold);
  // }

  // Future<bool> checkCredentials() async {
  //   AuthService auth = AuthService();
  //   Map<String, dynamic> result = await auth.loginUserWithEmailAndPassword(
  //       credentialController.username, credentialController.password);
  //   if (result["status"] == "error") {
  //     setState(() {
  //       msg = result["message"];
  //     });
  //     return false;
  //   }
  //   setState(() {
  //     msg = result["message"];
  //   });
  //   credentialController.clear();
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text(msg),
  //         backgroundColor: Colors.green,
  //       ),
  //     );
  //   });
  //   return true;
  // }

  // Future<bool> checkGoogleCredentials() async {
  //   AuthService auth = AuthService();

  //   Map<String, dynamic> result = await auth.signUpWithGoogle();
  //   if (result["status"] == "error") {
  //     setState(() {
  //       msg = result["message"];
  //     });
  //     return false;
  //   }
  //   setState(() {
  //     msg = result["message"];
  //   });
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text(msg),
  //         backgroundColor: Colors.green,
  //       ),
  //     );
  //   });
  //   return true;
  // }

  // bool checkFacebookCredentials() {
  //   return true;
  // }

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
    // setState(() {
    //   _emailController.dispose();
    //   _passwordController.dispose();
    // });
    Navigator.pushNamed(context, '/home');
  }

//   @override
//   Widget build(BuildContext context) {
//     AppSizes().initSizes(context);
//     return Scaffold(
//       appBar: CustomTopAppBar2(
//         title: "Sign In",
//         backButton: true,
//         backgroundColor: StyleSheet().topbarBackground,
//         titleColor: StyleSheet().topbarText,
//         backOnPressed: () {
//           Navigator.pop(context);
//         },
//       ),
//       body: SingleChildScrollView(
//         child: Container(
//           height: AppSizes().getScreenHeight(),
//           color: StyleSheet().uiBackground,
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.start,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 SizedBox(
//                   height: AppSizes().getBlockSizeVertical(5),
//                 ),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   children: [
//                     Text(
//                       "Email",
//                       style: textStyleTextInputTopic,
//                     )
//                   ],
//                 ),
//                 SizedBox(
//                   height: AppSizes().getBlockSizeVertical(1),
//                 ),
//                 InputFieldFb3(
//                     inputController: credentialController,
//                     hint: "Email",
//                     icon: Icons.email,
//                     hintColor: StyleSheet().greyHint,
//                     textColor: StyleSheet().text,
//                     shadowColor: StyleSheet().textBackground,
//                     enableBorderColor: StyleSheet().disabledBorder,
//                     borderColor: StyleSheet().greyHint,
//                     focusedBorderColor: StyleSheet().enableBorder,
//                     typeKey: CustomTextInputTypes().username),
//                 SizedBox(
//                   height: AppSizes().getBlockSizeVertical(3),
//                 ),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   children: [Text("Password", style: textStyleTextInputTopic)],
//                 ),
//                 SizedBox(
//                   height: AppSizes().getBlockSizeVertical(1),
//                 ),
//                 InputFieldFb3(
//                     inputController: credentialController,
//                     hint: "Password",
//                     icon: Icons.key,
//                     hintColor: StyleSheet().greyHint,
//                     textColor: StyleSheet().text,
//                     shadowColor: StyleSheet().textBackground,
//                     enableBorderColor: StyleSheet().disabledBorder,
//                     borderColor: StyleSheet().greyHint,
//                     focusedBorderColor: StyleSheet().enableBorder,
//                     isPassword: true,
//                     typeKey: CustomTextInputTypes().password),
//                 SizedBox(
//                   height: AppSizes().getBlockSizeVertical(5),
//                 ),
//                 CustomTextButton(
//                   label: "Sign In",
//                   onPressed: () async {
//                     if (await checkCredentials()) {
//                       setState(() {
//                         credentialController.clear();
//                       });
//                       navigateToHome();
//                     } else {
//                       loginError();
//                     }
//                   },
//                   backgroundColor: StyleSheet().btnBackground,
//                   textColor: StyleSheet().btnText,
//                   icon: Icons.login,
//                 ),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     const Text("Don't you have an account?",
//                         style: TextStyle(
//                           fontSize: 15,
//                         )),
//                     TextButton(
//                         child: Text(
//                           "Sign up",
//                           style: TextStyle(
//                               fontSize: 15,
//                               color: StyleSheet().btnBackground,
//                               fontWeight: FontWeight.w900),
//                         ),
//                         onPressed: () {
//                           setState(() {
//                             credentialController.clear();
//                           });
//                           navigateToSignUp();
//                         }),
//                   ],
//                 ),
//                 SizedBox(
//                   height: AppSizes().getBlockSizeVertical(5),
//                 ),
//                 Divider(
//                   color: StyleSheet().divider,
//                   endIndent: 5,
//                   height: 2,
//                   thickness: 2,
//                 ),
//                 SizedBox(
//                   height: AppSizes().getBlockSizeVertical(5),
//                 ),
//                 CustomTextButton(
//                   label: "Sign in with Google",
//                   borderRadius: 5,
//                   onPressed: () async {
//                     if (await checkGoogleCredentials()) {
//                       setState(() {
//                         credentialController.clear();
//                       });
//                       navigateToHome();
//                     } else {
//                       loginError();
//                     }
//                   },
//                   borderColor: StyleSheet().elebtnBorder,
//                   img: 'assetes/icons/google.png',
//                   textColor: StyleSheet().elebtnText,
//                   backgroundColor: StyleSheet().uiBackground,
//                 ),
//                 // SizedBox(
//                 //   height: AppSizes().getBlockSizeVertical(2),
//                 // ),
//                 // CustomTextButton(
//                 //   borderRadius: 5,
//                 //   label: "Sign in with Facebook",
//                 //   onPressed: () {},
//                 //   img: 'assetes/icons/facebook.png',
//                 //   textColor: StyleSheet().elebtnText,
//                 //   backgroundColor: StyleSheet().uiBackground,
//                 //   borderColor: StyleSheet().elebtnBorder,
//                 // ),
//               ],
//             ),
//           ),
//         ),
//       ),
//       bottomNavigationBar: null,
//     );
//   }
// }

  Future<void> _login() async {
    // if (!_formKey.currentState!.validate()) return;

    // final authProvider = Provider.of<AuthProvider>(context, listen: false);
    // final success = await authProvider.login(
    //   _emailController.text.trim(),
    //   _passwordController.text,
    // );

    // if (success && mounted) {
    //   Navigator.of(context).pushReplacement(
    //     MaterialPageRoute(builder: (_) => const HomeScreen()),
    //   );
    // }
    AuthService auth = AuthService();
    Map<String, dynamic> result = await auth.loginUserWithEmailAndPassword(
        _emailController.text.trim(), _passwordController.text.trim());
    if (result["status"] == "error") {
      setState(() {
        msg = result["message"];
        state = false;
      });
      return;
    }
    setState(() {
      msg = result["message"];
      state = true;
    });
    // _emailController.dispose();
    // _passwordController.dispose();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: Colors.green,
        ),
      );
    });
    setState(() {
      isLoading = false;
    });
    navigateToHome();
    return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.favorite,
                    size: 80,
                    color: Colors.teal,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'SmartCare',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Login to your account',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  if (msg.isNotEmpty && !state)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        msg,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ElevatedButton(
                    onPressed: isLoading ? null : _login,
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Login'),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account?"),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const Signup()),
                          );
                        },
                        child: const Text('Sign Up'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
