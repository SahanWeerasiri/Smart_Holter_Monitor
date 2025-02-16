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

int getHeartBeat(Map<String, int> data) {
  int gap = 50;
  int middle = 2047;
  if (data.isEmpty) return 0;

  List<DateTime> timestamps = [];
  for (var key in data.keys) {
    try {
      timestamps.add(DateTime.parse(key));
    } catch (e) {
      print('Error parsing date: $key, Error: $e');
    }
  }

  if (timestamps.isEmpty) return 0;

  timestamps.sort((a, b) => b.compareTo(a)); // Sort in descending order

  int i = 0;
  DateTime current = timestamps[i];

  // Find the first non-zero value
  while (i < timestamps.length &&
      data[current.toString()]! <= (middle + gap) &&
      data[current.toString()]! >= (middle - gap)) {
    i++;
    if (i >= timestamps.length) return 0;
    current = timestamps[i];
  }

  // Find the next zero value
  while (i < timestamps.length &&
      data[current.toString()]! >= middle + gap &&
      data[current.toString()]! <= middle - gap) {
    i++;
    if (i >= timestamps.length) return 0;
    current = timestamps[i];
  }

  // Find the next non-zero value (start of first beat)
  while (i < timestamps.length &&
      data[current.toString()]! <= (middle + gap) &&
      data[current.toString()]! >= (middle - gap)) {
    i++;
    if (i >= timestamps.length) return 0;
    current = timestamps[i];
  }

  DateTime start = current;
  int count = 1; // We found one beat

  // Get the direction of the signal change
  bool isPositive = false;
  if (i > 0 && i < timestamps.length) {
    isPositive =
        data[current.toString()]! > data[timestamps[i - 1].toString()]!;
  }

  // Look for 4 more beats
  while (count < 5 && i < timestamps.length - 1) {
    i++;
    DateTime previous = current;
    current = timestamps[i];

    bool currentIsPositive =
        data[current.toString()]! > data[previous.toString()]!;

    // If we have a change in direction, count it as a beat
    if (currentIsPositive != isPositive) {
      count++;
      isPositive = currentIsPositive;
    }
  }

  if (count < 5) return 0; // Couldn't find 5 beats

  DateTime end = current;

  // Calculate duration in minutes
  Duration duration = end.difference(start);
  double totalMinutes = duration.inMilliseconds / (1000 * 60);

  if (totalMinutes <= 0) return 0;

  // Calculate beats per minute (5 beats in total_minutes)
  int bpm = (5 / totalMinutes).round();

  return bpm;
}
