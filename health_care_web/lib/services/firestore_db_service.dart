import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:health_care_web/models/device_profile_model.dart';
import 'package:health_care_web/models/doctor_profile_model.dart';
import 'package:health_care_web/models/patient_profile_model.dart';
import 'package:health_care_web/models/report_model.dart';
import 'package:health_care_web/models/return_model.dart';

class FirestoreDbService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<ReturnModel> createAccount(String name, String email) async {
    try {
      final uid = _auth.currentUser?.uid ?? ''; // Get current user ID
      if (uid.isEmpty) {
        return ReturnModel(state: false, message: "User not authenticated");
      }
      final accountData = {
        'createdAt': DateTime.now(),
        'email': email,
        'name': name,
        'address': '',
        'mobile': '',
        'language': '',
        'color': '',
        'pic': '',
      };
      await _firestore.collection('doctor_accounts').doc(uid).set(accountData);
      return ReturnModel(state: true, message: 'Account created successfully');
    } catch (e) {
      return ReturnModel(state: false, message: 'Error creating account: $e');
    }
  }

  Future<ReturnModel> fetchAccount(String uid) async {
    try {
      final doc = await _firestore.collection('doctor_accounts').doc(uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        final doctor = DoctorProfileModel.fromMap(data as Map<String, String>);
        return ReturnModel(
            state: true,
            message: 'Account fetched successfully',
            doctorProfileModel: doctor);
      } else {
        return ReturnModel(state: false, message: 'Account not found');
      }
    } catch (e) {
      return ReturnModel(state: false, message: 'Error fetching account: $e');
    }
  }

  Future<ReturnModel> fetchPatients() async {
    try {
      final snapshot = await _firestore.collection('user_accounts').get();
      final List<PatientProfileModel> patients = [];
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final patient =
            PatientProfileModel.fromMap(data, doc.id); //Use fromMap constructor
        patients.add(patient);
      }
      return ReturnModel(
          state: true,
          message: 'Patients fetched successfully',
          patients: patients);
    } catch (e) {
      return ReturnModel(state: false, message: 'Error fetching patients: $e');
    }
  }

  Future<ReturnModel> fetchSearchPatients(String name) async {
    try {
      final snapshot = await _firestore.collection('user_accounts').get();
      final List<PatientProfileModel> patients = [];
      for (final doc in snapshot.docs) {
        final data = doc.data();
        if (data['name'].toLowerCase().contains(name.toLowerCase())) {
          final patient = PatientProfileModel.fromMap(
              data, doc.id); //Use fromMap constructor
          patients.add(patient);
        }
      }
      return ReturnModel(
          state: true,
          message: 'Patients fetched successfully',
          patients: patients);
    } catch (e) {
      return ReturnModel(state: false, message: 'Error fetching patients: $e');
    }
  }

  Future<ReturnModel> isDoctor(String email) async {
    try {
      final snapshot = await _firestore
          .collection('doctor_accounts')
          .where('email', isEqualTo: email)
          .get();
      return ReturnModel(
          state: snapshot.docs.isNotEmpty,
          message: snapshot.docs.isNotEmpty ? 'Is a doctor' : 'Not a doctor');
    } catch (e) {
      return ReturnModel(
          state: false, message: 'Error checking doctor status: $e');
    }
  }

  Future<ReturnModel> removePatient(String uid) async {
    try {
      await _firestore
          .collection('user_accounts')
          .doc(uid)
          .update({'doctor_id': ''});
      return ReturnModel(state: true, message: 'Patient removed successfully');
    } catch (e) {
      return ReturnModel(state: false, message: 'Error removing patient: $e');
    }
  }

  Future<ReturnModel> addPatient(String uid, String doctorId) async {
    try {
      await _firestore
          .collection('user_accounts')
          .doc(uid)
          .update({'doctor_id': doctorId});
      return ReturnModel(state: true, message: 'Patient added successfully');
    } catch (e) {
      return ReturnModel(state: false, message: 'Error adding patient: $e');
    }
  }

  Future<ReturnModel> fetchCurrentPatient(String doctorId) async {
    try {
      final snapshot = await _firestore
          .collection('user_accounts')
          .where('doctor_id', isEqualTo: doctorId)
          .get();
      final List<PatientProfileModel> patients = snapshot.docs
          .map((doc) => PatientProfileModel.fromMap(doc.data(), doc.id))
          .toList();
      return ReturnModel(
          state: true,
          message: 'Current patients fetched successfully',
          patients: patients);
    } catch (e) {
      return ReturnModel(
          state: false, message: 'Error fetching current patients: $e');
    }
  }

  //Add fromMap constructor to your models for easier data conversion. Example for PatientProfileModel:

  Future<ReturnModel> fetchReports(String uid) async {
    try {
      final snapshot = await _firestore
          .collection('user_accounts')
          .doc(uid)
          .collection('reports')
          .orderBy('timestamp', descending: true)
          .get();
      final List<ReportModel> reports =
          snapshot.docs.map((doc) => ReportModel.fromMap(doc.data())).toList();
      return ReturnModel(
          state: true,
          message: 'Reports fetched successfully',
          reports: reports);
    } catch (e) {
      return ReturnModel(state: false, message: 'Error fetching reports: $e');
    }
  }

  Future<ReturnModel> updateProfile(String uid, String mobile, String language,
      String address, String pic) async {
    try {
      await _firestore.collection('doctor_accounts').doc(uid).update({
        'mobile': mobile,
        'address': address,
        'language': language,
        'pic': pic,
      });
      return ReturnModel(state: true, message: 'Profile updated successfully');
    } catch (e) {
      return ReturnModel(state: false, message: 'Error updating profile: $e');
    }
  }

  Future<ReturnModel> addDeviceToPatient(String uid, String device) async {
    try {
      await _firestore
          .collection('user_accounts')
          .doc(uid)
          .update({'device': device});
      return ReturnModel(
          state: true, message: 'Device added to patient successfully');
    } catch (e) {
      return ReturnModel(
          state: false, message: 'Error adding device to patient: $e');
    }
  }

  Future<ReturnModel> removeDeviceFromPatient(String uid, String device) async {
    try {
      // In a real application, you'd likely have a more sophisticated method for handling data transfer and deletion
      // (e.g., using transactions to ensure atomicity)

      // Placeholder - needs to be replaced by actual logic for transferring and removing data
      await _firestore
          .collection('user_accounts')
          .doc(uid)
          .update({'device': ''}); //Removing device ref from the patient
      return ReturnModel(
          state: true, message: 'Device removed from patient successfully');
    } catch (e) {
      return ReturnModel(
          state: false, message: 'Error removing device from patient: $e');
    }
  }

  Future<ReturnModel> getLatestDeviceReadings(String uid) async {
    try {
      final snapshot = await _firestore
          .collection('user_accounts')
          .doc(uid)
          .collection('data')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();
      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        return ReturnModel(
            state: true,
            message: 'Latest readings fetched successfully',
            deviceProfileModel: DeviceProfileModel(
                code: "device",
                detail: "detail",
                use: "use",
                state: DeviceProfileModel.assigned,
                deadline: "",
                latestValue: data.values.first.toString(),
                avgValue: ""));
      } else {
        return ReturnModel(state: false, message: 'No data found');
      }
    } catch (e) {
      return ReturnModel(
          state: false, message: 'Error fetching latest readings: $e');
    }
  }

  Future<ReturnModel> saveReportData(String uid, ReportModel report) async {
    try {
      // Add or update the report data
      await _firestore
          .collection('user_accounts')
          .doc(uid)
          .collection('data')
          .doc(report.reportId)
          .set(report.toMap()); // Use toMap()
      return ReturnModel(state: true, message: 'Draft saved successfully');
    } catch (e) {
      return ReturnModel(state: false, message: 'Error saving report data: $e');
    }
  }

  Future<ReturnModel> saveReport(String uid, ReportModel report) async {
    try {
      await _firestore
          .collection('user_accounts')
          .doc(uid)
          .collection('reports')
          .add(report.toMap()); //Use toMap()
      await _firestore
          .collection('user_accounts')
          .doc(uid)
          .update({'is_done': false});
      return ReturnModel(state: true, message: 'Report saved successfully');
    } catch (e) {
      return ReturnModel(state: false, message: 'Error saving report: $e');
    }
  }
}

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flame/extensions.dart';
// import 'package:health_care_web/constants/consts.dart';
// import 'package:health_care_web/models/patient_profile_model.dart';
// import 'package:health_care_web/models/user_profile_model.dart';
// import 'package:health_care_web/services/util.dart';

