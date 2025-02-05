import 'package:health_care_web/models/device_profile_model.dart';
import 'package:health_care_web/models/doctor_profile_model.dart';
import 'package:health_care_web/models/patient_profile_model.dart';
import 'package:health_care_web/models/report_model.dart';
import 'package:health_care_web/models/user_profile_model.dart';

class ReturnModel {
  bool state;
  String message;
  DeviceProfileModel? deviceProfileModel;
  UserProfileModel? userProfileModel;
  DoctorProfileModel? doctorProfileModel;
  PatientProfileModel? patientProfileModel;
  ReportModel? reportModel;
  List<UserProfileModel> users;
  List<DoctorProfileModel> doctors;
  List<PatientProfileModel> patients;
  List<DeviceProfileModel> devices;
  List<ReportModel> reports;
  ReturnModel({
    required this.state,
    required this.message,
    this.deviceProfileModel,
    this.userProfileModel,
    this.doctorProfileModel,
    this.patientProfileModel,
    this.reportModel,
    this.reports = const [],
    this.devices = const [],
    this.patients = const [],
    this.users = const [],
    this.doctors = const [],
  });
}
