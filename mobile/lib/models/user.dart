class User {
  final String id;
  final String name;
  final String email;
  final String? password;
  final String? address;
  final String? phone;
  final String? language;
  final String? profileImage;
  final String? connectedDevice;
  final DateTime? deviceDeadline;
  final List<EmergencyContact> emergencyContacts;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.password,
    this.address,
    this.phone,
    this.language,
    this.profileImage,
    this.connectedDevice,
    this.deviceDeadline,
    this.emergencyContacts = const [],
  });

  User copyWith({
    String? name,
    String? address,
    String? phone,
    String? language,
    String? profileImage,
    String? connectedDevice,
    DateTime? deviceDeadline,
    List<EmergencyContact>? emergencyContacts,
  }) {
    return User(
      id: id,
      name: name ?? this.name,
      email: email,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      language: language ?? this.language,
      profileImage: profileImage ?? this.profileImage,
      connectedDevice: connectedDevice ?? this.connectedDevice,
      deviceDeadline: deviceDeadline ?? this.deviceDeadline,
      emergencyContacts: emergencyContacts ?? this.emergencyContacts,
    );
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['_id'],
      name: map['name'],
      email: map['email'],
      password: map['password'],
      address: map['address'],
      phone: map['phone'],
      language: map['language'],
      profileImage: map['profileImage'],
      emergencyContacts: (map['emergencyContacts'] as List<dynamic>?)
              ?.map((e) => EmergencyContact.fromMap(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'password': password,
      'address': address,
      'phone': phone,
      'language': language,
      'profileImage': profileImage,
      'emergencyContacts': emergencyContacts.map((e) => e.toMap()).toList(),
    };
  }
}

class EmergencyContact {
  final String id;
  final String name;
  final String phone;

  EmergencyContact({
    required this.id,
    required this.name,
    required this.phone,
  });

  factory EmergencyContact.fromMap(Map<String, dynamic> map) {
    return EmergencyContact(
      id: map['_id'],
      name: map['name'],
      phone: map['phone'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'name': name,
      'phone': phone,
    };
  }
}
