import 'package:health_care_web/constants/consts.dart';
import 'package:health_care_web/models/contact_profile_model.dart';

class UserProfile {
  String id;
  String name;
  String age;
  String email;
  String pic;
  String address;
  String mobile;
  String color;
  bool isDone;
  String language;
  String device;
  String doctorId;
  List<ContactProfile> contacts;
  UserProfile({
    required this.id,
    required this.name,
    this.age = "0",
    required this.email,
    this.pic = "",
    this.address = "",
    this.mobile = "",
    this.device = "",
    this.color = "",
    this.isDone = false,
    this.language = "",
    this.doctorId = "",
    this.contacts = const [],
  });
}
