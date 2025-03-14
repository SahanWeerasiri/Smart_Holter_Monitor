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
}