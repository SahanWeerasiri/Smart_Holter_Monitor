import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:health_care_web/components/buttons/custom_text_button/custom_text_button.dart';
import 'package:health_care_web/constants/consts.dart';
import 'package:health_care_web/controllers/profileController.dart';
import 'package:health_care_web/pages/additional/popups/edit_profile_popup.dart';
import 'package:health_care_web/pages/services/firestore_db_service.dart';
import 'package:iconly/iconly.dart';

class Profile extends StatefulWidget {
  final User? user;

  const Profile({super.key, required this.user});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final UserProfile _userProfile =
      UserProfile(id: "", name: "Name", email: "Email");
  late final ProfileController profileController = ProfileController();
  bool _isLoading = false; // Loading state

  @override
  void initState() {
    super.initState();
    fetchProfileData();
  }

  Future<void> fetchProfileData() async {
    setState(() {
      _isLoading = true;
    });
    Map<String, dynamic> res = await FirestoreDbService()
        .fetchAccount(FirebaseAuth.instance.currentUser!.uid);
    if (res['success']) {
      setState(() {
        _userProfile.name = res['data']['name'];
        _userProfile.email = res['data']['email'];
        _userProfile.address = res['data']['address'];
        _userProfile.color = res['data']['color'];
        _userProfile.language = res['data']['language'];
        _userProfile.mobile = res['data']['mobile'];
        _userProfile.pic = res['data']['pic'];
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['error']),
            backgroundColor: Colors.red,
          ),
        );
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> onSubmit() async {
    Map<String, dynamic> res = await FirestoreDbService().updateProfile(
        FirebaseAuth.instance.currentUser!.uid,
        profileController.mobile.text,
        profileController.language.text,
        profileController.address.text,
        profileController.pic.text);
    if (res['success']) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['message']),
            backgroundColor: Colors.green,
          ),
        );
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['error']),
            backgroundColor: Colors.red,
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    AppSizes().initSizes(context);
    if (_isLoading) {
      return Center(
          child: CircularProgressIndicator(
        backgroundColor: StyleSheet().uiBackground,
        color: StyleSheet().btnBackground,
      ));
    }
    return SingleChildScrollView(
      child: Container(
        color: StyleSheet().uiBackground,
        width: double.infinity,
        padding: EdgeInsets.all(AppSizes().getBlockSizeHorizontal(5)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Picture Section
            Container(
              clipBehavior: Clip.hardEdge,
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: StyleSheet().btnBackground,
                borderRadius: BorderRadius.circular(60),
              ),
              child: _userProfile.pic.isNotEmpty
                  ? Image.memory(
                      base64Decode(_userProfile.pic),
                      fit: BoxFit.cover, // Ensures the image fills the circle
                    )
                  : const Icon(
                      Icons.person,
                      size: 40, // Optional: Adjust size as needed
                      color: Colors.white, // Optional: Adjust icon color
                    ),
            ),
            const SizedBox(height: 20),

            // Edit Profile Button
            CustomTextButton(
              label: "Edit Profile",
              onPressed: () {
                profileController.mobile.text = _userProfile.mobile;
                profileController.address.text = _userProfile.address;
                profileController.language.text = _userProfile.language;
                profileController.pic.text = _userProfile.pic;
                showDialog(
                  context: context,
                  builder: (context) => EditProfilePopup(
                    mobileController: profileController.mobile,
                    addressController: profileController.address,
                    languageController: profileController.language,
                    picController: profileController.pic,
                    onSubmit: () {
                      onSubmit();
                      profileController.clear();
                      Navigator.pop(context);
                      fetchProfileData();
                    },
                  ),
                );
              },
              icon: IconlyLight.edit,
              backgroundColor: StyleSheet().btnBackground,
              textColor: StyleSheet().btnText,
            ),
            const SizedBox(height: 20),

            // Profile Details Section
            _buildProfileDetail(_userProfile.name),
            _buildProfileDetail(_userProfile.email),
            _buildProfileDetail(_userProfile.mobile),
            _buildProfileDetail(_userProfile.address),
            _buildProfileDetail(_userProfile.language),
          ],
        ),
      ),
    );
  }

  // Helper widget for profile details
  Widget _buildProfileDetail(String text) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        color: StyleSheet().profileBase,
      ),
      width: double.infinity,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            color: StyleSheet().profiletext,
          ),
        ),
      ),
    );
  }
}
