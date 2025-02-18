import 'package:flutter/material.dart';
import 'package:health_care_web/models/return_model.dart';
import 'package:health_care_web/services/real_db_service.dart';
import 'package:health_care_web/services/util.dart';

class AdminTabs {
  static final String doctorRegistration = "DOCTOR_REGISTRATION";
  static final String deviceAssignment = "DEVICE_ASSIGNMENT";

  Future<void> addNewDevice(String code, String details, String hospitalId,
      BuildContext context) async {
    ReturnModel res =
        await RealDbService().addDevice(code, details, hospitalId);
    showMessages(res.state, res.message, context);
  }
}
