import 'package:health_care_web/models/contact_profile_model.dart';
import 'package:health_care_web/models/device_profile_model.dart';
import 'package:health_care_web/models/doctor_profile_model.dart';
import 'package:health_care_web/models/return_model.dart';
import 'package:health_care_web/services/firestore_db_service.dart';

class PatientProfileModel{
  bool isDone;
  DeviceProfileModel? device;
  DoctorProfileModel? doctorProfileModel;
  String docId;
  String deviceId;
  String id;
  String address;
  String name;
  String email;
  String age;
  String pic;
  String mobile;
  String color;
  String language;
  List<ContactProfileModel> contacts;


  PatientProfileModel({
    required this.id,
    required this.name,
    required this.age,
    required this.email,
    required this.docId,
    required this.deviceId,
    this.pic = "",
    this.address = "",
    this.mobile = "",
    this.color = "",
    this.language = "",
    this.isDone = false,
    this.contacts = const [],
    this.device,
    this.doctorProfileModel,
  });

  factory PatientProfileModel.fromMap(Map<String, dynamic> map, String id) {
    // Get Doctor profile separately
    return PatientProfileModel(
        id: id,
        name: map['name'] ?? '',
        age: map['age'] ?? '',
        email: map['email'] ?? '',
        docId: map['docId'] ?? '',
        deviceId: map['deviceId'] ?? '',
        pic: map['pic'] ?? '',
        address: map['address'] ?? '',
        mobile: map['mobile'] ?? '',
        color: map['color'] ?? '',
        language: map['language'] ?? '',
        isDone: map['isDone'] ?? false,
        device: null,
        doctorProfileModel: null,
        contacts: []);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'email': email,
      'pic': pic,
      'docId': docId,
      'deviceId': deviceId,
      'address': address,
      'mobile': mobile,
      'color': color,
      'language': language,
      'isDone': isDone,
      'device': DeviceProfileModel.toMap(device!),
      'doctorProfileModel': doctorProfileModel!.toMap(),
    };
  }

  PatientReportModel toPatientReportModel() {
    return PatientReportModel(
      id: id,
      name: name,
      email: email,
      mobile: mobile,
      address: address,
      age: age,
      device: null,
      doctorProfileModel: null,

    );
  }

  Future<void> addContacts()async{
    ReturnModel res = await FirestoreDbService().fetchContacts(id);
    if(res.state){
      contacts = res.contacts;
    }else{
      contacts = [];
    }
  }
}

class PatientReportModel {
  DeviceReportModel? device;
  DoctorReportModel? doctorProfileModel;
  String id;
  String address;
  String name;
  String email;
  String age;
  String pic;
  String mobile;
  String color;
  String language;
  List<String> contacts;

  PatientReportModel({
    required this.id,
    required this.name,
    required this.age,
    required this.email,
    this.pic = "",
    this.address = "",
    this.mobile = "",
    this.color = "",
    this.language = "",
    this.contacts = const [],
    this.device,
    this.doctorProfileModel,
  });

  factory PatientReportModel.fromMap(Map<String, dynamic> map) {
    return PatientReportModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      age: map['age'] ?? '',
      email: map['email'] ?? '',
      pic: map['pic'] ?? '',
      address: map['address'] ?? '',
      mobile: map['mobile'] ?? '',
      color: map['color'] ?? '',
      language: map['language'] ?? '',
      device: DeviceReportModel.fromMap(map), //Assuming a fromMap method exists
      doctorProfileModel:
          DoctorReportModel.fromMap(map), //Assuming a fromMap method exists
    );
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
      'language': language,
      'device': device!.toMap(),
      'doctorProfileModel': doctorProfileModel!.toMap(),
    };
  }
}