// class FirestoreDbService {
//   final CollectionReference usersCollection =
//       FirebaseFirestore.instance.collection('user_accounts');
//   final CollectionReference doctorCollection =
//       FirebaseFirestore.instance.collection('doctor_accounts');

//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   Future<Map<String, dynamic>> createAccount(String name, String email) async {
//     try {
//       // Example data for the account
//       final accountData = {
//         'createdAt': DateTime.now().toIso8601String(),
//         'email': email,
//         'name': name,
//         'address': "Address",
//         'mobile': "Mobile",
//         'language': 'Language',
//         'color': 'Color',
//         'pic': '',
//       };

//       // Store data in the database
//       await doctorCollection.doc(_auth.currentUser!.uid).set(accountData);

//       // Return the account data
//       return {'success': true, 'data': accountData};
//     } catch (e) {
//       // Handle errors and rethrow
//       return {'success': false, 'error': e.toString()};
//     }
//   }

//   Future<Map<String, dynamic>> fetchAccount(String uid) async {
//     try {
//       // Fetch the document snapshot
//       final DocumentSnapshot<Object?> snapshot =
//           await doctorCollection.doc(uid).get();

//       // Check if the document exists
//       if (snapshot.exists) {
//         // Extract data from the snapshot
//         final accountData = snapshot.data()!;
//         // Return success with the account data
//         return {'success': true, 'data': accountData};
//       } else {
//         // Document does not exist
//         return {'success': false, 'error': 'Account not found'};
//       }
//     } catch (e) {
//       // Handle errors and return failure
//       return {'success': false, 'error': e.toString()};
//     }
//   }

