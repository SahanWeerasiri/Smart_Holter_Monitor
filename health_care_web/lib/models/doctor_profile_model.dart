import 'package:flutter/material.dart';
import 'package:health_care_web/models/patient_profile_model.dart';
import 'package:health_care_web/models/report_model.dart';
import 'package:health_care_web/models/return_model.dart';
import 'package:health_care_web/services/firestore_db_service.dart';

class DoctorProfileModel {
  final String id;
  final String name;
  final String age;
  final String email;
  final String pic;
  final String address;
  final String mobile;
  final String color;
  final List<PatientProfileModel> patients;

  DoctorProfileModel({
    required this.id,
    required this.name,
    required this.age,
    required this.email,
    this.pic = "",
    this.address = "",
    this.mobile = "",
    this.color = "",
    this.patients = const [],
  });

  factory DoctorProfileModel.fromMap(Map<String, dynamic> map) {
    return DoctorProfileModel(
      id: map['id'],
      name: map['name'] ?? '',
      age: map['age'] ?? '',
      email: map['email'] ?? '',
      pic: map['pic'] ?? '',
      address: map['address'] ?? '',
      mobile: map['mobile'] ?? '',
      color: map['color'] ?? '',
      patients: [], //Patients need to be fetched separately!
    );
  }

  Future<void> saveReport(String uid,ReportModel selectedReport, BuildContext context)async{
    ReturnModel res =
        await FirestoreDbService().saveReport(uid, selectedReport);
    if (res.state) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res.message),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res.message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> saveDraftReport(String uid, ReportModel selectedReport, BuildContext context)async{
    ReturnModel res =
        await FirestoreDbService().saveReportData(uid, selectedReport);
    if (res.state) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res.message),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res.message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'email': email,
      'pic': pic,
      'address': address,
      'mobile': mobile,
      'color': color,
    };
  }
}

class DoctorReportModel {
  final String name;
  final String email;
  final String address;
  final String mobile;

  DoctorReportModel({
    required this.name,
    required this.email,
    this.address = "",
    this.mobile = "",
  });
  //Add factory constructor and toMap method
  factory DoctorReportModel.fromMap(Map<String, dynamic> map) {
    return DoctorReportModel(
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      address: map['address'],
      mobile: map['mobile'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'address': address,
      'mobile': mobile,
    };
  }
}
