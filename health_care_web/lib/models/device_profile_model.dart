class DeviceProfile {
  String code;
  String use;
  String detail;
  int state;
  String deadline;
  DeviceProfile({
    required this.code,
    this.detail = "",
    required this.use,
    required this.deadline,
    this.state = 0,
  });
}
