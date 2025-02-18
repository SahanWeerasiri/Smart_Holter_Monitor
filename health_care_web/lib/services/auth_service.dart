import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:health_care_web/models/return_model.dart';
import 'package:health_care_web/services/firestore_db_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreDbService _firestoreDbService =
      FirestoreDbService(); // Inject Firestore service

  Future<ReturnModel> createUserWithEmailAndPassword(
      String name, String email, String password, String role) async {
    try {
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      if (role == "Hospital") {
        return ReturnModel(
            state: true, message: "Hospital created successfully");
      }
      final createAccountResult =
          await _firestoreDbService.createAccount(name, email);
      if (createAccountResult.state) {
        return ReturnModel(
            state: true, message: "Account created successfully");
      } else {
        await _auth.currentUser
            ?.delete(); // Clean up if account creation fails.
        return createAccountResult;
      }
    } on FirebaseAuthException catch (e) {
      return ReturnModel(state: false, message: _handleFirebaseAuthError(e));
    } catch (e) {
      return ReturnModel(state: false, message: 'Error creating user: $e');
    }
  }

  Future<ReturnModel> loginUserWithEmailAndPassword(
      String email, String password, String role) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      if (role == "Doctor") {
        final isDoctorResult = await _firestoreDbService.isDoctor(email);
        if (!isDoctorResult.state) {
          await signout();
          return isDoctorResult;
        }
      } else if (role == "Hospital") {
        final isHospitalResult = await _firestoreDbService.isHospital(email);
        if (!isHospitalResult.state) {
          await signout();
          return isHospitalResult;
        }
      }
      return ReturnModel(state: true, message: "Logged in successfully");
    } on FirebaseAuthException catch (e) {
      return ReturnModel(state: false, message: _handleFirebaseAuthError(e));
    } catch (e) {
      return ReturnModel(state: false, message: 'Error logging in: $e');
    }
  }

  Future<void> signout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      log("Something went wrong during signout: $e");
    }
  }

  String _handleFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided for that user.';
      case 'invalid-email':
        return 'The email address is badly formatted.';
      case 'too-many-requests':
        return 'Too many requests to sign in. Please try again later.';
      case 'user-disabled':
        return 'This user has been disabled.';
      default:
        return 'An unknown error occurred.';
    }
  }
}
