import 'package:health_care_web/models/contact_profile_model.dart';

class UserProfileModel {
  final String id;
  final String name;
  final String age;
  final String email;
  final String pic;
  final String address;
  final String mobile;
  final String color;
  final String language;
  final List<ContactProfileModel> contacts;

  UserProfileModel({
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
  });

  factory UserProfileModel.fromMap(Map<String, dynamic> map) {
    return UserProfileModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      age: map['age'] ?? '',
      email: map['email'] ?? '',
      pic: map['pic'] ?? '',
      address: map['address'] ?? '',
      mobile: map['mobile'] ?? '',
      color: map['color'] ?? '',
      language: map['language'] ?? '',
      contacts: [], //contacts need to be fetched separately
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
    };
  }
}
