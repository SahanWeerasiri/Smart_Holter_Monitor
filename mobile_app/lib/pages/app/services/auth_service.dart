import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Map<String, dynamic>> createUserWithEmailAndPassword(
      String email, String password) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return {
        "status": "success",
        "message": "Account created successfully",
        "user": cred.user
      };
    } catch (e) {
      return {
        "status": "error",
        "message": e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> loginUserWithEmailAndPassword(
      String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return {
        "status": "success",
        "message": "Logged in successfully",
        "user": cred.user
      };
    } catch (e) {
      return {
        "status": "error",
        "message": e.toString(),
      };
    }
  }

  Future<void> signout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      log("Something went wrong");
    }
  }
}
