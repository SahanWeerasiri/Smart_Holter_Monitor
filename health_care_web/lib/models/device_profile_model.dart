class DeviceProfileModel {
  String code;
  String use;
  String detail;
  int state;
  String deadline;
  String latestValue;
  String avgValue;
  Map<String, String> data;
  static final int notAssigned = 0;
  static final int assigned = 1;
  static final int pending = 2;
  DeviceProfileModel({
    required this.code,
    required this.detail,
    required this.use,
    required this.deadline,
    required this.latestValue,
    required this.avgValue,
    this.state = 0,
    this.data = const {},
  });

  static DeviceProfileModel fromMap(Map<String, dynamic> map) {
    return DeviceProfileModel(
      code: map['code'],
      detail: map['detail'],
      use: map['use'],
      state: map['state'],
      deadline: map['deadline'],
      latestValue: "",
      avgValue: "",
      data: const {},
    );
  }

  static Map<String, dynamic> toMap(DeviceProfileModel deviceProfileModel) {
    return {
      'code': deviceProfileModel.code,
      'detail': deviceProfileModel.detail,
      'use': deviceProfileModel.use,
      'state': deviceProfileModel.state,
      'deadline': deviceProfileModel.deadline,
      'latestValue': deviceProfileModel.latestValue,
      'avgValue': deviceProfileModel.avgValue,
      'data': deviceProfileModel.data,
    };
  }
}

class DeviceReportModel {
  String code;
  String detail;
  String deadline;
  String avgValue;
  Map<String, String> data;
  static final int notAssigned = 0;
  static final int assigned = 1;
  static final int pending = 2;
  DeviceReportModel({
    required this.code,
    required this.detail,
    required this.deadline,
    required this.avgValue,
    this.data = const {},
  });

  factory DeviceReportModel.fromMap(Map<String, dynamic> map) {
    return DeviceReportModel(
      code: map['code'] ?? '',
      detail: map['detail'],
      deadline: map['deadline'],
      avgValue: map['avgValue'],
      data: map['data'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'detail': detail,
      'deadline': deadline,
      'avgValue': avgValue,
      'data': data,
    };
  }
}
