import 'package:health_care_web/models/patient_profile_model.dart';

class ReportModel {
  String timestamp;
  String description;
  String brief;
  String docSuggestions;
  String aiSuggestions;
  String graph;
  String reportId;
  String anomalies;
  bool isEditing;
  PatientReportModel patientProfileModel;

  ReportModel({
    required this.timestamp,
    required this.brief,
    required this.description,
    required this.aiSuggestions,
    required this.docSuggestions,
    required this.graph,
    required this.reportId,
    required this.isEditing,
    required this.patientProfileModel,
    required this.anomalies,
  });

  factory ReportModel.fromMap(Map<String, dynamic> map) {
    return ReportModel(
      timestamp: map['timestamp'],
      description: map['description'] ?? '',
      brief: map['brief'] ?? '',
      docSuggestions: map['docSuggestions'] ?? '',
      aiSuggestions: map['aiSuggestions'] ?? '',
      graph: map['graph'] ?? '',
      reportId: map['reportId'] ?? '',
      isEditing: map['isEditing'] ?? false,
      anomalies: map['anomalies'] ?? '',
      patientProfileModel: PatientReportModel.fromMap(
          map), // Assuming PatientReportModel has a fromMap method
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'timestamp': timestamp,
      'description': description,
      'brief': brief,
      'docSuggestions': docSuggestions,
      'aiSuggestions': aiSuggestions,
      'graph': graph,
      'reportId': reportId,
      'anomalies': anomalies,
      'isEditing': isEditing,
      'patientProfileModel': patientProfileModel
          .toMap(), // Assuming PatientReportModel has a toMap method
    };
  }
}
