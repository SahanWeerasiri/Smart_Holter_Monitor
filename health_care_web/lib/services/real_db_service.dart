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
              DeviceProfileModel.notAssigned, // Needs better state handling - consider using enum
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
            data: snapshot.child('data').value as Map<String, String>,
            avgValue: fetchDeviceDataAvg(uid).toString()
          );
        
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
          if(res.state){
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
            avgValue: fetchDeviceDataAvg(uid).toString()
          );
        
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