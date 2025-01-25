import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flame/extensions.dart';
import 'package:health_care_web/constants/consts.dart';
import 'package:health_care_web/pages/app/services/real_db_service.dart';

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

  Future<Map<String, dynamic>> fetchPatient() async {
    try {
      // Fetch the document snapshot
      final QuerySnapshot<Object?> snapshot = await usersCollection.get();

      List<UserProfile> profiles = [];

      // Iterate through all documents in the snapshot
      for (DocumentSnapshot doc in snapshot.docs) {
        final patientData = doc.data() as Map<String, dynamic>;
        // Add the user profile to the list
        profiles.add(UserProfile(
          id: doc.id,
          name: patientData['name'],
          email: patientData['email'],
          pic: patientData['pic'],
          doctorId: patientData['doctor_id'],
          address: patientData['address'],
          mobile: patientData['mobile'],
          device: patientData['device'],
          isDone: patientData['is_done'],
        ));
      }

      // Check if any profiles were found
      return {'success': true, 'data': profiles};
    } catch (e) {
      // Handle errors and return failure
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> fetchSearch(String name) async {
    try {
      // Fetch the document snapshot
      final QuerySnapshot<Object?> snapshot = await usersCollection.get();

      List<UserProfile> profiles = [];

      // Iterate through all documents in the snapshot
      for (DocumentSnapshot doc in snapshot.docs) {
        final patientData = doc.data() as Map<String, dynamic>;
        // Add the user profile to the list
        if (patientData['name'].toString().toLowerCase().contains(name)) {
          profiles.add(UserProfile(
            id: doc.id,
            name: patientData['name'],
            email: patientData['email'],
            pic: patientData['pic'],
            doctorId: patientData['doctor_id'],
            address: patientData['address'],
            mobile: patientData['mobile'],
            device: patientData['device'],
            isDone: patientData['is_done'],
          ));
        }
      }

      // Check if any profiles were found
      return {'success': true, 'data': profiles};
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

  Future<Map<String, dynamic>> removePatiet(String uid) async {
    try {
      // Fetch the document snapshot
      await usersCollection.doc(uid).update({
        'doctor_id': "",
      });

      return {'success': true, 'message': "Patient is removed succesfully"};
    } catch (e) {
      // Handle errors and return failure
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> addPatiet(String uid, String docId) async {
    try {
      // Fetch the document snapshot
      await usersCollection.doc(uid).update({
        'doctor_id': docId,
      });

      return {'success': true, 'message': "Patient is added succesfully"};
    } catch (e) {
      // Handle errors and return failure
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> fetchCurrentPatient(String uid) async {
    try {
      // Fetch the document snapshot
      final QuerySnapshot<Object?> snapshot = await usersCollection.get();

      List<UserProfile> profiles = [];

      // Iterate through all documents in the snapshot
      for (DocumentSnapshot doc in snapshot.docs) {
        final patientData = doc.data() as Map<String, dynamic>;
        // Check if the 'doctor_id' matches the provided UID
        if (patientData['doctor_id'] == uid) {
          // Add the user profile to the list
          profiles.add(UserProfile(
            id: doc.id,
            name: patientData['name'],
            email: patientData['email'],
            pic: patientData['pic'],
            address: patientData['address'],
            mobile: patientData['mobile'],
            device: patientData['device'],
            isDone: patientData['is_done'],
          ));
        }
      }

      // Check if any profiles were found
      return {'success': true, 'data': profiles};
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

      await doctorCollection.doc(uid).update({
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

  Future<Map<String, dynamic>> addDeviceToPatient(
      String uid, String device) async {
    try {
      // Fetch the document snapshot

      await usersCollection.doc(uid).update({
        'device': device,
      });
      return {'success': true, 'message': "Device added successfully"};
    } catch (e) {
      // Handle errors and return failure
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> removeDeviceFromPatient(
      String uid, String device) async {
    try {
      // Fetch the document snapshot
      Map<String, dynamic> res =
          await RealDbService().transferDeviceData(device);
      if (res['success']) {
        await usersCollection.doc(uid).collection("data").add({
          'device': device,
          'timestamp': DateTime.now(),
          'data': res['data'],
        });

        Map<String, dynamic> res2 =
            await RealDbService().deleteDeviceData(device);
        if (res2['success']) {
          await usersCollection.doc(uid).update({
            'device': "Device",
            // "is_done":false, keep it as it is until the report is done
          });
          return {'success': true, 'message': res2['message']};
        } else {
          return {'success': false, 'message': res2['message']};
        }
      } else {
        return {'success': false, 'message': res['message']};
      }
    } catch (e) {
      // Handle errors and return failure
      return {'success': false, 'error': e.toString()};
    }
  }
}
