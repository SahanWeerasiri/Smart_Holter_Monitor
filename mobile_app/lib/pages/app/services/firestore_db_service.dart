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

  Future<Map<String, dynamic>> fetchAccount(String uid) async {
    try {
      // Fetch the document snapshot
      final DocumentSnapshot<Object?> snapshot =
          await usersCollection.doc(uid).get();

      // Check if the document exists
      if (snapshot.exists) {
        // Extract data from the snapshot
        final accountData = snapshot.data()!;
        // Return success with the account data
        return {'success': true, 'data': accountData};
      } else {
        // Document does not exist
        return {'success': false, 'error': 'Account not found'};
      }
    } catch (e) {
      // Handle errors and return failure
      return {'success': false, 'error': e.toString()};
    }
  }
}
