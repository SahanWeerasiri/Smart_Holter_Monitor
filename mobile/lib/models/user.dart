class User {
  final String id;
  final String name;
  final String email;
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
}
