import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:health_care_web/controllers/profileController.dart';
import 'package:health_care_web/models/patient_profile_model.dart';
import 'package:health_care_web/models/report_model.dart';
import 'package:health_care_web/models/return_model.dart';
import 'package:health_care_web/services/firestore_db_service.dart';
import 'package:health_care_web/services/real_db_service.dart';
import 'package:health_care_web/services/util.dart';

class DoctorProfileModel {
  final String id;
  final String name;
  final String email;
  final String pic;
  final String address;
  final String mobile;
  final String color;
  final List<PatientProfileModel> patients;

  DoctorProfileModel({
    required this.id,
    required this.name,
    required this.email,
    this.pic = "",
    this.address = "",
    this.mobile = "",
    this.color = "",
    this.patients = const [],
  });

  factory DoctorProfileModel.fromMap(Map<String, dynamic> map, String id) {
    return DoctorProfileModel(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      pic: map['pic'] ?? '',
      address: map['address'] ?? '',
      mobile: map['mobile'] ?? '',
      color: map['color'] ?? '',
      patients: [], //Patients need to be fetched separately!
    );
  }

  Future<DoctorProfileModel> initDoctor(BuildContext context) async {
    ReturnModel res = await FirestoreDbService().fetchAccount();
    if(res.state){
      showMessages(res.state, res.message, context);
    }else{
      showMessages(res.state, res.message, context);
    }

    return res.doctorProfileModel!;
  }


  Future<void> saveReport(ReportModel selectedReport, BuildContext context)async{
    ReturnModel res =
        await FirestoreDbService().saveReport(selectedReport);
    if (res.state) {
      Navigator.pop(context);
    }
    showMessages(res.state,res.message,context);
  }

  Future<void> saveDraftReport(ReportModel selectedReport, BuildContext context)async{
    ReturnModel res =
        await FirestoreDbService().saveReportData(selectedReport);
    if (res.state) {
      Navigator.pop(context);
    }
    showMessages(res.state,res.message,context);
  
  }

  Future<ReturnModel> fetchCurrentPatient(BuildContext context) async{
    ReturnModel res = ReturnModel(state: false, message: "");
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        showMessages(true, "Wave01", context);
        throw Exception("User is not logged in.");
      }

      ReturnModel res =
          await FirestoreDbService().fetchCurrentPatients(user.uid);