//   Future<Map<String, dynamic>> fetchPatient() async {
//     try {
//       // Fetch the document snapshot
//       final QuerySnapshot<Object?> snapshot = await usersCollection.get();

//       List<UserProfileModel> profiles = [];

//       // Iterate through all documents in the snapshot
//       for (DocumentSnapshot doc in snapshot.docs) {
//         final patientData = doc.data() as Map<String, dynamic>;
//         // Add the user profile to the list
//         // final QuerySnapshot<Object?> snapshotContacts =
//         //     await usersCollection.doc(doc.id).collection("emergency").get();
//         // List<ContactProfile> contacts = [];
//         // for (DocumentSnapshot docContacts in snapshotContacts.docs) {
//         //   final contactData = docContacts.data() as Map<String, dynamic>;
//         //   contacts.add(ContactProfile(
//         //       name: contactData['name'], mobile: contactData['mobile']));
//         // }
//         profiles.add(PatientProfileModel(
//           id: doc.id,
//           name: patientData['name'],
//           email: patientData['email'],
//           pic: patientData['pic'],
//           age: getAge(patientData['birthday']),
//           doctorProfileModel: patientData['doctor_id'],
//           address: patientData['address'],
//           mobile: patientData['mobile'],
//           device: patientData['device'],
//           isDone: patientData['is_done'],
//           // contacts: contacts,
//         ));
//       }

