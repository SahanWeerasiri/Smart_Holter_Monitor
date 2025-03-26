import 'package:firebase_auth/firebase_auth.dart';
import 'package:health_care/pages/app/services/firestore_db_service.dart';
import 'package:health_care/pages/app/services/real_db_service.dart';
import 'package:health_care/pages/app/services/util.dart';

class Account {
  static final Account _instance = Account._internal();

  String uid = "";
  String name = "";
  String address = "";
  String mobile = "";
  String email = "";
  String birthday = "";
  String profileImage = "";
  String language = "";
  String age = "";
  String deviceId = "";
  String docId = "";
  bool isDone = false;
  String doctorName = "";
  String doctorMobile = "";
  String doctorEmail = "";
  String doctorAddress = "";
  String doctorImageURL = "";
  String doctorHospitalId = "";
  String deviceDescription = "";
  String deviceDeadline = "";
  bool deviceState = false;
  String deviceHospitalId = "";
  String hoispitalName = "";
  String hospitalMobile = "";

  List<Map<String, dynamic>> emergency = [];
  List<Map<String, dynamic>> reports = [];

  factory Account() {
    return _instance;
  }

  Account._internal();

  static Account get instance => _instance;

  // Convert Account to a Map
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'address': address,
      'mobile': mobile,
      'email': email,
      'birthday': birthday,
      'profileImage': profileImage,
      'language': language,
      'age': age,
      'deviceId': deviceId,
      'docId': docId,
      'isDone': isDone,
      'doctorName': doctorName,
      'doctorMobile': doctorMobile,
      'doctorEmail': doctorEmail,
      'doctorAddress': doctorAddress,
      'doctorImageURL': doctorImageURL,
      'doctorHospitalId': doctorHospitalId,
      'deviceDescription': deviceDescription,
      'deviceDeadline': deviceDeadline,
      'deviceState': deviceState,
      'deviceHospitalId': deviceHospitalId,
      'hoispitalName': hoispitalName,
      'hospitalMobile': hospitalMobile,
      'emergency': emergency,
      'reports': reports,
    };
  }

  // Create Account from a Map
  factory Account.fromMap(Map<String, dynamic> map) {
    Account account = Account._internal();
    account.uid = map['uid'] ?? "";
    account.name = map['name'] ?? "";
    account.address = map['address'] ?? "";
    account.mobile = map['mobile'] ?? "";
    account.email = map['email'] ?? "";
    account.birthday = map['birthday'] ?? "";
    account.profileImage = map['profileImage'] ?? "";
    account.language = map['language'] ?? "";
    account.age = map['age'] ?? "";
    account.deviceId = map['deviceId'] ?? "";
    account.docId = map['docId'] ?? "";
    account.isDone = map['isDone'] ?? false;
    account.doctorName = map['doctorName'] ?? "";
    account.doctorMobile = map['doctorMobile'] ?? "";
    account.doctorEmail = map['doctorEmail'] ?? "";
    account.doctorAddress = map['doctorAddress'] ?? "";
    account.doctorImageURL = map['doctorImageURL'] ?? "";
    account.doctorHospitalId = map['doctorHospitalId'] ?? "";
    account.deviceDescription = map['deviceDescription'] ?? "";
    account.deviceDeadline = map['deviceDeadline'] ?? "";
    account.deviceState = map['deviceState'] ?? false;
    account.deviceHospitalId = map['deviceHospitalId'] ?? "";
    account.hoispitalName = map['hoispitalName'] ?? "";
    account.hospitalMobile = map['hospitalMobile'] ?? "";
    account.emergency = List<Map<String, dynamic>>.from(map['emergency'] ?? []);
    account.reports = List<Map<String, dynamic>>.from(map['reports'] ?? []);
    return account;
  }

  Future<void> initialize() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      uid = currentUser.uid;

      try {
        Map<String, dynamic> data =
            await FirestoreDbService().fetchAccount(uid);
        if (data.containsKey('data')) {
          name = data['data']["name"] ?? "";
          address = data['data']["address"] ?? "";
          mobile = data['data']["mobile"] ?? "";
          email = data['data']["email"] ?? "";
          profileImage = data['data']["pic"] ?? "";
          birthday = data['data']["birthday"] ?? "";
          language = data['data']["language"] ?? "";
          deviceId = data['data']["deviceId"] ?? "";
          docId = data['data']["docId"] ?? "";
          isDone = data['data']["isDone"] ?? false;
          age = getAge(birthday);
        }
        print("Personal data initialized");

        // Fetch doctor details
        if (docId.isNotEmpty) {
          Map<String, dynamic> data2 =
              await FirestoreDbService().fetchDoctor(docId);
          if (data2['success'] == true) {
            doctorName = data2['data']["name"] ?? "";
            doctorMobile = data2['data']["mobile"] ?? "";
            doctorEmail = data2['data']["email"] ?? "";
            doctorImageURL = data2['data']["pic"] ?? "";
            doctorAddress = data2['data']["address"] ?? "";
            doctorHospitalId = data2['data']["hospitalId"] ?? "";
          }
        }

        print("Doctor data initialized");

        // Fetch device details
        if (deviceId != "Device") {
          Map<String, dynamic> data3 =
              await RealDbService().fetchDeviceDetails(deviceId);
          print("Device data fetched");
          if (data3['success']) {
            deviceDescription = data3["other"] ?? "";
            deviceDeadline = data3["deadline"] ?? "";
            deviceState = data3["idDone"] ?? false;
            deviceHospitalId = data3["hospitalId"] ?? "";
          }
        }
        print("Device data initialized");

        // Fetch emergency contacts
        Map<String, dynamic> data4 =
            await FirestoreDbService().fetchEmergency(uid);
        if (data4['success']) {
          emergency = data4["data"] ?? [];
        }
        print("Emergency contacts initialized");

        // Fetch reports
        Map<String, dynamic> data5 =
            await FirestoreDbService().fetchReports(uid);
        if (data5['success']) {
          reports = List<Map<String, dynamic>>.from(data5["data_new"] ?? []);
          reports
              .addAll(List<Map<String, dynamic>>.from(data5["data_old"] ?? []));
        }

        Map<String, dynamic> data6 =
            await FirestoreDbService().fetchHospital(doctorHospitalId);
        if (data6['success']) {
          hoispitalName = data6["data"]["name"] ?? "";
          hospitalMobile = data6["data"]["mobile"] ?? "";
        }

        print("Reports initialized");
      } catch (e) {
        print("Error initializing account: $e");
      }
    }
  }

  void clear() {
    uid = "";
    name = "";
    address = "";
    mobile = "";
    profileImage = "";
    email = "";
    birthday = "";
    age = "";
    language = "";
    deviceId = "";
    docId = "";
    isDone = false;
    doctorName = "";
    doctorMobile = "";
    doctorEmail = "";
    doctorAddress = "";
    doctorImageURL = "";
    deviceDescription = "";
    deviceDeadline = "";
    deviceState = false;
    deviceHospitalId = "";
    emergency = [];
    reports = [];
    hoispitalName = "";
    hospitalMobile = "";
  }
}
