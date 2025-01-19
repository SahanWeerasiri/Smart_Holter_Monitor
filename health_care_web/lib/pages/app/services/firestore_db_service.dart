import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flame/extensions.dart';
import 'package:health_care_web/constants/consts.dart';

class FirestoreDbService {
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('user_accounts');
  final CollectionReference doctorCollection =
      FirebaseFirestore.instance.collection('doctor_accounts');

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Map<String, dynamic>> createAccount(String name, String email) async {
    try {
      // Example data for the account
      final accountData = {
        'createdAt': DateTime.now().toIso8601String(),
        'email': email,
        'name': name,
        'address': "Address",
        'mobile': "Mobile",
        'language': 'Language',
        'color': 'Color',
        'pic': '',
      };

      // Store data in the database
      await doctorCollection.doc(_auth.currentUser!.uid).set(accountData);

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
          await doctorCollection.doc(uid).get();

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

  Future<Map<String, dynamic>> fetchPatient(String uid) async {
    try {
      // Fetch the document snapshot
      final QuerySnapshot<Object?> snapshot = await usersCollection.get();

      const List<UserProfile> profiles = [];

      // Iterate through all documents in the snapshot
      for (DocumentSnapshot doc in snapshot.docs) {
        final patientData = doc.data() as Map<String, dynamic>;
        // Check if the 'doctor_id' matches the provided UID
        if (patientData['doctor_id'] == uid) {
          // Add the user profile to the list
          profiles.add(
            UserProfile(
              name: patientData['name'],
              email: patientData['email'],
              pic: patientData['pic'],
              address: patientData['address'],
              mobile: patientData['mobile'],
              device: patientData['device'],
              isDone: patientData['is_done'],
            ),
          );
        }
      }

      // Check if any profiles were found
      if (profiles.isNotEmpty) {
        return {'success': true, 'data': profiles};
      } else {
        return {
          'success': false,
          'error': 'No patients found for the given doctor'
        };
      }
    } catch (e) {
      // Handle errors and return failure
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> isDoctor(String email) async {
    try {
      // Fetch the document snapshot
      final QuerySnapshot<Object?> snapshot = await doctorCollection.get();

      // Iterate through all documents in the snapshot
      bool isDoctor = false;

      for (DocumentSnapshot doc in snapshot.docs) {
        final docData = doc.data() as Map<String, dynamic>;
        // Check if the 'doctor_id' matches the provided UID
        if (docData['email'] == email) {
          isDoctor = true;
          break;
        }
      }

      // Check if any profiles were found
      if (isDoctor) {
        return {'success': true, 'message': "This is a doctor"};
      } else {
        return {'success': false, 'error': 'You are not a doctor'};
      }
    } catch (e) {
      // Handle errors and return failure
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> fetchReports(String uid) async {
    try {
      // Fetch the document snapshot
      final QuerySnapshot<Object?> snapshot =
          await usersCollection.doc(uid).collection("reports").get();

      final docs = snapshot.docs;

      docs.sort((a, b) => b.get("timestamp").compareTo(a.get("timestamp")));
      docs.reverse();

      List<ReportModel> reportsNew = [];
      List<ReportModel> reportsOld = [];

      for (final DocumentSnapshot<Object?> doc in docs) {
        // Check if the document exists
        if (doc.exists) {
          if (doc.get("is_seen")) {
            reportsOld.add(ReportModel(
                aiSuggestions: doc.get("ai_suggestions"),
                brief: doc.get("brief"),
                avgHeart: doc.get("avg_heart"),
                timestamp: doc.get("timestamp"),
                docSuggestions: doc.get("suggestions"),
                description: doc.get("description"),
                graph: doc.get("graph"),
                reportId: doc.id));
          } else {
            reportsNew.add(ReportModel(
                brief: doc.get("brief"),
                aiSuggestions: doc.get("ai_suggestions"),
                avgHeart: doc.get("avg_heart"),
                timestamp: doc.get("timestamp"),
                docSuggestions: doc.get("suggestions"),
                description: doc.get("description"),
                graph: doc.get("graph"),
                reportId: doc.id));
          }
        } else {
          reportsOld.add(ReportModel(
            aiSuggestions: "",
            brief: "",
            avgHeart: "",
            timestamp: "",
            docSuggestions: "",
            description: "",
            graph: "",
            reportId: "",
          ));
        }
      }
      return {'success': true, 'data_new': reportsNew, "data_old": reportsOld};
    } catch (e) {
      // Handle errors and return failure
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> updateReportSeen(
      String uid, String reportId) async {
    try {
      // Fetch the document snapshot

      await usersCollection
          .doc(uid)
          .collection("reports")
          .doc(reportId)
          .update({'is_seen': true});
      return {'success': true, 'message': "updation successful"};
    } catch (e) {
      // Handle errors and return failure
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> updateProfile(String uid, String mobile,
      String language, String address, String pic) async {
    try {
      // Fetch the document snapshot

      await usersCollection.doc(uid).update({
        'mobile': mobile,
        'address': address,
        'language': language,
        'pic': pic,
      });
      return {'success': true, 'message': "updation successful"};
    } catch (e) {
      // Handle errors and return failure
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> addContact(
      String uid, String name, String mobile) async {
    try {
      // Fetch the document snapshot

      await usersCollection.doc(uid).collection("emergency").add({
        "name": name,
        "mobile": mobile,
      });
      return {'success': true, 'message': "Add contact successfully!"};
    } catch (e) {
      // Handle errors and return failure
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> fetchEmergency(String uid) async {
    try {
      // Fetch the document snapshot
      final QuerySnapshot<Object?> snapshot =
          await usersCollection.doc(uid).collection("emergency").get();

      final docs = snapshot.docs;

      List<Map<String, dynamic>> people = [];

      for (final DocumentSnapshot<Object?> doc in docs) {
        // Check if the document exists
        if (doc.exists) {
          people.add({
            'name': doc.get("name"),
            'mobile': doc.get("mobile"),
          });
        } else {
          people.add({
            'name': "",
            'mobile': "",
          });
        }
      }
      return {'success': true, 'data': people};
    } catch (e) {
      // Handle errors and return failure
      return {'success': false, 'error': e.toString()};
    }
  }
}