//       // Check if any profiles were found
//       return {'success': true, 'data': profiles};
//     } catch (e) {
//       // Handle errors and return failure
//       return {'success': false, 'error': e.toString()};
//     }
//   }

//   Future<Map<String, dynamic>> fetchSearch(String name) async {
//     try {
//       // Fetch the document snapshot
//       final QuerySnapshot<Object?> snapshot = await usersCollection.get();

//       List<UserProfile> profiles = [];

//       // Iterate through all documents in the snapshot
//       for (DocumentSnapshot doc in snapshot.docs) {
//         final patientData = doc.data() as Map<String, dynamic>;
//         // Add the user profile to the list
//         if (patientData['name'].toString().toLowerCase().contains(name)) {
//           profiles.add(UserProfile(
//             id: doc.id,
//             name: patientData['name'],
//             email: patientData['email'],
//             pic: patientData['pic'],
//             age: getAge(patientData['birthday']),
//             doctorId: patientData['doctor_id'],
//             address: patientData['address'],
//             mobile: patientData['mobile'],
//             device: patientData['device'],
//             isDone: patientData['is_done'],
//           ));
//         }
//       }

//       // Check if any profiles were found
//       return {'success': true, 'data': profiles};
//     } catch (e) {
//       // Handle errors and return failure
//       return {'success': false, 'error': e.toString()};
//     }
//   }

//   Future<Map<String, dynamic>> isDoctor(String email) async {
//     try {
//       // Fetch the document snapshot
//       final QuerySnapshot<Object?> snapshot = await doctorCollection.get();

//       // Iterate through all documents in the snapshot
//       bool isDoctor = false;

//       for (DocumentSnapshot doc in snapshot.docs) {
//         final docData = doc.data() as Map<String, dynamic>;
//         // Check if the 'doctor_id' matches the provided UID
//         if (docData['email'] == email) {
//           isDoctor = true;
//           break;
//         }
//       }

//       // Check if any profiles were found
//       if (isDoctor) {
//         return {'success': true, 'message': "This is a doctor"};
//       } else {
//         return {'success': false, 'error': 'You are not a doctor'};
//       }
//     } catch (e) {
//       // Handle errors and return failure
//       return {'success': false, 'error': e.toString()};
//     }
//   }

//   Future<Map<String, dynamic>> removePatiet(String uid) async {
//     try {
//       // Fetch the document snapshot
//       await usersCollection.doc(uid).update({
//         'doctor_id': "",
//       });

//       return {'success': true, 'message': "Patient is removed succesfully"};
//     } catch (e) {
//       // Handle errors and return failure
//       return {'success': false, 'error': e.toString()};
//     }
//   }

//   Future<Map<String, dynamic>> addPatiet(String uid, String docId) async {
//     try {
//       // Fetch the document snapshot
//       await usersCollection.doc(uid).update({
//         'doctor_id': docId,
//       });

//       return {'success': true, 'message': "Patient is added succesfully"};
//     } catch (e) {
//       // Handle errors and return failure
//       return {'success': false, 'error': e.toString()};
//     }
//   }

//   Future<Map<String, dynamic>> fetchCurrentPatient(String uid) async {
//     try {
//       // Fetch the document snapshot
//       final QuerySnapshot<Object?> snapshot = await usersCollection.get();

//       List<UserProfile> profiles = [];

//       // Iterate through all documents in the snapshot
//       for (DocumentSnapshot doc in snapshot.docs) {
//         final patientData = doc.data() as Map<String, dynamic>;
//         // Check if the 'doctor_id' matches the provided UID
//         if (patientData['doctor_id'] == uid) {
//           final QuerySnapshot<Object?> snapshotContacts =
//               await usersCollection.doc(doc.id).collection("emergency").get();
//           List<ContactProfile> contacts = [];
//           for (DocumentSnapshot docContacts in snapshotContacts.docs) {
//             final contactData = docContacts.data() as Map<String, dynamic>;
//             contacts.add(ContactProfile(
//                 name: contactData['name'], mobile: contactData['mobile']));
//           }
//           // Add the user profile to the list
//           profiles.add(UserProfile(
//               id: doc.id,
//               name: patientData['name'],
//               email: patientData['email'],
//               pic: patientData['pic'],
//               address: patientData['address'],
//               mobile: patientData['mobile'],
//               device: patientData['device'],
//               isDone: patientData['is_done'],
//               contacts: contacts));
//         }
//       }

