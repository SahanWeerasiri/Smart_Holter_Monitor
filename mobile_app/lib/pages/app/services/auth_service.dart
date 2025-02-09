import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:health_care/pages/app/services/firestore_db_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Map<String, dynamic>> createUserWithEmailAndPassword(
      String name, String email, String password, String birthday) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      Map<String, dynamic> res =
          await FirestoreDbService().createAccount(name, email, birthday);
      if (res['success']) {
        return {
          "status": "success",
          "message": "Account created successfully",
          "user": cred.user
        };
      } else {
        throw Exception(res["error"]);
      }
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

  Future<Map<String, dynamic>> signWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;
      final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth?.accessToken, idToken: googleAuth?.idToken);
      final userCredential = await _auth.signInWithCredential(credential);
      return {
        "status": "success",
        "message": "Logged in successfully",
        "user": userCredential.user
      };
    } catch (e) {
      return {
        "status": "error",
        "message": e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> signUpWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      // You can check if the user is new or existing
      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        return {
          "status": "success",
          "message": "Account created successfully",
          "user": userCredential.user,
        };
      } else {
        return {
          "status": "success",
          "message": "Logged in successfully",
          "user": userCredential.user,
        };
      }
    } catch (e) {
      return {
        "status": "error",
        "message": e.toString(),
      };
    }
  }
}
