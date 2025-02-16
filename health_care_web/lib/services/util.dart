import 'package:flutter/material.dart';

List<String> generateTags(String name) {
  // Convert the name to lowercase to make all tags simple
  String lowerCaseName = name.toLowerCase();

  // Generate the tags
  List<String> tags = [];
  for (int i = 1; i <= lowerCaseName.length; i++) {
    tags.add(lowerCaseName.substring(0, i));
  }

  return tags;
}

String getAge(String birthday) {
  //birthday = YYYY-MM-DD
  final data = birthday.split('-');
  int year = int.parse(data[0]);
  int month = int.parse(data[1]);
  int day = int.parse(data[2]);
  DateTime currentDate = DateTime.now();
  int age = currentDate.year - year;
  int monthDiff = currentDate.month - month;

  if (monthDiff < 0 || (monthDiff == 0 && currentDate.day < day)) {
    age--;
  }
  return age.toString();
}

void showMessages(bool state, String message, BuildContext context) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: state ? Colors.green : Colors.red,
      ),
    );
  });
}

bool listEquals(List<dynamic> list1, List<dynamic> list2) {
  if (list1.length != list2.length) return false;
  for (int i = 0; i < list1.length; i++) {
    if (list1[i] != list2[i]) return false;
  }
  return true;
}
