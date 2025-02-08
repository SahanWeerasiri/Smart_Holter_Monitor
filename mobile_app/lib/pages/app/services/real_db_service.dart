import 'package:firebase_database/firebase_database.dart';

class RealDbService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  Future<Map<String, dynamic>> fetchDeviceData(String device) async {
    // Reference to the device's data
    final ref = _database.ref('devices').child(device).child('data');

    late String key;
    late String value;
    // Listen for real-time updates
    ref.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data != null && data.isNotEmpty) {
        // Convert the map to a sorted list of entries (descending by timestamp)
        final sortedEntries = data.entries.toList()
          ..sort((a, b) =>
              b.key.compareTo(a.key)); // Sort by key (time_stamp) descending

        // The latest entry will now be the first
        final latestEntry = sortedEntries.first;

        key = latestEntry.key;
        value = latestEntry.value;
      } else {
        key = 'false';
        value = "No Data";
      }
    }, onError: (error) {
      key = 'false';
      value = error.toString();
    });

    return {
      'success': key != 'false' ? true : false,
      'data': value,
      'timestamp': key,
    };
  }
}
