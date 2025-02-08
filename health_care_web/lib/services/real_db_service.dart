import 'package:firebase_database/firebase_database.dart';
import 'package:health_care_web/constants/consts.dart'; // Assuming this contains period
import 'package:health_care_web/models/device_profile_model.dart';
import 'package:health_care_web/models/return_model.dart';

class RealDbService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  Future<ReturnModel> fetchDeviceData(String device) async {
    final ref = _database.ref('devices').child(device);
    try {
      final snapshot =
          await ref.child('data').orderByKey().limitToLast(1).once();
      final data = snapshot.snapshot.value as Map<dynamic, dynamic>?;

      if (data != null && data.isNotEmpty) {
        final latestEntry = data.entries.first;
        final latestValue = latestEntry.value;
        final otherSnapshot = await ref.child('other').once();
        final useSnapshot = await ref.child('use').once();
        final deadlineSnapshot = await ref.child('deadline').once();

        final deviceProfileModel = DeviceProfileModel(
          code: device,
          detail: otherSnapshot.snapshot.value?.toString() ?? "",
          use: useSnapshot.snapshot.value?.toString() ?? "",
          state: DeviceProfileModel
              .notAssigned, // Needs better state handling - consider using enum
          deadline: deadlineSnapshot.snapshot.value?.toString() ?? "",
          latestValue: latestValue.toString(),
          avgValue: fetchDeviceDataAvg(device).toString(),
        );
        return ReturnModel(
            state: true,
            message: 'Data fetched successfully',
            deviceProfileModel: deviceProfileModel);
      } else {
        return ReturnModel(
            state: false, message: 'No data found for this device');
      }
    } catch (e) {
      return ReturnModel(state: false, message: 'Error fetching data: $e');
    }
  }

  Future<ReturnModel> fetchDevices() async {
    try {
      final ref = _database.ref('devices');
      final snapshot = await ref.get();
      final List<DeviceProfileModel> devices = [];
      if (snapshot.exists) {
        for (var element in snapshot.children) {
          devices.add(DeviceProfileModel(
            code: element.key.toString(),
            detail: element.child('other').value?.toString() ?? "",
            use: element.child('use').value?.toString() ?? "",
            state: element.child('assigned').value as int? ??
                DeviceProfileModel.notAssigned,
            deadline: element.child('deadline').value?.toString() ?? "",
            latestValue:
                "", //Not directly available here, fetch separately if needed
            avgValue:
                "", //Not directly available here, fetch separately if needed
          ));
        }
      }
      return ReturnModel(
          state: true,
          message: 'Devices fetched successfully',
          devices: devices);
    } catch (e) {
      return ReturnModel(state: false, message: 'Error fetching devices: $e');
    }
  }

  Future<ReturnModel> fetchSearchDevices(String name) async {
    try {
      final ref = _database.ref('devices');
      final snapshot = await ref.get();
      final List<DeviceProfileModel> devices = [];
      if (snapshot.exists) {
        for (var element in snapshot.children) {
          final deviceCode = element.key.toString();
          if (deviceCode.toLowerCase().contains(name.toLowerCase())) {
            devices.add(DeviceProfileModel(
              code: deviceCode,
              detail: element.child('other').value?.toString() ?? "",
              use: element.child('use').value?.toString() ?? "",
              state: element.child('assigned').value as int? ??
                  DeviceProfileModel.notAssigned,
              deadline: element.child('deadline').value?.toString() ?? "",
              latestValue:
                  "", //Not directly available here, fetch separately if needed
              avgValue:
                  "", //Not directly available here, fetch separately if needed
            ));
          }
        }
      }
      return ReturnModel(
          state: true,
          message: 'Devices fetched successfully',
          devices: devices);
    } catch (e) {
      return ReturnModel(state: false, message: 'Error fetching devices: $e');
    }
  }

  Future<ReturnModel> addDevice(String code, String other) async {
    final ref = _database.ref('devices').child(code);
    try {
      final snapshot = await ref.get();
      if (snapshot.exists) {
        return ReturnModel(state: false, message: 'Device already exists.');
      } else {
        await ref.set({
          'other': other,
          'assigned': 0,
          'is_done': false,
          'deadline': "",
        });
        return ReturnModel(state: true, message: 'Device added successfully.');
      }
    } catch (e) {
      return ReturnModel(state: false, message: 'Error adding device: $e');
    }
  }

  Future<ReturnModel> transferDeviceData(String code) async {
    final ref = _database.ref('devices').child(code).child('data');
    try {
      final snapshot = await ref.get();
      if (snapshot.exists) {
        return ReturnModel(
          state: true,
          message: 'Data retrieved successfully',
          deviceProfileModel: DeviceProfileModel(
            code: code, // Explicitly cast
            detail: (snapshot.value as Map)['detail'] as String,
            use: (snapshot.value as Map)['use'] as String,
            state: (snapshot.value as Map)['assigned'] as int,
            deadline: (snapshot.value as Map)['deadline'] as String,
            latestValue: "",
            avgValue: fetchDeviceDataAvg(code).toString(),
            data: ((snapshot.value as Map)['data']) as Map<String,
                String>, // Assuming you have these fields in the data
          ),
        );
      } else {
        return ReturnModel(state: false, message: 'Device data not found.');
      }
    } catch (e) {
      return ReturnModel(state: false, message: 'Error retrieving data: $e');
    }
  }

  Future<ReturnModel> deleteDeviceData(String code) async {
    final ref = _database.ref('devices').child(code).child('data');
    try {
      await ref.remove();
      await _database
          .ref('devices')
          .child(code)
          .update({'assigned': 0, 'use': ""});
      return ReturnModel(state: true, message: 'Data removed successfully.');
    } catch (e) {
      return ReturnModel(state: false, message: 'Error removing data: $e');
    }
  }

  Future<ReturnModel> connectDeviceData(String code, String other) async {
    try {
      await _database.ref('devices').child(code).update({
        'assigned': DeviceProfileModel.assigned,
        'use': other,
        'deadline': (DateTime.now().add(Duration(hours: period))).toString()
      });
      return ReturnModel(
          state: true, message: 'Device connected successfully.');
    } catch (e) {
      return ReturnModel(state: false, message: 'Error connecting device: $e');
    }
  }

  Future<ReturnModel> connectDevicePending(String code) async {
    try {
      await _database.ref('devices').child(code).update({
        'assigned': DeviceProfileModel.pending,
      });
      return ReturnModel(state: true, message: 'Device set to pending.');
    } catch (e) {
      return ReturnModel(
          state: false, message: 'Error setting device to pending: $e');
    }
  }

  Future<ReturnModel> disconnectDevicePending(String code) async {
    try {
      await _database.ref('devices').child(code).update({
        'assigned': DeviceProfileModel.notAssigned,
      });
      return ReturnModel(state: true, message: 'Device disconnected.');
    } catch (e) {
      return ReturnModel(
          state: false, message: 'Error disconnecting device: $e');
    }
  }

  Future<int> fetchDeviceDataAvg(String device) async {
    final ref = _database.ref('devices').child(device).child('data');
    try {
      final snapshot = await ref.get();
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>?;
        if (data != null && data.isNotEmpty) {
          List<num> values = data.values.whereType<num>().toList();
          if (values.isEmpty) return 0;
          double avg = values.reduce((a, b) => a + b) / values.length;
          return avg.round();
        } else {
          return 0;
        }
      } else {
        return 0;
      }
    } catch (e) {
      return 0;
    }
  }
}