//       // Check if any profiles were found
//       return {'success': true, 'data': profiles};
//     } catch (e) {
//       // Handle errors and return failure
//       return {'success': false, 'error': e.toString()};
//     }
//   }

//   Future<Map<String, dynamic>> fetchReports(String uid) async {
//     try {
//       // Fetch the document snapshot
//       final QuerySnapshot<Object?> snapshot =
//           await usersCollection.doc(uid).collection("reports").get();

//       final docs = snapshot.docs;

//       docs.sort((a, b) => b.get("timestamp").compareTo(a.get("timestamp")));
//       docs.reverse();

//       List<ReportModel> reports = [];

//       for (final DocumentSnapshot<Object?> doc in docs) {
//         // Check if the document exists
//         if (doc.exists) {
//           reports.add(ReportModel(
//               aiSuggestions: doc.get("ai_suggestions"),
//               brief: doc.get("brief"),
//               avgHeart: doc.get("avg_heart"),
//               timestamp: doc.get("timestamp").toString(),
//               docSuggestions: doc.get("suggestions"),
//               description: doc.get("description"),
//               graph: doc.get("graph"),
//               age: doc.get('age') ?? "",
//               anomalies: doc.get("anomalies"),
//               isEditing: false,
//               docName: doc.get('doc_name'),
//               docEmail: doc.get('doc_email'),
//               reportId: doc.id));
//         } else {
//           reports.add(ReportModel(
//             aiSuggestions: "",
//             brief: "",
//             avgHeart: "",
//             timestamp: "",
//             docSuggestions: "",
//             description: "",
//             graph: "",
//             anomalies: "",
//             age: "",
//             docName: "",
//             docEmail: "",
//             isEditing: false,
//             reportId: "",
//           ));
//         }
//       }
//       return {'success': true, 'data': reports};
//     } catch (e) {
//       // Handle errors and return failure
//       return {'success': false, 'error': e.toString()};
//     }
//   }

//   Future<Map<String, dynamic>> updateProfile(String uid, String mobile,
//       String language, String address, String pic) async {
//     try {
//       // Fetch the document snapshot

//       await doctorCollection.doc(uid).update({
//         'mobile': mobile,
//         'address': address,
//         'language': language,
//         'pic': pic,
//       });
//       return {'success': true, 'message': "updation successful"};
//     } catch (e) {
//       // Handle errors and return failure
//       return {'success': false, 'error': e.toString()};
//     }
//   }

//   Future<Map<String, dynamic>> addDeviceToPatient(
//       String uid, String device) async {
//     try {
//       // Fetch the document snapshot

//       await usersCollection.doc(uid).update({
//         'device': device,
//       });
//       return {'success': true, 'message': "Device is added succesfully"};
//     } catch (e) {
//       // Handle errors and return failure
//       return {'success': false, 'error': e.toString()};
//     }
//   }

//   Future<Map<String, dynamic>> removeDeviceFromPatient(
//       String uid, String device) async {
//     try {
//       // Fetch the document snapshot
//       final int avgHeart = await RealDbService().fetchDeviceDataAvg(device);
//       Map<String, dynamic> res =
//           await RealDbService().transferDeviceData(device);
//       if (res['success']) {
//         final DocumentSnapshot<Object?> sns =
//             await usersCollection.doc(uid).get();
//         await usersCollection.doc(uid).collection("data").add({
//           'device': device,
//           'timestamp': DateTime.now().toString(),
//           'data': res['data'],
//           'avg_heart': avgHeart.toString(),
//           'doc_id': sns.get('doctor_id'),
//           'age': getAge(sns.get('birthday')),
//         });

