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
        final assignedSnapshot = await ref.child('assigned').once();

        final deviceProfileModel = DeviceProfileModel(
          code: device,
          detail: otherSnapshot.snapshot.value?.toString() ?? "",
          use: useSnapshot.snapshot.value?.toString() ?? "",
          state: assignedSnapshot.snapshot.value as int? ??
              DeviceProfileModel
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

  Future<DeviceReportModel?> fetchDeviceOneReport(String uid) async {
    try {
      final ref = _database.ref('devices').child(uid);
      final snapshot = await ref.get();
      if (snapshot.exists) {
        return DeviceReportModel(
            code: snapshot.key.toString(),
            detail: snapshot.child('other').value?.toString() ?? "",
            deadline: snapshot.child('deadline').value?.toString() ?? "",
            avgValue: (await fetchDeviceDataAvg(uid)).toString());
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<DeviceReportModel?> fetchDeviceOneViewReport(String uid) async {
    try {
      final ref = _database.ref('devices').child(uid);
      final snapshot = await ref.get();
      if (snapshot.exists) {
        return DeviceReportModel(
            code: snapshot.key.toString(),
            detail: snapshot.child('other').value?.toString() ?? "",
            deadline: snapshot.child('deadline').value?.toString() ?? "",
            avgValue: "");
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<DeviceProfileModel?> fetchDeviceOne(String uid) async {
    try {
      final ref = _database.ref('devices').child(uid);
      final snapshot = await ref.get();
      if (snapshot.exists) {
        ReturnModel res = await fetchDeviceData(uid);
        String latestValue = "0";
        if (res.state) {
          latestValue = res.deviceProfileModel!.latestValue;
        }
        return DeviceProfileModel(
            code: snapshot.key.toString(),
            detail: snapshot.child('other').value?.toString() ?? "",
            use: snapshot.child('use').value?.toString() ?? "",
            state: snapshot.child('assigned').value as int? ??
                DeviceProfileModel.notAssigned,
            latestValue: latestValue,
            deadline: snapshot.child('deadline').value?.toString() ?? "",
            data: snapshot.child('data').value as Map<String, String>,
            avgValue: (await fetchDeviceDataAvg(uid)).toString());
      } else {
        return null;
      }
    } catch (e) {
      return null;
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

  Future<ReturnModel> addDevice(
      String code, String other, String hospitalId) async {
    final ref = _database.ref('devices').child(code);
    try {
      final snapshot = await ref.get();
      if (snapshot.exists) {
        return ReturnModel(state: false, message: 'Device already exists.');
      } else {
        await ref.set({
          'other': other,
          'hospitalId': hospitalId,
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
    final ref = _database.ref('devices').child(code);
    try {
      final snapshot = await ref.get();
      if (snapshot.exists) {
        final dataFromSnapshot = (snapshot.value as Map)['data'];

        // Convert the LinkedMap to a Map<String, String>
        Map<String, String> data = {};
        if (dataFromSnapshot != null) {
          // Handle the case where 'data' might be null
          (dataFromSnapshot as Map).forEach((key, value) {
            data[key.toString()] = value.toString();
          });
        }

        return ReturnModel(
          state: true,
          message: 'Data retrieved successfully',
          deviceProfileModel: DeviceProfileModel(
            code: code, // Explicitly cast
            detail: (snapshot.value as Map)['other'] as String,
            use: (snapshot.value as Map)['use'] as String,
            state: (snapshot.value as Map)['assigned'] as int,
            deadline: (snapshot.value as Map)['deadline'] as String,
            latestValue: "",
            avgValue: (await fetchDeviceDataAvg(code)).toString(),
            data: data, // Assuming you have these fields in the data
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
          .update({'assigned': 0, 'use': "", 'deadline': ''});
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
        'deadline': (DateTime.now().add(Duration(hours: period))).toString(),
        'data': {
          '2025-02-11 19:58:00': 3092,
          '2025-02-11 19:58:01': 1874,
          '2025-02-11 19:58:02': 395,
          '2025-02-11 19:58:03': 2781,
          '2025-02-11 19:58:04': 1420,
          '2025-02-11 19:58:05': 3689,
          '2025-02-11 19:58:06': 2034,
          '2025-02-11 19:58:07': 412,
          '2025-02-11 19:58:08': 3748,
          '2025-02-11 19:58:09': 2560,
          '2025-02-11 19:58:10': 981,
          '2025-02-11 19:58:11': 3175,
          '2025-02-11 19:58:12': 145,
          '2025-02-11 19:58:13': 2934,
          '2025-02-11 19:58:14': 2217
        }
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
