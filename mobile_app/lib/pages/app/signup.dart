// import 'package:health_care/components/buttons/custom_text_button/custom_text_button.dart';
// import 'package:health_care/components/text_input/text_input_with_leading_icon.dart';
// import 'package:health_care/components/top_app_bar/top_app_bar2.dart';
// import 'package:health_care/constants/consts.dart';
// import 'package:health_care/controllers/textController.dart';
import 'package:flutter/material.dart';
import 'package:health_care/pages/app/services/auth_service.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  // late final CredentialController credentialController;
  // late final TextStyle textStyleHeading;
  // late final TextStyle textStyleTextInputTopic;
  // late final TextStyle textStyleInputField;
  DateTime? birthday;
  String msg = "";
  bool state = false;
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // void reset() {
  //   _nameController.dispose();
  //   _emailController.dispose();
  //   _passwordController.dispose();
  //   _confirmPasswordController.dispose();
  // }

  Future<void> _signup() async {
    // if (!_formKey.currentState!.validate()) return;

    // final authProvider = Provider.of<AuthProvider>(context, listen: false);
    // final success = await authProvider.register(
    //   _nameController.text.trim(),
    //   _emailController.text.trim(),
    //   _passwordController.text,
    // );

    // if (success && mounted) {
    //   Navigator.of(context).pushReplacement(
    //     MaterialPageRoute(builder: (_) => const HomeScreen()),
    //   );
    // }
    if (_passwordController.text.trim() !=
        _confirmPasswordController.text.trim()) {
      setState(() {
        msg = "Passwords do not match";
        state = false;
      });
      return;
    }
    if (_emailController.text.trim().isEmpty) {
      setState(() {
        msg = "Email is required";
        state = false;
      });
      return;
    }

    if (_passwordController.text.trim().isEmpty) {
      setState(() {
        msg = "Password is required";
        state = false;
      });
      return;
    }

    if (_passwordController.text.trim().length < 8) {
      setState(() {
        msg = "Password required at least 8 characters";
        state = false;
      });
      return;
    }

    if (birthday == "") {
      setState(() {
        msg = "Select your birthday";
        state = false;
      });
      return;
    }

    AuthService auth = AuthService();
    Map<String, dynamic> result = await auth.createUserWithEmailAndPassword(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text.trim(),
        birthday.toString());
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: Colors.green,
        ),
      );
    });
    // reset();
    navigateToHome();
    return;
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
  //   if (credentialController.confirmPassword != credentialController.password) {
  //     setState(() {
  //       msg = "Passwords do not match";
  //     });
  //     return false;
  //   }
  //   if (credentialController.username.isEmpty) {
  //     setState(() {
  //       msg = "Email is required";
  //     });
  //     return false;
  //   }

  //   if (credentialController.password.isEmpty) {
  //     setState(() {
  //       msg = "Password is required";
  //     });
  //     return false;
  //   }

  //   if (credentialController.password.length < 8) {
  //     setState(() {
  //       msg = "Password required at least 8 characters";
  //     });
  //     return false;
  //   }

  //   if (birthday == "") {
  //     setState(() {
  //       msg = "Select your birthday";
  //     });
  //     return false;
  //   }

  //   AuthService auth = AuthService();
  //   Map<String, dynamic> result = await auth.createUserWithEmailAndPassword(
  //       credentialController.name,
  //       credentialController.username,
  //       credentialController.password,
  //       birthday);
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
    // reset();
    Navigator.pushNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
      ),
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
                    size: 60,
                    color: Colors.teal,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Join SmartCare',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Create your account to monitor your heart health',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    readOnly: true,
                    controller: TextEditingController(
                      text: birthday == null
                          ? ''
                          : "${birthday!.day}/${birthday!.month}/${birthday!.year}",
                    ),
                    decoration: InputDecoration(
                      labelText: 'Date of Birth',
                      prefixIcon: const Icon(Icons.calendar_today),
                    ),
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (pickedDate != null && pickedDate != birthday) {
                        setState(() {
                          birthday = pickedDate;
                        });
                      }
                    },
                    validator: (value) {
                      if (birthday == null) {
                        return 'Please select your date of birth';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
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
                        return 'Please enter a password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
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
                    onPressed: isLoading ? null : _signup,
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Sign Up'),
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
