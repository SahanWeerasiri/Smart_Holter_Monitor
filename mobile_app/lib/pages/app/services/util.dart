String getAge(String birthday) {
  //birthday = YYYY-MM-DD
  final data = birthday.split('-');
  int year = int.parse(data[0]);
  int month = int.parse(data[1]);
  int day = int.parse(data[2].split(' ')[0]);
  DateTime currentDate = DateTime.now();
  int age = currentDate.year - year;
  int monthDiff = currentDate.month - month;

  if (monthDiff < 0 || (monthDiff == 0 && currentDate.day < day)) {
    age--;
  }
  return age.toString();
}

Map<String, int> convertToInt(data) {
  Map<String, int> dataHolter = {};

  data.forEach((date, value) {
    int parsedValue = int.tryParse(value) ??
        0; // Convert value string to int, default to 0 if invalid
    dataHolter[date] = parsedValue; // Simple assignment works better here
  });

  return dataHolter;
}

// int getHeartBeat(Map<String, int> data) {
//   int gap = 50;
//   int middle = 2047;
//   if (data.isEmpty) return 0;

//   List<DateTime> timestamps = [];
//   for (var key in data.keys) {
//     try {
//       timestamps.add(DateTime.parse(key));
//     } catch (e) {
//       print('Error parsing date: $key, Error: $e');
//     }
//   }

//   if (timestamps.isEmpty) return 0;

//   timestamps.sort((a, b) => b.compareTo(a)); // Sort in descending order

//   int i = 0;
//   DateTime current = timestamps[i];

//   // Find the first non-zero value
//   while (i < timestamps.length &&
//       data[current.toString()]! <= (middle + gap) &&
//       data[current.toString()]! >= (middle - gap)) {
//     i++;
//     if (i >= timestamps.length) return 0;
//     current = timestamps[i];
//   }

//   // Find the next zero value
//   while (i < timestamps.length &&
//       data[current.toString()]! >= middle + gap &&
//       data[current.toString()]! <= middle - gap) {
//     i++;
//     if (i >= timestamps.length) return 0;
//     current = timestamps[i];
//   }

//   // Find the next non-zero value (start of first beat)
//   while (i < timestamps.length &&
//       data[current.toString()]! <= (middle + gap) &&
//       data[current.toString()]! >= (middle - gap)) {
//     i++;
//     if (i >= timestamps.length) return 0;
//     current = timestamps[i];
//   }

//   DateTime start = current;
//   int count = 1; // We found one beat

//   // Get the direction of the signal change
//   bool isPositive = false;
//   if (i > 0 && i < timestamps.length) {
//     isPositive =
//         data[current.toString()]! > data[timestamps[i - 1].toString()]!;
//   }

//   // Look for 4 more beats
//   while (count < 5 && i < timestamps.length - 1) {
//     i++;
//     DateTime previous = current;
//     current = timestamps[i];

//     bool currentIsPositive =
//         data[current.toString()]! > data[previous.toString()]!;

//     // If we have a change in direction, count it as a beat
//     if (currentIsPositive != isPositive) {
//       count++;
//       isPositive = currentIsPositive;
//     }
//   }

//   if (count < 5) return 0; // Couldn't find 5 beats

//   DateTime end = current;

//   // Calculate duration in minutes
//   Duration duration = end.difference(start);
//   double totalMinutes = duration.inMilliseconds / (1000 * 60);

//   if (totalMinutes <= 0) return 0;

//   // Calculate beats per minute (5 beats in total_minutes)
//   int bpm = (5 / totalMinutes).round();

//   return bpm;
// }

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

  print('DDD');
  if (timestamps.isEmpty) return 0;

  timestamps.sort((a, b) => b.compareTo(a)); // Sort in descending order

  List<String> filteredTimestamps = [];

  for (var t in timestamps) {
    filteredTimestamps.add(t.toString().split('.')[0]);
  }

  print(filteredTimestamps);

  int i = 0;
  String current = filteredTimestamps[i];

  int? currentValue = data[current.toString()];
  print('Prevent null errors');
  if (currentValue == null) return 0; // Prevent null errors

  // Find the first non-zero value
  while (i < filteredTimestamps.length &&
      (data[current] ?? middle) <= (middle + gap) &&
      (data[current] ?? middle) >= (middle - gap)) {
    i++;
    print('CCC');
    if (i >= filteredTimestamps.length) return 0;
    current = filteredTimestamps[i];
  }

  // Find the next zero value
  while (i < filteredTimestamps.length &&
      (data[current] ?? middle) >= (middle + gap) &&
      (data[current] ?? middle) <= (middle - gap)) {
    i++;
    print('BBB');
    if (i >= filteredTimestamps.length) return 0;
    current = filteredTimestamps[i];
  }

  // Find the next non-zero value (start of first beat)
  while (i < filteredTimestamps.length &&
      (data[current] ?? middle) <= (middle + gap) &&
      (data[current] ?? middle) >= (middle - gap)) {
    i++;
    print('AAA');
    if (i >= filteredTimestamps.length) return 0;
    current = filteredTimestamps[i];
  }

  String start = current;
  int count = 1; // We found one beat

  // Get the direction of the signal change
  bool isPositive = false;
  if (i > 0 && i < filteredTimestamps.length) {
    isPositive =
        (data[current] ?? middle) > (data[filteredTimestamps[i - 1]] ?? middle);
  }

  // Look for 4 more beats
  while (count < 5 && i < filteredTimestamps.length - 1) {
    i++;
    String previous = current;
    current = filteredTimestamps[i];

    bool currentIsPositive =
        (data[current] ?? middle) > (data[previous] ?? middle);

    // If we have a change in direction, count it as a beat
    if (currentIsPositive != isPositive) {
      count++;
      isPositive = currentIsPositive;
    }
  }

  print('Couldnt find 5 beats');
  print(count);
  if (count < 5) return 0; // Couldn't find 5 beats

  String end = current;

  // Calculate duration in minutes
  Duration duration = DateTime.parse(start).difference(DateTime.parse(end));
  double totalMinutes = duration.inMilliseconds / (1000 * 60);

  print(totalMinutes);
  print(duration);

  if (totalMinutes <= 0) return 0;

  // Calculate beats per minute (5 beats in total_minutes)
  int bpm = (5 / totalMinutes).round();

  return bpm;
}
