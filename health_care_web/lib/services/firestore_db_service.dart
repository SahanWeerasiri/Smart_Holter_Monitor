import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:health_care_web/models/contact_profile_model.dart';
import 'package:health_care_web/models/device_profile_model.dart';
import 'package:health_care_web/models/doctor_profile_model.dart';
import 'package:health_care_web/models/patient_profile_model.dart';
import 'package:health_care_web/models/report_model.dart';
import 'package:health_care_web/models/return_model.dart';
import 'package:health_care_web/services/real_db_service.dart';

class FirestoreDbService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<ReturnModel> createAccount(String name, String email) async {
    try {
      final uid = _auth.currentUser?.uid ?? ''; // Get current user ID
      if (uid.isEmpty) {
        return ReturnModel(state: false, message: "User not authenticated");
      }
      final accountData = {
        'createdAt': DateTime.now(),
        'email': email,
        'name': name,
        'address': '',
        'mobile': '',
        'language': '',
        'color': '',
        'pic': '',
      };
      await _firestore.collection('doctor_accounts').doc(uid).set(accountData);
      return ReturnModel(state: true, message: 'Account created successfully');
    } catch (e) {
      return ReturnModel(state: false, message: 'Error creating account: $e');
    }
  }

  Future<ReturnModel> fetchAccount() async {
    try {
      final doc = await _firestore
          .collection('doctor_accounts')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();
      if (doc.exists) {
        final data = doc.data()!;
        final doctor = DoctorProfileModel.fromMap(
            data, FirebaseAuth.instance.currentUser!.uid);
        return ReturnModel(
            state: true,
            message: 'Account fetched successfully',
            doctorProfileModel: doctor);
      } else {
        return ReturnModel(state: false, message: 'Account not found');
      }
    } catch (e) {
      return ReturnModel(state: false, message: 'Error fetching account: $e');
    }
  }

  Future<ReturnModel> fetchPatients() async {
    try {
      final snapshot = await _firestore.collection('user_accounts').get();
      final List<PatientProfileModel> patients = [];
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final patient =
            PatientProfileModel.fromMap(data, doc.id); //Use fromMap constructor
        patients.add(patient);
      }
      return ReturnModel(
          state: true,
          message: 'Patients fetched successfully',
          patients: patients);
    } catch (e) {
      return ReturnModel(state: false, message: 'Error fetching patients: $e');
    }
  }

  Future<ReturnModel> fetchContacts(String uid) async {
    try {
      final snapshot = await _firestore
          .collection('user_accounts')
          .doc(uid)
          .collection('emergency')
          .get();
      final List<ContactProfileModel> contacts = [];
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final ContactProfileModel contact = ContactProfileModel(
            name: data['name'].toString(), mobile: data['mobile'].toString());
        contacts.add(contact);
      }
      return ReturnModel(
          state: true,
          message: 'Patients fetched successfully',
          contacts: contacts);
    } catch (e) {
      return ReturnModel(state: false, message: 'Error fetching patients: $e');
    }
  }

  Future<PatientProfileModel?> fetchPatientOne(String uid) async {
    try {
      final doc = await _firestore.collection('user_accounts').doc(uid).get();

      final data = doc.data();
      final patient =
          PatientProfileModel.fromMap(data!, doc.id); //Use fromMap constructor

      return patient;
    } catch (e) {
      return null;
    }
  }

  Future<DoctorProfileModel?> fetchDoctorOne(String uid) async {
    try {
      final doc = await _firestore.collection('doctor_accounts').doc(uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        final doctor = DoctorProfileModel.fromMap(data, uid);
        return doctor;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<ReturnModel> fetchSearchPatients(String name) async {
    try {
      final snapshot = await _firestore.collection('user_accounts').get();
      final List<PatientProfileModel> patients = [];
      for (final doc in snapshot.docs) {
        final data = doc.data();
        if (data['name'].toLowerCase().contains(name.toLowerCase())) {
          final patient = PatientProfileModel.fromMap(
              data, doc.id); //Use fromMap constructor
          patients.add(patient);
        }
      }
      return ReturnModel(
          state: true,
          message: 'Patients fetched successfully',
          patients: patients);
    } catch (e) {
      return ReturnModel(state: false, message: 'Error fetching patients: $e');
    }
  }

  Future<ReturnModel> isDoctor(String email) async {
    try {
      final snapshot = await _firestore
          .collection('doctor_accounts')
          .where('email', isEqualTo: email)
          .get();
      return ReturnModel(
          state: snapshot.docs.isNotEmpty,
          message: snapshot.docs.isNotEmpty ? 'Is a doctor' : 'Not a doctor');
    } catch (e) {
      return ReturnModel(
          state: false, message: 'Error checking doctor status: $e');
    }
  }

  Future<ReturnModel> removePatient(String uid) async {
    try {
      await _firestore
          .collection('user_accounts')
          .doc(uid)
          .update({'docId': ''});
      return ReturnModel(state: true, message: 'Patient removed successfully');
    } catch (e) {
      return ReturnModel(state: false, message: 'Error removing patient: $e');
    }
  }

  Future<ReturnModel> addPatient(String uid, String doctorId) async {
    try {
      await _firestore
          .collection('user_accounts')
          .doc(uid)
          .update({'docId': doctorId});
      return ReturnModel(state: true, message: 'Patient added successfully');
    } catch (e) {
      return ReturnModel(state: false, message: 'Error adding patient: $e');
    }
  }

  Future<ReturnModel> fetchCurrentPatients(String doctorId) async {
    try {
      final snapshot = await _firestore
          .collection('user_accounts')
          .where('docId', isEqualTo: doctorId)
          .get();
      final List<PatientProfileModel> patients = snapshot.docs
          .map((doc) => PatientProfileModel.fromMap(doc.data(), doc.id))
          .toList();
      return ReturnModel(
          state: true,
          message: 'Current patients fetched successfully',
          patients: patients);
    } catch (e) {
      return ReturnModel(
          state: false, message: 'Error fetching current patients: $e');
    }
  }

  Future<ReturnModel> fetchReports(String uid) async {
    try {
      final PatientProfileModel? patientProfileModel =
          await fetchPatientOne(uid);

      if (patientProfileModel == null) {
        return ReturnModel(state: false, message: 'Patient not found');
      }
      final snapshot = await _firestore
          .collection('user_accounts')
          .doc(uid)
          .collection('reports')
          .orderBy('timestamp', descending: true)
          .get();

      final List<ReportModel> reports = [];

      for (DocumentSnapshot doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final reportModel = ReportModel.fromMap(data);
        reportModel.patientProfileModel =
            patientProfileModel.toPatientReportModel();

        final DoctorReportModel? doctorReportModel =
            (await fetchDoctorOne(reportModel.docId))?.toDoctorReportModel();

        if (doctorReportModel == null) {
          return ReturnModel(
              state: false,
              message: "No doctor found for report ${reportModel.docId}");
        }

        reportModel.patientProfileModel!.doctorProfileModel = doctorReportModel;

        final DeviceReportModel? deviceReportModel =
            await RealDbService().fetchDeviceOneReport(reportModel.deviceId);

        if (deviceReportModel == null) {
          return ReturnModel(
              state: false,
              message: "No device found for report ${reportModel.docId}");
        }

        deviceReportModel.avgValue = data['avgHeart'] as String;
        reportModel.patientProfileModel!.device = deviceReportModel;

        reports.add(reportModel);
      }

      return ReturnModel(
          state: true,
          message: 'Reports fetched successfully',
          reports: reports);
    } catch (e) {
      return ReturnModel(state: false, message: 'Error fetching reports: $e');
    }
  }

  Future<ReturnModel> updateProfile(String uid, String mobile, String language,
      String address, String pic) async {
    try {
      await _firestore.collection('doctor_accounts').doc(uid).update({
        'mobile': mobile,
        'address': address,
        'language': language,
        'pic': pic,
      });
      return ReturnModel(state: true, message: 'Profile updated successfully');
    } catch (e) {
      return ReturnModel(state: false, message: 'Error updating profile: $e');
    }
  }

  Future<ReturnModel> addDeviceToPatient(String uid, String device) async {
    try {
      await _firestore
          .collection('user_accounts')
          .doc(uid)
          .update({'deviceId': device});
      return ReturnModel(
          state: true, message: 'Device added to patient successfully');
    } catch (e) {
      return ReturnModel(
          state: false, message: 'Error adding device to patient: $e');
    }
  }

  Future<ReturnModel> removeDeviceFromPatient(String uid, String device) async {
    try {
      // In a real application, you'd likely have a more sophisticated method for handling data transfer and deletion
      // (e.g., using transactions to ensure atomicity)

      // Placeholder - needs to be replaced by actual logic for transferring and removing data
      await _firestore.collection('user_accounts').doc(uid).update({
        'device': '',
        'deviceId': 'Device'
      }); //Removing device ref from the patient
      return ReturnModel(
          state: true, message: 'Device removed from patient successfully');
    } catch (e) {
      return ReturnModel(
          state: false, message: 'Error removing device from patient: $e');
    }
  }

  Future<ReturnModel> getLatestDeviceReadings(String uid) async {
    try {
      final PatientProfileModel? patientProfileModel =
          await fetchPatientOne(uid);

      if (patientProfileModel == null) {
        return ReturnModel(state: false, message: 'Patient not found');
      }

      final PatientReportModel patientReportModel =
          patientProfileModel.toPatientReportModel();

      final snapshot = await _firestore
          .collection('user_accounts')
          .doc(uid)
          .collection('data')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();
      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        final data = doc.data();
        final reportModel = ReportModel.fromMap(data);
        reportModel.patientProfileModel = patientReportModel;
        final DoctorReportModel? doctorReportModel =
            (await fetchDoctorOne(reportModel.docId))?.toDoctorReportModel();

        if (doctorReportModel != null) {
          reportModel.patientProfileModel!.doctorProfileModel =
              doctorReportModel;
        } else {
          return ReturnModel(state: false, message: "No doctor");
        }

        final DeviceReportModel? deviceReportModel =
            (await RealDbService().fetchDeviceOneReport(reportModel.deviceId));

        if (deviceReportModel != null) {
          deviceReportModel.avgValue = data['avgHeart'] as String;
          deviceReportModel.addDataField(data['data']);
          reportModel.patientProfileModel!.device = deviceReportModel;
        } else {
          return ReturnModel(state: false, message: "No device");
        }

        return ReturnModel(
            state: true,
            message: 'Report fetched successfully',
            reportModel: reportModel);
      } else {
        return ReturnModel(state: false, message: "No data found");
      }
    } catch (e) {
      return ReturnModel(
          state: false, message: 'Error fetching latest readings: $e');
    }
  }

  Future<ReturnModel> saveReportData(ReportModel report) async {
    try {
      // Add or update the report data
      await _firestore
          .collection('user_accounts')
          .doc(report.patientProfileModel!.id)
          .collection('data')
          .doc(report.reportId)
          .update(report.toMap()); // Use toMap()
      return ReturnModel(state: true, message: 'Draft saved successfully');
    } catch (e) {
      return ReturnModel(state: false, message: 'Error saving report data: $e');
    }
  }

  Future<ReturnModel> saveReportDataOnce(
      ReportModel report, DeviceReportModel deviceReportModel) async {
    try {
      // Add or update the report data
      final snapshot = await _firestore
          .collection('user_accounts')
          .doc(report.patientProfileModel!.id)
          .collection('data')
          .add(report.toMapWithDocId()); // Use toMap()
      await _firestore
          .collection('user_accounts')
          .doc(report.patientProfileModel!.id)
          .collection('data')
          .doc(snapshot.id)
          .update({
        'data': deviceReportModel.data,
        'reportId': snapshot.id,
        'deviceId': deviceReportModel.code,
        'avgHeart': deviceReportModel.avgValue,
        'timestamp': DateTime.now().toString()
      }); // Use toMap())
      await RealDbService().deleteDeviceData(deviceReportModel.code);
      await removeDeviceFromPatient(
          report.patientProfileModel!.id, deviceReportModel.code);
      return ReturnModel(state: true, message: 'Device Removed Successfully');
    } catch (e) {
      return ReturnModel(state: false, message: 'Error saving report data: $e');
    }
  }

  Future<ReturnModel> saveReport(ReportModel report) async {
    try {
      ReturnModel res = await saveReportData(report);
      if (res.state) {
        DocumentSnapshot doc = await _firestore
            .collection('user_accounts')
            .doc(report.patientProfileModel!.id)
            .collection('data')
            .doc(report.reportId)
            .get();

        if (doc.exists) {
          await _firestore
              .collection('user_accounts')
              .doc(report.patientProfileModel!.id)
              .collection('reports')
              .doc(report.reportId)
              .set({
            'age': doc['age'],
            'aiSuggestions': doc['aiSuggestions'],
            'anomalies': doc['anomalies'],
            'avgHeart': doc['avgHeart'],
            'brief': doc['brief'],
            'description': doc['description'],
            'deviceId': doc['deviceId'],
            'docId': doc['docId'],
            'docSuggestions': doc['docSuggestions'],
            'graph': doc['graph'],
            'isEditing': doc['isEditing'],
            'reportId': doc['reportId'],
            'timestamp': doc['timestamp'],
          });
          await _firestore
              .collection('user_accounts')
              .doc(report.patientProfileModel!.id)
              .update({'isDone': false});
        } else {
          return ReturnModel(state: false, message: 'Report not found');
        }
      } else {
        return res;
      }

      return ReturnModel(state: true, message: 'Report saved successfully');
    } catch (e) {
      return ReturnModel(state: false, message: 'Error saving report: $e');
    }
  }
}