//   Future<Map<String, dynamic>> fetchDevices() async {
//     // Reference to the device's data
//     try {
//       final ref = _database.ref('devices');
//       final DataSnapshot dataSnapshot = await ref.get();

//       List<DeviceProfile> devices = [];

//       for (final child in dataSnapshot.children) {
//         final device = child.key;
//         final other = child.child('other').value as String;
//         final useData = child.child('use').value as String;
//         final state = child.child('assigned').value as int;
//         final deadline = child.child('deadline').value as String;
//         devices.add(DeviceProfile(
//             deadline: deadline.toString(),
//             code: device.toString(),
//             detail: other.toString(),
//             state: state,
//             use: useData.toString()));
//       }

//       return {
//         'success': true,
//         'data': devices,
//       };
//     } catch (e) {
//       return {
//         'success': false,
//         'data': 'Error fetching devices $e',
//       };
//     }
//   }

//   Future<Map<String, dynamic>> fetchSearchDevices(String name) async {
//     // Reference to the device's data
//     try {
//       final ref = _database.ref('devices');
//       final DataSnapshot dataSnapshot = await ref.get();

//       List<DeviceProfile> devices = [];

//       for (final child in dataSnapshot.children) {
//         final device = child.key.toString();
//         final other = child.child('other').value as String;
//         final useData = child.child('use').value as String;
//         final state = child.child('assigned').value as int;
//         final deadline = child.child('deadline').value as String;
//         if (device.toLowerCase().contains(name)) {
//           devices.add(DeviceProfile(
//               code: device.toString(),
//               detail: other.toString(),
//               state: state,
//               use: useData.toString(),
//               deadline: deadline.toString()));
//         }
//       }

//       return {
//         'success': true,
//         'data': devices,
//       };
//     } catch (e) {
//       return {
//         'success': false,
//         'data': 'Error fetching devices $e',
//       };
//     }
//   }

