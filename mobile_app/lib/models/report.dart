import 'package:health_care/models/user.dart';

class Doctor {
  final String id;
  final String name;
  final String specialization;
  final String hospital;
  final String phone;
  final String email;
  final String? profileImage;

  Doctor({
    required this.id,
    required this.name,
    required this.specialization,
    required this.hospital,
    required this.phone,
    required this.email,
    this.profileImage,
  });

  // Convert Doctor to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'specialization': specialization,
      'hospital': hospital,
      'phone': phone,
      'email': email,
      'profileImage': profileImage,
    };
  }

  // Create Doctor from a Map
  factory Doctor.fromMap(Map<String, dynamic> map) {
    return Doctor(
      id: map['id'],
      name: map['name'],
      specialization: map['specialization'],
      hospital: map['hospital'],
      phone: map['phone'],
      email: map['email'],
      profileImage: map['profileImage'],
    );
  }
}

class Report {
  final String reportId;
  final String brief;
  final String timestamp;
  final String docSuggestions;
  final String aiSuggestions;
  final String anomalies;
  final bool isSeen;
  final String deviceId;
  final bool isEditing;
  final String age;
  final String docId;
  final Doctor? doctor;
  final Account? patient;
  final List<HeartRateData> heartRateData;

  Report({
    required this.reportId,
    required this.brief,
    required this.timestamp,
    required this.docSuggestions,
    required this.aiSuggestions,
    required this.anomalies,
    required this.isSeen,
    required this.deviceId,
    required this.isEditing,
    required this.age,
    required this.docId,
    this.doctor,
    this.patient,
    required this.heartRateData,
  });

  // Convert Report to a Map
  Map<String, dynamic> toMap() {
    return {
      'reportId': reportId,
      'brief': brief,
      'timestamp': timestamp,
      'docSuggestions': docSuggestions,
      'aiSuggestions': aiSuggestions,
      'anomalies': anomalies,
      'isSeen': isSeen,
      'deviceId': deviceId,
      'isEditing': isEditing,
      'age': age,
      'docId': docId,
      'doctor': doctor?.toMap(),
      'patient': patient?.toMap(),
      'heartRateData': heartRateData.map((hr) => hr.toMap()).toList(),
    };
  }

  // Create Report from a Map
  factory Report.fromMap(Map<String, dynamic> map) {
    return Report(
      reportId: map['reportId'],
      brief: map['brief'],
      timestamp: map['timestamp'],
      docSuggestions: map['docSuggestions'],
      aiSuggestions: map['aiSuggestions'],
      anomalies: map['anomalies'],
      isSeen: map['isSeen'] == 'true',
      deviceId: map['deviceId'],
      isEditing: map['isEditing'] == 'true',
      age: map['age'],
      docId: map['docId'],
      doctor: map['doctor'] != null ? Doctor.fromMap(map['doctor']) : null,
      patient: map['patient'] != null ? Account.fromMap(map['patient']) : null,
      heartRateData: (map['heartRateData'] as List<dynamic>?)
              ?.map((hr) => HeartRateData.fromMap(hr))
              .toList() ??
          [],
    );
  }
}

class HeartRateData {
  final DateTime timestamp;
  final int channel1;
  final int channel2;
  final int channel3;

  HeartRateData({
    required this.timestamp,
    required this.channel1,
    required this.channel2,
    required this.channel3,
  });

  // Convert HeartRateData to a Map
  Map<String, dynamic> toMap() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'channel1': channel1,
      'channel2': channel2,
      'channel3': channel3,
    };
  }

  // Create HeartRateData from a Map
  factory HeartRateData.fromMap(Map<String, dynamic> map) {
    return HeartRateData(
      timestamp: DateTime.parse(map['timestamp']),
      channel1: map['channel1'],
      channel2: map['channel2'],
      channel3: map['channel3'],
    );
  }
}

class ReportDoctor {
  final String name;
  final String mobile;
  final String email;

  ReportDoctor({
    required this.name,
    required this.mobile,
    required this.email,
  });

  // Convert HeartRateData to a Map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'mobile': mobile,
      'email': email,
    };
  }

  // Create HeartRateData from a Map
  factory ReportDoctor.fromMap(Map<String, dynamic> map) {
    return ReportDoctor(
      name: map['doctorName'],
      mobile: map['doctorMobile'],
      email: map['doctorEmail'],
    );
  }
}
