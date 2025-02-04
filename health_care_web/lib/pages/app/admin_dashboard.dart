import 'package:flutter/material.dart';
import 'package:health_care_web/components/buttons/custom_button_1/custom_button.dart';
import 'package:health_care_web/constants/consts.dart';
import "package:health_care_web/pages/app/additional/admin/doctor_signup_section.dart";
import 'package:health_care_web/pages/app/additional/admin/device_assignment_section.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  String selectedTab = AdminTabs().doctorRegistration;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                spacing: 8,
                children: [
                  CustomButton(
                    label: "Doctor Registration",
                    onPressed: () {
                      setState(() {
                        selectedTab = AdminTabs().doctorRegistration;
                      });
                    },
                    backgroundColor: StyleSheet().btnBackground,
                    textColor: StyleSheet().btnText,
                    icon: Icons.create,
                  ),
                  CustomButton(
                    label: "Device Assignment",
                    onPressed: () {
                      setState(() {
                        selectedTab = AdminTabs().deviceAssignment;
                      });
                    },
                    backgroundColor: StyleSheet().btnBackground,
                    textColor: StyleSheet().btnText,
                    icon: Icons.devices,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              (selectedTab == AdminTabs().doctorRegistration)
                  ? const DoctorSignupSection()
                  : const DeviceAssignmentSection(),
            ],
          ),
        ),
      ),
    );
  }
}
