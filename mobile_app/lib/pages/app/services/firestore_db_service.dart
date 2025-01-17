import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:health_care/pages/app/additional/chat_bubble.dart';

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

      snapshot.docs
          .sort((a, b) => b.get("timestamp").compareTo(a.get("timestamp")));

      List<ChatModel> chats = [];

      for (final DocumentSnapshot<Object?> doc in snapshot.docs) {
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
            .doc(chatBubble.chatModel.chatId);
      }

      return {'success': true, 'msg': "Chat deleted successfully!"};
    } catch (e) {
      // Handle errors and return failure
      return {'success': false, 'error': e.toString()};
    }
  }
}