//         Map<String, dynamic> res2 =
//             await RealDbService().deleteDeviceData(device);
//         if (res2['success']) {
//           await usersCollection.doc(uid).update({
//             'device': "Device",
//             // "is_done":false, keep it as it is until the report is done
//           });
//           return {'success': true, 'message': res2['message']};
//         } else {
//           return {'success': false, 'message': res2['message']};
//         }
//       } else {
//         return {'success': false, 'message': res['message']};
//       }
//     } catch (e) {
//       // Handle errors and return failure
//       return {'success': false, 'error': e.toString()};
//     }
//   }

//   Future<Map<String, dynamic>> getLatestDeviceReadings(String uid) async {
//     try {
//       final QuerySnapshot<Map<String, dynamic>> snapshot = await usersCollection
//           .doc(uid)
//           .collection("data")
//           .orderBy("timestamp", descending: true)
//           .limit(1)
//           .get();

//       if (snapshot.docs.isNotEmpty) {
//         final DocumentSnapshot<Map<String, dynamic>> doc = snapshot.docs.first;
//         final data = doc.data();
//         if (data!.keys.contains('doc_id') && !data.keys.contains('doc_name')) {
//           final DocumentSnapshot<Object?> sns =
//               await doctorCollection.doc(doc.get('doc_id').toString()).get();
//           return {
//             'success': true,
//             'data': data,
//             'data_id': doc.id,
//             'name': sns.get('name'),
//             'email': sns.get('email'),
//           };
//         } else {
//           return {
//             'success': true,
//             'data': data,
//             'data_id': doc.id,
//             'name': data['doc_name'] ?? "",
//             'email': data['doc_email'] ?? "",
//           };
//         }
//       } else {
//         return {'success': false, 'error': 'No data found'};
//       }
//     } catch (e) {
//       return {'success': false, 'error': e.toString()};
//     }
//   }

//   Future<Map<String, dynamic>> saveReportData(
//       String uid, ReportModel report) async {
//     try {
//       await usersCollection
//           .doc(uid)
//           .collection("data")
//           .doc(report.reportId)
//           .update({
//         'brief': report.brief,
//         'ai_suggestions': report.aiSuggestions,
//         'suggestions': report.docSuggestions,
//         'description': report.description,
//         'avg_heart': report.avgHeart,
//         'graph': report.graph,
//         'anomalies': report.anomalies,
//         'timestamp': DateTime.now().toString(),
//         'doc_id': report.reportId,
//         'doc_name': report.docName,
//         'doc_email': report.docEmail,
//         'doc_suggestions': report.docSuggestions,
//       });

//       return {'success': true, 'message': 'Draft is saved successfully'};
//     } catch (e) {
//       return {'success': false, 'error': e.toString()};
//     }
//   }

//   Future<Map<String, dynamic>> saveReport(
//       String uid, ReportModel report) async {
//     try {
//       await usersCollection.doc(uid).collection("reports").add({
//         'brief': report.brief,
//         'ai_suggestions': report.aiSuggestions,
//         'suggestions': report.docSuggestions,
//         'description': report.description,
//         'avg_heart': report.avgHeart,
//         'graph': report.graph,
//         'anomalies': report.anomalies,
//         'is_seen': false,
//         'age': report.age,
//         'doc_id': report.reportId,
//         'doc_name': report.docName,
//         'doc_email': report.docEmail,
//         'timestamp': report.timestamp,
//         'doc_suggestions': report.docSuggestions,
//       });

//       usersCollection.doc(uid).update({
//         'is_done': false,
//       });

//       return {'success': true, 'message': 'Report is saved successfully'};
//     } catch (e) {
//       return {'success': false, 'error': e.toString()};
//     }
//   }
// }
