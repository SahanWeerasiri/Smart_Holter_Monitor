import 'package:firebase_database/firebase_database.dart';
import 'package:health_care_web/constants/consts.dart';

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

  Future<Map<String, dynamic>> fetchDevices() async {
    // Reference to the device's data
    try {
      final ref = _database.ref('devices');
      final DataSnapshot dataSnapshot = await ref.get();

      List<DeviceProfile> devices = [];

      for (final child in dataSnapshot.children) {
        final device = child.key;
        final other = child.child('other').value as String;
        bool state = false;
        try {
          final data = child.child('data').value as Map<dynamic, dynamic>;
          if (data.isNotEmpty) {
            state = true;
          }
        } catch (e) {
          state = false;
        }
        devices.add(DeviceProfile(
            code: device.toString(), detail: other.toString(), state: state));
      }

      return {
        'success': true,
        'data': devices,
      };
    } catch (e) {
      return {
        'success': false,
        'data': 'Error fetching devices $e',
      };
    }
  }

  Future<Map<String, dynamic>> fetchSearchDevices(String name) async {
    // Reference to the device's data
    try {
      final ref = _database.ref('devices');
      final DataSnapshot dataSnapshot = await ref.get();

      List<DeviceProfile> devices = [];

      for (final child in dataSnapshot.children) {
        final device = child.key.toString();
        final other = child.child('other').value as String;
        if (device.toLowerCase().contains(name)) {
          bool state = false;
          try {
            final data = child.child('data').value as Map<dynamic, dynamic>;
            if (data.isNotEmpty) {
              state = true;
            }
          } catch (e) {
            state = false;
          }
          devices.add(DeviceProfile(
              code: device.toString(), detail: other.toString(), state: state));
        }
      }

      return {
        'success': true,
        'data': devices,
      };
    } catch (e) {
      return {
        'success': false,
        'data': 'Error fetching devices $e',
      };
    }
  }

  Future<Map<String, dynamic>> addDevice(String code, String other) async {
    final DatabaseReference ref = _database.ref('devices').child(code);
    try {
      // Check if the ref already exists
      final DataSnapshot snapshot = await ref.get();

      if (snapshot.exists) {
        // If the device already exists, return an error
        return {'success': false, 'message': 'Device already exists.'};
      } else {
        // If the device does not exist, add the data
        await ref.set({'other': other});
        return {'success': true, 'message': 'Device added successfully.'};
      }
    } catch (e) {
      // Handle any errors during the operation
      return {'success': false, 'message': 'An error occurred: $e'};
    }
  }

  Future<Map<String, dynamic>> transferDeviceData(String code) async {
    final DatabaseReference ref =
        _database.ref('devices').child(code).child('data');
    try {
      // Check if the ref already exists
      final DataSnapshot snapshot = await ref.get();

      if (snapshot.exists) {
        // If the device already exists, return an error
        return {
          'success': true,
          'data': snapshot.value as Map<dynamic, dynamic>
        };
      } else {
        // If the device does not exist, add the data
        return {
          'success': false,
          'message': 'Device data are not retrieved successfully.'
        };
      }
    } catch (e) {
      // Handle any errors during the operation
      return {'success': false, 'message': 'An error occurred: $e'};
    }
  }

  Future<Map<String, dynamic>> deleteDeviceData(String code) async {
    final DatabaseReference ref =
        _database.ref('devices').child(code).child('data');
    try {
      // Check if the ref already exists
      await ref.remove();

      return {'success': true, 'data': 'Data removed from the device.'};
    } catch (e) {
      // Handle any errors during the operation
      return {'success': false, 'message': 'An error occurred: $e'};
    }
  }
}