      showMessages(res.state, res.message, context);
    } catch (e) {
      showMessages(true, "Wave02", context);
      showMessages(false, e.toString(), context);
    }
    return res;
  }

  Future<ReportModel?> fetchAIReport(String uid, BuildContext context) async {
    // Fetching ai report

    try {
      ReturnModel res =
          await FirestoreDbService().getLatestDeviceReadings(uid);

      if (res.state) {

        /*
        
        Add AI integration here
        
        */


        return res.reportModel;
      } else {
        showMessages(res.state, res.message, context);
        return null;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return null;
    }
  }

  Future<List<dynamic>?> createReport(PatientProfileModel profile, BuildContext context) async {

    final ReportModel? reportModel = await fetchAIReport(profile.id,context);
    final ReturnModel reports =
        await FirestoreDbService().fetchReports(profile.id);

    if (reportModel == null) {
      showMessages(false, "No data found for the new report", context);
      return null;
    }

    if (!reports.state) {
      showMessages(reports.state, reports.message, context);
      return null;
    }

    return [reportModel, reports];
  }

  Future<List<ReportModel>?> viewReports(PatientProfileModel profile, BuildContext context) async {
    
    final ReturnModel reports =
        await FirestoreDbService().fetchReports(profile.id);

    if (!reports.state) {
      showMessages(reports.state, reports.message, context);
      return null;
    }
    return reports.reports;
  }

  Future<void> removeDevice(String uid, String deviceId, BuildContext context) async {
    
    ReturnModel res =
        await FirestoreDbService().removeDeviceFromPatient(uid, deviceId);
    showMessages(res.state, res.message, context);
  }


  Future<void> removePatients(String id, BuildContext context) async {
    ReturnModel res = await FirestoreDbService().removePatient(id);
    showMessages(res.state, res.message, context);
  }

  Future<void> addPatients(String id,String docId,BuildContext context ) async {
    ReturnModel res = await FirestoreDbService().addPatient(id, docId);
    showMessages(res.state, res.message, context);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'pic': pic,
      'address': address,
      'mobile': mobile,
      'color': color,
    };
  }

  Future<DoctorProfileModel?> fetchProfileData(BuildContext context) async {
    ReturnModel res = await FirestoreDbService()
        .fetchAccount();
    if (res.state) {
      return res.doctorProfileModel;
    } else {
      showMessages(res.state, res.message, context);
      return null;
    }
    
  }

  Future<void> updateProfile(BuildContext context, ProfileController profileController)async {
    ReturnModel res = await FirestoreDbService().updateProfile(
        FirebaseAuth.instance.currentUser!.uid,
        profileController.mobile.text,
        profileController.language.text,
        profileController.address.text,
        profileController.pic.text);
    showMessages(res.state, res.message, context);
  }

  DoctorReportModel toDoctorReportModel (){
    return DoctorReportModel(id: id, name: name, email: email, address: address,mobile: mobile);
  }

  Future<List<PatientProfileModel>> fetchAllPatients(BuildContext context) async{
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("User is not logged in.");
      }

      ReturnModel res = await FirestoreDbService().fetchPatients();

      if (res.state) {
        for(PatientProfileModel patient in res.patients){
          if(patient.docId!=""){
            patient.doctorProfileModel = (await FirestoreDbService().fetchDoctorOne(patient.docId))!;
            // showMessages(true, "${patient.id} | ${patient.doctorProfileModel!.email} | ${patient.docId}", context);
          }
          ReturnModel res = await RealDbService().fetchDeviceData(patient.deviceId);
          if(res.state){
            patient.device = res.deviceProfileModel;
            // showMessages(true, "${patient.id} | ${patient.device!.deadline} | ${patient.docId}", context);
          }

        }
        
        return res.patients;
        
      } else {
        showMessages(res.state, res.message, context);
        return [];
      }
    } catch (e) {
      showMessages(false, e.toString(), context);
        return [];
    }
  }

  Future<List<PatientProfileModel>> fetchSearchPatients(String name, BuildContext context) async{
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("User is not logged in.");
      }

      ReturnModel res = await FirestoreDbService().fetchSearchPatients(name.toLowerCase());

      if (res.state) {
        for(PatientProfileModel patient in res.patients){
          if(patient.docId!=""){
            patient.doctorProfileModel = (await FirestoreDbService().fetchDoctorOne(patient.docId))!;
            // showMessages(true, "${patient.id} | ${patient.doctorProfileModel!.email} | ${patient.docId}", context);
          }
          ReturnModel res = await RealDbService().fetchDeviceData(patient.deviceId);
          if(res.state){
            patient.device = res.deviceProfileModel;
            // showMessages(true, "${patient.id} | ${patient.device!.deadline} | ${patient.docId}", context);
          }

        }
        
        return res.patients;
        
      } else {
        showMessages(res.state, res.message, context);
        return [];
      }
    } catch (e) {
      showMessages(false, e.toString(), context);
        return [];
    }
  }
}

class DoctorReportModel {
  final String id;
  final String name;
  final String email;
  final String address;
  final String mobile;

  DoctorReportModel({
    required this.id,
    required this.name,
    required this.email,
    this.address = "",
    this.mobile = "",
  });
  //Add factory constructor and toMap method
  factory DoctorReportModel.fromMap(Map<String, dynamic> map) {
    return DoctorReportModel(
      id: map['id'],
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      address: map['address'],
      mobile: map['mobile'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'address': address,
      'mobile': mobile,
    };
  }
}
