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

Map<String, int> convertToInt(data) {
  Map<String, int> dataHolter = {};

  data.forEach((date, value) {
    int parsedValue = int.tryParse(value) ??
        0; // Convert value string to int, default to 0 if invalid
    dataHolter[date] = parsedValue; // Simple assignment works better here
  });

  return dataHolter;
}
