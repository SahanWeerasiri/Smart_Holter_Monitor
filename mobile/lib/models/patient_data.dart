class PatientData {
  final int currentBpm;
  final int averageBpm;
  final String status; // Good, Bad, Moderate
  final Doctor? assignedDoctor;
  final List<Report> reports;

  PatientData({
    this.currentBpm = 0,
    this.averageBpm = 0,
    this.status = '',
    this.assignedDoctor,
    this.reports = const [],
  });

  // Convert PatientData to a Map
  Map<String, dynamic> toMap() {
    return {
      'currentBpm': currentBpm,
      'averageBpm': averageBpm,
      'status': status,
      'assignedDoctor': assignedDoctor?.toMap(),
      'reports': reports.map((report) => report.toMap()).toList(),
    };
  }

  // Create PatientData from a Map
  factory PatientData.fromMap(Map<String, dynamic> map) {
    return PatientData(
      currentBpm: map['currentBpm'] ?? 0,
      averageBpm: map['averageBpm'] ?? 0,
      status: map['status'] ?? '',
      assignedDoctor: map['assignedDoctor'] != null
          ? Doctor.fromMap(map['assignedDoctor'])
          : null,
      reports: (map['reports'] as List<dynamic>?)
              ?.map((report) => Report.fromMap(report))
              .toList() ??
          [],
    );
  }
}

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
  final String id;
  final String title;
  final DateTime date;
  final Doctor? doctor;
  final String patientName;
  final String summary;
  final String anomalyDetection;
  final String doctorSuggestions;
  final String aiSuggestions;
  final List<HeartRateData> heartRateData;

  Report({
    required this.id,
    required this.title,
    required this.date,
    this.doctor,
    required this.patientName,
    required this.summary,
    required this.anomalyDetection,
    required this.doctorSuggestions,
    required this.aiSuggestions,
    required this.heartRateData,
  });

  // Convert Report to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'date': date.toIso8601String(),
      'doctor': doctor?.toMap(),
      'patientName': patientName,
      'summary': summary,
      'anomalyDetection': anomalyDetection,
      'doctorSuggestions': doctorSuggestions,
      'aiSuggestions': aiSuggestions,
      'heartRateData': heartRateData.map((hr) => hr.toMap()).toList(),
    };
  }

  // Create Report from a Map
  factory Report.fromMap(Map<String, dynamic> map) {
    return Report(
      id: map['id'],
      title: map['title'],
      date: DateTime.parse(map['date']),
      doctor: map['doctor'] != null ? Doctor.fromMap(map['doctor']) : null,
      patientName: map['patientName'],
      summary: map['summary'],
      anomalyDetection: map['anomalyDetection'],
      doctorSuggestions: map['doctorSuggestions'],
      aiSuggestions: map['aiSuggestions'],
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
