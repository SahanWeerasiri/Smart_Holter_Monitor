import 'package:health_care_web/models/device_profile_model.dart';
import 'package:health_care_web/models/doctor_profile_model.dart';
import 'package:health_care_web/models/user_profile_model.dart';

class PatientProfileModel extends UserProfileModel {
  final bool isDone;
  final DeviceProfileModel? device;
  final DoctorProfileModel doctorProfileModel;

  PatientProfileModel({
    required super.id,
    required super.name,
    required super.age,
    required super.email,
    super.pic = "",
    super.address = "",
    super.mobile = "",
    super.color = "",
    super.language = "",
    required this.isDone,
    super.contacts = const [],
    required this.device,
    required this.doctorProfileModel,
  });

  factory PatientProfileModel.fromMap(Map<String, dynamic> map, String id) {
    // Get Doctor profile separately
    return PatientProfileModel(
        id: id,
        name: map['name'] ?? '',
        age: map['age'] ?? '',
        email: map['email'] ?? '',
        pic: map['pic'] ?? '',
        address: map['address'] ?? '',
        mobile: map['mobile'] ?? '',
        color: map['color'] ?? '',
        language: map['language'] ?? '',
        isDone: map['isDone'] ?? false,
        device: map['device'] != null
            ? DeviceProfileModel.fromMap(map['device'])
            : null,
        doctorProfileModel: DoctorProfileModel(
            id: "",
            name: "",
            age: "",
            email: "",
            pic: "",
            address: "",
            mobile: "",
            color: "",
            patients: []));
  }

  @override
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
      'isDone': isDone,
      'device': DeviceProfileModel.toMap(device!),
      'doctorProfileModel': doctorProfileModel.toMap(),
    };
  }
}

class PatientReportModel extends UserProfileModel {
  final bool isDone;
  final DeviceReportModel device;
  final DoctorReportModel doctorProfileModel;

  PatientReportModel({
    required super.id,
    required super.name,
    required super.age,
    required super.email,
    super.pic = "",
    super.address = "",
    super.mobile = "",
    super.color = "",
    super.language = "",
    required this.isDone,
    super.contacts = const [],
    required this.device,
    required this.doctorProfileModel,
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
      isDone: map['isDone'] ?? false,
      device: DeviceReportModel.fromMap(map), //Assuming a fromMap method exists
      doctorProfileModel:
          DoctorReportModel.fromMap(map), //Assuming a fromMap method exists
    );
  }

  @override
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
      'isDone': isDone,
      'device': device.toMap(),
      'doctorProfileModel': doctorProfileModel.toMap(),
    };
  }
}
