import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
// import 'package:firebase_storage/firebase_storage.dart';
import 'package:smartcare/models/chat_message.dart';
import 'package:smartcare/models/patient_data.dart';
import 'package:smartcare/models/user.dart' as app_user;

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  // final FirebaseStorage _storage = FirebaseStorage.instance;

  // Authentication methods
  Future<User?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      rethrow;
    }
  }

  Future<User?> createUserWithEmailAndPassword(
      String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  // User profile methods
  Future<app_user.User?> getUserProfile(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;

        // Get emergency contacts
        final contactsSnapshot = await _firestore
            .collection('users')
            .doc(userId)
            .collection('emergency_contacts')
            .get();

        final emergencyContacts = contactsSnapshot.docs.map((doc) {
          final data = doc.data();
          return app_user.EmergencyContact(
            id: doc.id,
            name: data['name'] ?? '',
            phone: data['phone'] ?? '',
          );
        }).toList();

        return app_user.User(
          id: userId,
          name: data['name'] ?? '',
          email: data['email'] ?? '',
          address: data['address'],
          phone: data['phone'],
          language: data['language'],
          profileImage: data['profileImage'],
          connectedDevice: data['connectedDevice'],
          deviceDeadline: data['deviceDeadline'] != null
              ? (data['deviceDeadline'] as Timestamp).toDate()
              : null,
          emergencyContacts: emergencyContacts,
        );
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> createUserProfile(app_user.User user) async {
    try {
      await _firestore.collection('users').doc(user.id).set({
        'name': user.name,
        'email': user.email,
        'address': user.address,
        'phone': user.phone,
        'language': user.language,
        'profileImage': user.profileImage,
        'connectedDevice': user.connectedDevice,
        'deviceDeadline': user.deviceDeadline,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateUserProfile(
    String userId, {
    String? name,
    String? address,
    String? phone,
    String? language,
    String? profileImage,
    String? connectedDevice,
    DateTime? deviceDeadline,
  }) async {
    try {
      final Map<String, dynamic> data = {};

      if (name != null) data['name'] = name;
      if (address != null) data['address'] = address;
      if (phone != null) data['phone'] = phone;
      if (language != null) data['language'] = language;
      if (profileImage != null) data['profileImage'] = profileImage;
      if (connectedDevice != null) data['connectedDevice'] = connectedDevice;
      if (deviceDeadline != null) data['deviceDeadline'] = deviceDeadline;

      await _firestore.collection('users').doc(userId).update(data);
    } catch (e) {
      rethrow;
    }
  }

  // Emergency contacts methods
  Future<String> addEmergencyContact(
      String userId, String name, String phone) async {
    try {
      final docRef = await _firestore
          .collection('users')
          .doc(userId)
          .collection('emergency_contacts')
          .add({
        'name': name,
        'phone': phone,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return docRef.id;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removeEmergencyContact(String userId, String contactId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('emergency_contacts')
          .doc(contactId)
          .delete();
    } catch (e) {
      rethrow;
    }
  }

  // Patient data methods
  Future<PatientData?> getPatientData(String userId) async {
    try {
      final doc = await _firestore.collection('patient_data').doc(userId).get();

      if (!doc.exists) {
        return null;
      }

      final data = doc.data() as Map<String, dynamic>;

      // Get assigned doctor if exists
      Doctor? assignedDoctor;
      if (data['assignedDoctorId'] != null) {
        final doctorDoc = await _firestore
            .collection('doctors')
            .doc(data['assignedDoctorId'])
            .get();

        if (doctorDoc.exists) {
          final doctorData = doctorDoc.data() as Map<String, dynamic>;
          assignedDoctor = Doctor(
            id: doctorDoc.id,
            name: doctorData['name'] ?? '',
            specialization: doctorData['specialization'] ?? '',
            hospital: doctorData['hospital'] ?? '',
            phone: doctorData['phone'] ?? '',
            email: doctorData['email'] ?? '',
            profileImage: doctorData['profileImage'],
          );
        }
      }

      // Get reports
      final reportsSnapshot = await _firestore
          .collection('patient_data')
          .doc(userId)
          .collection('reports')
          .orderBy('date', descending: true)
          .get();

      final reports = await Future.wait(reportsSnapshot.docs.map((doc) async {
        final reportData = doc.data();

        // Get doctor for this report if exists
        Doctor? reportDoctor;
        if (reportData['doctorId'] != null) {
          final doctorDoc = await _firestore
              .collection('doctors')
              .doc(reportData['doctorId'])
              .get();

          if (doctorDoc.exists) {
            final doctorData = doctorDoc.data() as Map<String, dynamic>;
            reportDoctor = Doctor(
              id: doctorDoc.id,
              name: doctorData['name'] ?? '',
              specialization: doctorData['specialization'] ?? '',
              hospital: doctorData['hospital'] ?? '',
              phone: doctorData['phone'] ?? '',
              email: doctorData['email'] ?? '',
              profileImage: doctorData['profileImage'],
            );
          }
        }

        // Get heart rate data from Realtime Database
        final heartRateSnapshot = await _database
            .ref('heart_rate_data')
            .child(userId)
            .child(doc.id)
            .orderByKey()
            .get();

        final List<HeartRateData> heartRateData = [];

        if (heartRateSnapshot.exists) {
          final data = heartRateSnapshot.value as Map<dynamic, dynamic>;
          data.forEach((key, value) {
            final timestamp =
                DateTime.fromMillisecondsSinceEpoch(int.parse(key));
            heartRateData.add(HeartRateData(
              timestamp: timestamp,
              channel1: value['channel1'] ?? 0,
              channel2: value['channel2'] ?? 0,
              channel3: value['channel3'] ?? 0,
            ));
          });
        }

        return Report(
          id: doc.id,
          title: reportData['title'] ?? '',
          date: (reportData['date'] as Timestamp).toDate(),
          doctor: reportDoctor,
          patientName: reportData['patientName'] ?? '',
          summary: reportData['summary'] ?? '',
          anomalyDetection: reportData['anomalyDetection'] ?? '',
          doctorSuggestions: reportData['doctorSuggestions'] ?? '',
          aiSuggestions: reportData['aiSuggestions'] ?? '',
          heartRateData: heartRateData,
        );
      }).toList());

      return PatientData(
        currentBpm: data['currentBpm'] ?? 0,
        averageBpm: data['averageBpm'] ?? 0,
        status: data['status'] ?? '',
        assignedDoctor: assignedDoctor,
        reports: reports,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Real-time heart rate monitoring
  Stream<Map<String, dynamic>> streamHeartRateData(String userId) {
    return _database
        .ref('heart_rate_data')
        .child(userId)
        .child('current')
        .onValue
        .map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) {
        return {
          'bpm': 0,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        };
      }
      return {
        'bpm': data['bpm'] ?? 0,
        'timestamp': data['timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
      };
    });
  }

  // Chat methods
  Future<List<ChatMessage>> getChatMessages(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('chats')
          .doc(userId)
          .collection('messages')
          .orderBy('timestamp')
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return ChatMessage(
          id: doc.id,
          message: data['message'] ?? '',
          type: data['type'] == 'user' ? MessageType.user : MessageType.bot,
          timestamp: (data['timestamp'] as Timestamp).toDate(),
        );
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> saveChatMessage(String userId, ChatMessage message) async {
    try {
      await _firestore
          .collection('chats')
          .doc(userId)
          .collection('messages')
          .add({
        'message': message.message,
        'type': message.type == MessageType.user ? 'user' : 'bot',
        'timestamp': Timestamp.fromDate(message.timestamp),
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> clearChatMessages(String userId) async {
    try {
      final batch = _firestore.batch();
      final snapshot = await _firestore
          .collection('chats')
          .doc(userId)
          .collection('messages')
          .get();

      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      rethrow;
    }
  }

  // AI response generation (in a real app, this would call a backend API)
  Future<String> generateAIResponse(String userId, String message) async {
    // This is a mock implementation
    // In a real app, you would call your backend API or use a service like Dialogflow
    await Future.delayed(const Duration(seconds: 1));

    if (message.toLowerCase().contains('hello') ||
        message.toLowerCase().contains('hi')) {
      return 'Hello! I\'m SmartCare, your health assistant. How can I help you today?';
    } else if (message.toLowerCase().contains('heart') ||
        message.toLowerCase().contains('bpm')) {
      // Get current heart rate from Realtime Database
      final snapshot = await _database
          .ref('heart_rate_data')
          .child(userId)
          .child('current')
          .get();

      int currentBpm = 72;
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        currentBpm = data['bpm'] ?? 72;
      }

      // Get average from Firestore
      final patientDoc =
          await _firestore.collection('patient_data').doc(userId).get();

      int averageBpm = 68;
      if (patientDoc.exists) {
        final data = patientDoc.data() as Map<String, dynamic>;
        averageBpm = data['averageBpm'] ?? 68;
      }

      return 'Your current heart rate is $currentBpm BPM, which is within the normal range. Your average BPM over the last week is $averageBpm.';
    } else if (message.toLowerCase().contains('doctor')) {
      final patientDoc =
          await _firestore.collection('patient_data').doc(userId).get();

      if (patientDoc.exists) {
        final data = patientDoc.data() as Map<String, dynamic>;
        if (data['assignedDoctorId'] != null) {
          final doctorDoc = await _firestore
              .collection('doctors')
              .doc(data['assignedDoctorId'])
              .get();

          if (doctorDoc.exists) {
            final doctorData = doctorDoc.data() as Map<String, dynamic>;
            return 'Your doctor is ${doctorData['name']}, a ${doctorData['specialization']} at ${doctorData['hospital']}. You can contact them at ${doctorData['phone']}.';
          }
        }
      }

      return 'You currently don\'t have an assigned doctor. Would you like me to help you find one?';
    } else if (message.toLowerCase().contains('report')) {
      final reportsSnapshot = await _firestore
          .collection('patient_data')
          .doc(userId)
          .collection('reports')
          .orderBy('date', descending: true)
          .get();

      final reportsCount = reportsSnapshot.docs.length;
      String latestDate = 'N/A';

      if (reportsCount > 0) {
        final latestReport = reportsSnapshot.docs.first.data();
        final date = (latestReport['date'] as Timestamp).toDate();
        latestDate =
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      }

      return 'You have $reportsCount reports available. Your latest report was on $latestDate.';
    } else {
      return 'I\'m here to help with any questions about your heart health, reports, or medical information. Could you please provide more details about what you\'d like to know?';
    }
  }
}