//   Future<Map<String, dynamic>> addDevice(String code, String other) async {
//     final DatabaseReference ref = _database.ref('devices').child(code);
//     try {
//       // Check if the ref already exists
//       final DataSnapshot snapshot = await ref.get();

//       if (snapshot.exists) {
//         // If the device already exists, return an error
//         return {'success': false, 'message': 'Device already exists.'};
//       } else {
//         // If the device does not exist, add the data
//         await ref.set({
//           'other': other,
//           'assigned': 0,
//           'is_done': false,
//           'deadline': "",
//         });
//         return {'success': true, 'message': 'Device added successfully.'};
//       }
//     } catch (e) {
//       // Handle any errors during the operation
//       return {'success': false, 'message': 'An error occurred: $e'};
//     }
//   }

//   Future<Map<String, dynamic>> transferDeviceData(String code) async {
//     final DatabaseReference ref =
//         _database.ref('devices').child(code).child('data');
//     try {
//       // Check if the ref already exists
//       final DataSnapshot snapshot = await ref.get();

//       if (snapshot.exists) {
//         // If the device already exists, return an error
//         return {
//           'success': true,
//           'data': snapshot.value as Map<dynamic, dynamic>
//         };
//       } else {
//         // If the device does not exist, add the data
//         return {
//           'success': false,
//           'message': 'Device data are not retrieved successfully.'
//         };
//       }
//     } catch (e) {
//       // Handle any errors during the operation
//       return {'success': false, 'message': 'An error occurred: $e'};
//     }
//   }

//   Future<Map<String, dynamic>> deleteDeviceData(String code) async {
//     final DatabaseReference ref =
//         _database.ref('devices').child(code).child('data');
//     try {
//       // Check if the ref already exists
//       await ref.remove();
//       await _database
//           .ref('devices')
//           .child(code)
//           .update({'assigned': 0, 'use': ""});
//       return {'success': true, 'data': 'Data removed from the device.'};
//     } catch (e) {
//       // Handle any errors during the operation
//       return {'success': false, 'message': 'An error occurred: $e'};
//     }
//   }

//   Future<Map<String, dynamic>> connectDeviceData(
//       String code, String other) async {
//     try {
//       // Check if the ref already exists
//       await _database.ref('devices').child(code).update({
//         'assigned': 1,
//         'use': other,
//         'deadline': (DateTime.now().add(Duration(hours: period))).toString()
//       });
//       return {'success': true, 'data': 'Device is connected successfully'};
//     } catch (e) {
//       // Handle any errors during the operation
//       return {'success': false, 'message': 'An error occurred: $e'};
//     }
//   }

//   Future<Map<String, dynamic>> connectDevicePending(String code) async {
//     try {
//       // Check if the ref already exists
//       await _database.ref('devices').child(code).update({'assigned': 2});
//       return {'success': true, 'data': 'Device is in pending state'};
//     } catch (e) {
//       // Handle any errors during the operation
//       return {'success': false, 'message': 'An error occurred: $e'};
//     }
//   }

//   Future<Map<String, dynamic>> disconnectDevicePending(String code) async {
//     try {
//       // Check if the ref already exists
//       await _database.ref('devices').child(code).update({'assigned': 0});
//       return {'success': true, 'data': 'Device is in pending state'};
//     } catch (e) {
//       // Handle any errors during the operation
//       return {'success': false, 'message': 'An error occurred: $e'};
//     }
//   }

//   Future<int> fetchDeviceDataAvg(String device) async {
//     final FirebaseDatabase database = FirebaseDatabase.instance;
//     final ref = database.ref('devices').child(device).child('data');

//     try {
//       final snapshot =
//           await ref.get(); // Get a single snapshot instead of listening

//       if (snapshot.exists) {
//         final data = snapshot.value as Map<dynamic, dynamic>?;
//         if (data != null && data.isNotEmpty) {
//           // Extract numerical heart rate values (adjust as needed based on your data structure)
//           List<num> heartRates = data.values
//               .whereType<num>()
//               .toList(); //Assuming values are numbers

//           if (heartRates.isEmpty) {
//             return 0; // Handle case where no numerical values are found.
//           }

//           // Calculate the average
//           double avgHeartRate =
//               heartRates.reduce((a, b) => a + b) / heartRates.length;
//           return avgHeartRate.round(); // Return as a rounded integer
//         } else {
//           return 0; // Handle the case where data is empty
//         }
//       } else {
//         return 0; // Handle the case where the data doesn't exist
//       }
//     } catch (e) {
//       return 0; // Return 0 or handle the error as appropriate
//     }
//   }
// }
