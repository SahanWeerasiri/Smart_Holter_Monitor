import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreDbService {
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('user_accounts');

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Map<String, dynamic>> createAccount(String name, String email) async {
    try {
      // Example data for the account
      final accountData = {
        'createdAt': DateTime.now().toIso8601String(),
        'email': email,
        'name': name
      };

      // Store data in the database
      await usersCollection.doc(_auth.currentUser!.uid).set(accountData);

      // Return the account data
      return {'success': true, 'data': accountData};
    } catch (e) {
      // Handle errors and rethrow
      return {'success': false, 'error': e.toString()};
    }
  }
}
