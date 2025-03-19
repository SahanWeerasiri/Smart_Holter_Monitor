import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flame/extensions.dart';
import 'package:health_care/constants/consts.dart';
import 'package:health_care/pages/app/additional/chat_bubble.dart';
import 'package:health_care/pages/app/services/real_db_service.dart';
import 'package:health_care/pages/app/services/util.dart';

class FirestoreDbService {
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('user_accounts');
  final CollectionReference doctorCollection =
      FirebaseFirestore.instance.collection('users');

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Map<String, dynamic>> createAccount(
      String name, String email, String birthday) async {
    try {
      // Example data for the account
      final accountData = {
        'createdAt': DateTime.now().toIso8601String(),
        'email': email,
        'name': name,
        'address': "Address",
        'mobile': "Mobile",
        'isDone': false,
        'language': 'Language',
        'device': '',
        'deviceId': 'Device',
        'color': 'Color',
        'pic': '',
        'docId': '',
        'birthday': birthday,
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

  Future<Map<String, dynamic>> fetchDoctor(String uid) async {
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
        return {'success': false, 'error': 'Doctor not found'};
      }
    } catch (e) {
      // Handle errors and return failure
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> fetchChats(String uid) async {
    try {
      // Fetch the document snapshot
      final QuerySnapshot<Object?> snapshot =
          await usersCollection.doc(uid).collection("chats").get();

      final docs = snapshot.docs;

      docs.sort((a, b) => b.get("createdAt").compareTo(a.get("createdAt")));
      docs.reverse();

      List<ChatModel> chats = [];

      for (final DocumentSnapshot<Object?> doc in docs) {
        // Check if the document exists
        if (doc.exists) {
          String sender = doc.get("sender");
          chats.add(ChatModel(
              doc.get("msg"),
              doc.get("timestamp"),
              sender == "me" ? true : false,
              sender == "me" ? "Me" : "AI",
              doc.id));
          // Return success with the account data
        } else {
          chats.add(ChatModel(
            "Msg is not found",
            "",
            false,
            "AI",
            "0",
          ));
        }
      }
      return {'success': true, 'data': chats};
    } catch (e) {
      // Handle errors and return failure
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> sendChats(
      String uid, ChatModel chatModel) async {
    try {
      DocumentReference<Map<String, dynamic>> res =
          await usersCollection.doc(uid).collection("chats").add({
        "msg": chatModel.msg,
        "timestamp": chatModel.timestamp,
        "sender": chatModel.isSender ? "me" : "ai",
        "createdAt": DateTime.now().toIso8601String()
      });
      return {'success': true, 'msg': "Msg saved successfully!", "key": res.id};
    } catch (e) {
      // Handle errors and return failure
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> deleteChats(
      String uid, List<ChatModel> chatBubles) async {
    try {
      for (ChatModel chatModel in chatBubles) {
        if (chatModel.chatId == "0") {
          continue;
        }
        usersCollection
            .doc(uid)
            .collection("chats")
            .doc(chatModel.chatId)
            .delete();
      }

      return {'success': true, 'msg': "Chat deleted successfully!"};
    } catch (e) {
      // Handle errors and return failure
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> fetchReports(String uid) async {
    try {
      // Fetch the document snapshot
      final QuerySnapshot<Object?> snapshot =
          await usersCollection.doc(uid).collection("data").get();

      final docs = snapshot.docs;

      docs.sort((a, b) => b.get("timestamp").compareTo(a.get("timestamp")));
      docs.reverse();

      List<ReportModel> reportsNew = [];
      List<ReportModel> reportsOld = [];

      for (final DocumentSnapshot<Object?> doc in docs) {
        // Check if the document exists
        if (doc.exists) {
          if (doc.get("isEditing")) {
            continue;
          }
          if (doc.get("isSeen")) {
            reportsOld.add(ReportModel(
                aiSuggestions: doc.get("aiSuggestions"),
                brief: doc.get("brief"),
                avgHeart: doc.get("avgHeart"),
                timestamp: doc.get("timestamp"),
                docSuggestions: doc.get("docSuggestions"),
                description: doc.get("description"),
                graph: doc.get("graph"),
                reportId: doc.id));
          } else {
            reportsNew.add(ReportModel(
                brief: doc.get("brief"),
                aiSuggestions: doc.get("aiSuggestions"),
                avgHeart: doc.get("avgHeart"),
                timestamp: doc.get("timestamp"),
                docSuggestions: doc.get("docSuggestions"),
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

  Future<Map<String, dynamic>> fetchReportsV2(String uid) async {
    try {
      final DocumentSnapshot resUser = await usersCollection.doc(uid).get();

      if (!resUser.exists) {
        return {'success': false, 'error': 'User not found'};
      }
      Map<String, String> patientProfileModel = {
        'id': uid,
        'name': resUser.get('name'),
        'mobile': resUser.get('mobile'),
        'address': resUser.get('address'),
        'language': resUser.get('language'),
        'color': resUser.get('color'),
        'pic': resUser.get('pic'),
        'deviceId': resUser.get('deviceId'),
        'docId': resUser.get('docId'),
        'email': resUser.get('email'),
        'age': getAge(resUser.get('birthday'))
      };
      final QuerySnapshot<Object?> snp =
          await usersCollection.doc(uid).collection('data').get();
      if (snp.docs.isEmpty) {
        return {'success': true, 'data_new': [], "data_old": []};
      }

      final snapshot = await usersCollection
          .doc(uid)
          .collection('data')
          .orderBy('timestamp', descending: true)
          .get();

      final List<Map<String, dynamic>> oldReports = [];
      final List<Map<String, dynamic>> newReports = [];

      for (DocumentSnapshot doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final Map<String, String> reportModel = {
          'brief': data['brief'],
          'avgHeart': data['avgHeart'],
          'timestamp': data['timestamp'],
          'docSuggestions': data['docSuggestions'],
          'description': data['description'],
          'graph': data['graph'],
          'reportId': doc.id,
          'isSeen': data['isSeen'] as bool ? 'true' : 'false',
          'deviceId': data['deviceId'],
          'aiSuggestions': data['aiSuggestions'],
          'anomalies': data['anomalies'],
          'isEditing': data['isEditing'] as bool ? 'true' : 'false',
          'age': data['age'],
          'docId': data['docId'],
        };
        if (reportModel['isEditing'] == 'true') {
          continue;
        }

        final Map<String, dynamic> doctorModel = {};

        await doctorCollection.doc(reportModel['docId']).get().then((value) {
          if (value.exists) {
            doctorModel['doctorName'] = value.get('name');
            doctorModel['doctorEmail'] = value.get('email');
            doctorModel['doctorMobile'] = value.get('mobile');
          } else {
            doctorModel['doctorName'] = "";
            doctorModel['doctorEmail'] = "";
            doctorModel['doctorMobile'] = "";
          }
        });

        if (doctorModel['doctorName'] == "") {
          continue;
        }

        final Map<String, dynamic> deviceModel = {};

        await RealDbService()
            .fetchDeviceDetails(patientProfileModel['deviceId']!)
            .then((value) {
          if (value['success']) {
            deviceModel['other'] = value;
          }
        });

        if (deviceModel['other'] == null) {
          continue;
        }

        if (reportModel['isSeen'] == 'true') {
          oldReports.add({
            'report': reportModel,
            'doctor': doctorModel,
            'device': deviceModel,
            'patient': patientProfileModel,
            'data': convertToInt(data['data']),
          });
        } else {
          newReports.add({
            'report': reportModel,
            'doctor': doctorModel,
            'device': deviceModel,
            'patient': patientProfileModel,
            'data': convertToInt(data['data']),
          });
        }
      }

      return {
        'success': true,
        'data_new': newReports,
        'data_old': oldReports,
      };
    } catch (e) {
      print(e.toString());
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> updateReportSeen(
      String uid, String reportId) async {
    try {
      // Fetch the document snapshot

      await usersCollection
          .doc(uid)
          .collection("data")
          .doc(reportId)
          .update({'isSeen': true});
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
            'id': doc.id,
            'name': doc.get("name"),
            'mobile': doc.get("mobile"),
          });
        }
      }
      return {'success': true, 'data': people};
    } catch (e) {
      // Handle errors and return failure
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> removeEmergencyContact(
      String uid, String id) async {
    try {
      await usersCollection.doc(uid).collection("emergency").doc(id).delete();
      return {'success': true, 'message': "Delete contact successfully!"};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> fetchHospital(String id) async {
    final DocumentSnapshot<Object?> snapshot =
        await doctorCollection.doc(id).get();
    if (snapshot.exists) {
      return {
        'success': true,
        'data': {
          'name': snapshot.get("name"),
          'mobile': snapshot.get("mobile"),
        }
      };
    } else {
      return {'success': false, 'error': 'Hospital not found'};
    }
  }
}
