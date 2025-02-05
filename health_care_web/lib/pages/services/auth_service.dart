import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:health_care_web/pages/services/firestore_db_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Map<String, dynamic>> createUserWithEmailAndPassword(
      String name, String email, String password) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      Map<String, dynamic> res =
          await FirestoreDbService().createAccount(name, email);
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
      String email, String password, String role) async {
    if (role == "Doctor") {
      try {
        final cred = await _auth.signInWithEmailAndPassword(
            email: email, password: password);

        final Map<String, dynamic> res =
            await FirestoreDbService().isDoctor(email);
        if (!res['success']) {
          await signout();
          return {
            "status": "error",
            "message": res['error'],
          };
        }
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
    if (role != "Admin") {
      return {
        "status": "error",
        "message": "Select a role",
      };
    }
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

  // Future<Map<String, dynamic>> signWithGoogle() async {
  //   try {
  //     final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
  //     final GoogleSignInAuthentication? googleAuth =
  //         await googleUser?.authentication;
  //     final credential = GoogleAuthProvider.credential(
  //         accessToken: googleAuth?.accessToken, idToken: googleAuth?.idToken);
  //     final userCredential = await _auth.signInWithCredential(credential);

  //     final Map<String, dynamic> res =
  //         await FirestoreDbService().isDoctor(userCredential.user!.email!);
  //     if (!res['success']) {
  //       await signout();
  //       return {
  //         "status": "error",
  //         "message": res['error'],
  //       };
  //     }

  //     return {
  //       "status": "success",
  //       "message": "Logged in successfully",
  //       "user": userCredential.user
  //     };
  //   } catch (e) {
  //     return {
  //       "status": "error",
  //       "message": e.toString(),
  //     };
  //   }
  // }

  // Future<Map<String, dynamic>> signUpWithGoogle() async {
  //   try {
  //     final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
  //     final GoogleSignInAuthentication? googleAuth =
  //         await googleUser?.authentication;
  //     final credential = GoogleAuthProvider.credential(
  //       accessToken: googleAuth?.accessToken,
  //       idToken: googleAuth?.idToken,
  //     );

  //     final userCredential = await _auth.signInWithCredential(credential);

  //     final Map<String, dynamic> res =
  //         await FirestoreDbService().isDoctor(userCredential.user!.email!);
  //     if (!res['success']) {
  //       await signout();
  //       return {
  //         "status": "error",
  //         "message": res['error'],
  //       };
  //     }

  //     // You can check if the user is new or existing
  //     if (userCredential.additionalUserInfo?.isNewUser ?? false) {
  //       return {
  //         "status": "success",
  //         "message": "Account created successfully",
  //         "user": userCredential.user,
  //       };
  //     } else {
  //       return {
  //         "status": "success",
  //         "message": "Logged in successfully",
  //         "user": userCredential.user,
  //       };
  //     }
  //   } catch (e) {
  //     return {
  //       "status": "error",
  //       "message": e.toString(),
  //     };
  //   }
  // }
}
