import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flame/extensions.dart';
import 'package:health_care_web/constants/consts.dart';
import 'package:health_care_web/pages/app/additional/chat_bubble.dart';

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
        'is_done': false,
        'language': 'Language',
        'device': 'Device',
        'color': 'Color',
        'pic': '',
        'doctor_id': ''
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

      docs.sort((a, b) => b.get("timestamp").compareTo(a.get("timestamp")));
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
      });
      return {'success': true, 'msg': "Msg saved successfully!", "key": res.id};
    } catch (e) {
      // Handle errors and return failure
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> deleteChats(
      String uid, List<ChatBubble> chatBubles) async {
    try {
      for (ChatBubble chatBubble in chatBubles) {
        if (chatBubble.chatModel.chatId == "0") {
          continue;
        }
        usersCollection
            .doc(uid)
            .collection("chats")
            .doc(chatBubble.chatModel.chatId)
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
