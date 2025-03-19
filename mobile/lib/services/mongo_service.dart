import 'package:mongo_dart/mongo_dart.dart';
import 'package:smartcare/models/chat_message.dart';
import 'package:smartcare/models/patient_data.dart';
import 'package:smartcare/models/user.dart' as app_user;

class MongoService {
  late Db _db;
  late DbCollection _usersCollection;
  late DbCollection _patientDataCollection;
  late DbCollection _chatMessagesCollection;

  MongoService() {
    _db = Db(
        'mongodb+srv://sahan:F9woKYCIQYcUYvFM@cluster0.oqu4o.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0');
    _usersCollection = _db.collection('users');
    _patientDataCollection = _db.collection('patient_data');
    _chatMessagesCollection = _db.collection('chat_messages');
  }

  Future<void> connect() async {
    await _db.open();
  }

  Future<void> disconnect() async {
    await _db.close();
  }

  // User profile methods
  Future<app_user.User?> getUserProfile(String userId) async {
    final user = await _usersCollection.findOne(where.id(userId as ObjectId));
    if (user != null) {
      return app_user.User.fromMap(user);
    }
    return null;
  }

  Future<void> createUserProfile(app_user.User user) async {
    await _usersCollection.insert(user.toMap());
  }

  Future<void> updateUserProfile(
      String userId, Map<String, dynamic> updates) async {
    // Construct the update query using the $set operator
    final updateQuery = {
      '\$set': updates,
    };

    // Apply the updates to the user document
    await _usersCollection.update(
      where.id(userId as ObjectId),
      updateQuery,
    );
  }

  // Emergency contacts methods
  Future<String> addEmergencyContact(
      String userId, String name, String phone) async {
    // Generate a unique ID for the contact
    final contactId = ObjectId().toHexString();

    // Create the contact object with the generated ID
    final contact = {
      'id': contactId, // Add the ID to the contact
      'name': name,
      'phone': phone,
      'createdAt': DateTime.now(),
    };

    // Update the user document to add the new contact
    await _usersCollection.update(
      where.id(userId as ObjectId),
      modify.push('emergencyContacts', contact),
    );

    // Return the generated contact ID
    return contactId;
  }

  Future<void> removeEmergencyContact(String userId, String contactId) async {
    await _usersCollection.update(
      where.id(userId as ObjectId),
      modify.pull('emergencyContacts', where.id(contactId as ObjectId)),
    );
  }

  // Patient data methods
  Future<PatientData?> getPatientData(String userId) async {
    final patientData =
        await _patientDataCollection.findOne(where.id(userId as ObjectId));
    if (patientData != null) {
      return PatientData.fromMap(patientData);
    }
    return null;
  }

  // Chat methods
  Future<List<ChatMessage>> getChatMessages(String userId) async {
    final messages =
        await _chatMessagesCollection.find(where.eq('userId', userId)).toList();
    return messages.map((msg) => ChatMessage.fromMap(msg)).toList();
  }

  Future<void> saveChatMessage(String userId, ChatMessage message) async {
    await _chatMessagesCollection.insert(message.toMap());
  }

  Future<void> clearChatMessages(String userId) async {
    await _chatMessagesCollection.remove(where.eq('userId', userId));
  }

  // AI response generation (mock implementation)
  Future<String> generateAIResponse(String userId, String message) async {
    await Future.delayed(const Duration(seconds: 1));
    return 'Mock AI response';
  }
}
