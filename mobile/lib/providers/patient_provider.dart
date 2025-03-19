import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smartcare/models/patient_data.dart';
import 'package:smartcare/models/chat_message.dart';
import 'package:smartcare/services/mongo_service.dart';

class PatientProvider extends ChangeNotifier {
  final MongoService _mongoService;

  PatientData? _patientData;
  List<ChatMessage> _chatMessages = [];
  bool _isLoading = false;
  String? _error;

  PatientProvider(this._mongoService);

  PatientData? get patientData => _patientData;
  List<ChatMessage> get chatMessages => _chatMessages;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchPatientData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Assuming userId is passed or stored somewhere
      final userId = 'someUserId';
      _patientData = await _mongoService.getPatientData(userId);
      _chatMessages = await _mongoService.getChatMessages(userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendChatMessage(String message) async {
    final userId = 'someUserId';
    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      message: message,
      type: MessageType.user,
      timestamp: DateTime.now(),
    );

    _chatMessages.add(userMessage);
    notifyListeners();

    await _mongoService.saveChatMessage(userId, userMessage);

    final botResponse = await _mongoService.generateAIResponse(userId, message);
    final botMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      message: botResponse,
      type: MessageType.bot,
      timestamp: DateTime.now(),
    );

    _chatMessages.add(botMessage);
    notifyListeners();

    await _mongoService.saveChatMessage(userId, botMessage);
  }

  Future<void> clearChat() async {
    final userId = 'someUserId';
    await _mongoService.clearChatMessages(userId);
    _chatMessages = [];
    notifyListeners();
  }
}

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:smartcare/models/patient_data.dart';
// import 'package:smartcare/models/chat_message.dart';
// import 'package:smartcare/services/firebase_service.dart';

// class PatientProvider extends ChangeNotifier {
//   final FirebaseService _firebaseService;

//   PatientData? _patientData;
//   List<ChatMessage> _chatMessages = [];
//   bool _isLoading = false;
//   String? _error;
//   StreamSubscription? _heartRateSubscription;

//   PatientProvider(this._firebaseService);

//   PatientData? get patientData => _patientData;
//   List<ChatMessage> get chatMessages => _chatMessages;
//   bool get isLoading => _isLoading;
//   String? get error => _error;

//   Future<void> fetchPatientData() async {
//     _isLoading = true;
//     _error = null;
//     //notifyListeners();

//     try {
//       final currentUser = FirebaseAuth.instance.currentUser;

//       if (currentUser == null) {
//         _error = 'User not authenticated';
//         _isLoading = false;
//         //notifyListeners();
//         return;
//       }

//       // Get patient data from Firestore
//       _patientData = await _firebaseService.getPatientData(currentUser.uid);

//       // If no data exists yet, create a default entry
//       _patientData ??= PatientData(
//         currentBpm: 0,
//         averageBpm: 0,
//         status: 'No Data',
//         reports: [],
//       );

//       // Start listening to real-time heart rate updates
//       _startHeartRateListener(currentUser.uid);

//       // Load chat messages
//       _chatMessages = await _firebaseService.getChatMessages(currentUser.uid);

//       _isLoading = false;
//       //notifyListeners();
//     } catch (e) {
//       _error = e.toString();
//       _isLoading = false;
//       //notifyListeners();
//     }
//   }

//   void _startHeartRateListener(String userId) {
//     // Cancel any existing subscription
//     _heartRateSubscription?.cancel();

//     // Subscribe to real-time heart rate updates
//     _heartRateSubscription =
//         _firebaseService.streamHeartRateData(userId).listen((data) {
//       if (_patientData != null) {
//         final currentBpm = data['bpm'] as int;

//         // Update the current BPM
//         _patientData = PatientData(
//           currentBpm: currentBpm,
//           averageBpm: _patientData!.averageBpm,
//           status: _getHeartRateStatus(currentBpm),
//           assignedDoctor: _patientData!.assignedDoctor,
//           reports: _patientData!.reports,
//         );

//         //notifyListeners();
//       }
//     });
//   }

//   String _getHeartRateStatus(int bpm) {
//     if (bpm == 0) return 'No Data';
//     if (bpm < 60) return 'Low';
//     if (bpm > 100) return 'High';
//     return 'Good';
//   }

//   Future<void> sendChatMessage(String message) async {
//     final currentUser = FirebaseAuth.instance.currentUser;
//     if (currentUser == null) return;

//     final userMessage = ChatMessage(
//       id: DateTime.now().millisecondsSinceEpoch.toString(),
//       message: message,
//       type: MessageType.user,
//       timestamp: DateTime.now(),
//     );

//     _chatMessages.add(userMessage);
//     //notifyListeners();

//     // Save user message to Firestore
//     await _firebaseService.saveChatMessage(currentUser.uid, userMessage);

//     // Generate AI response
//     final botResponse = await _firebaseService.generateAIResponse(
//       currentUser.uid,
//       message,
//     );

//     final botMessage = ChatMessage(
//       id: DateTime.now().millisecondsSinceEpoch.toString(),
//       message: botResponse,
//       type: MessageType.bot,
//       timestamp: DateTime.now(),
//     );

//     _chatMessages.add(botMessage);
//     //notifyListeners();

//     // Save bot message to Firestore
//     await _firebaseService.saveChatMessage(currentUser.uid, botMessage);
//   }

//   Future<void> clearChat() async {
//     final currentUser = FirebaseAuth.instance.currentUser;
//     if (currentUser == null) return;

//     await _firebaseService.clearChatMessages(currentUser.uid);
//     _chatMessages = [];
//     //notifyListeners();
//   }

//   @override
//   void dispose() {
//     _heartRateSubscription?.cancel();
//     super.dispose();
//   }
// }
