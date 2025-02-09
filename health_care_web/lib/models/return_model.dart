import 'package:health_care_web/models/contact_profile_model.dart';
import 'package:health_care_web/models/device_profile_model.dart';
import 'package:health_care_web/models/doctor_profile_model.dart';
import 'package:health_care_web/models/patient_profile_model.dart';
import 'package:health_care_web/models/report_model.dart';

class ReturnModel {
  bool state;
  String message;
  DeviceProfileModel? deviceProfileModel;
  DoctorProfileModel? doctorProfileModel;
  PatientProfileModel? patientProfileModel;
  ReportModel? reportModel;
  ContactProfileModel? contactModel;
  List<DoctorProfileModel> doctors;
  List<PatientProfileModel> patients;
  List<DeviceProfileModel> devices;
  List<ReportModel> reports;
  List<ContactProfileModel> contacts;
  ReturnModel({
    required this.state,
    required this.message,
    this.deviceProfileModel,
    this.doctorProfileModel,
    this.patientProfileModel,
    this.reportModel,
    this.contactModel,
    this.contacts = const [],
    this.reports = const [],
    this.devices = const [],
    this.patients = const [],
    this.doctors = const [],
  });
}
