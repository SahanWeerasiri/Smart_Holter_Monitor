import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:health_care_web/components/buttons/custom_text_button/custom_text_button.dart';
import 'package:health_care_web/components/list/design1/list_item1.dart';
import 'package:health_care_web/constants/consts.dart';
import 'package:health_care_web/controllers/profileController.dart';
import 'package:health_care_web/controllers/textController.dart';
import 'package:health_care_web/pages/app/additional/add_contact_popup.dart';
import 'package:health_care_web/pages/app/additional/edit_profile_popup.dart';
import 'package:health_care_web/pages/app/additional/show_contact_popup.dart';
import 'package:health_care_web/pages/app/services/firestore_db_service.dart';
import 'package:iconly/iconly.dart';

class Profile extends StatefulWidget {
  final User? user;

  const Profile({super.key, required this.user});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final UserProfile _userProfile = UserProfile(name: "Name", email: "Email");
  final List<ContactProfile> _people = [];
  late final CredentialController credentialController = CredentialController();
  late final ProfileController profileController = ProfileController();
  bool _isLoading = true; // Loading state

  @override
  void initState() {
    super.initState();
    fetchProfileData();
    fetchEmergency();
  }

  Future<void> fetchProfileData() async {
    setState(() {
      _isLoading = true;
    });
    Map<String, dynamic> res =
        await FirestoreDbService().fetchAccount(widget.user!.uid);
    if (res['success']) {
      setState(() {
        _userProfile.name = res['data']['name'];
        _userProfile.email = res['data']['email'];
        _userProfile.address = res['data']['address'];
        _userProfile.color = res['data']['color'];
        _userProfile.device = res['data']['device'];
        _userProfile.isDone = res['data']['is_done'];
        _userProfile.language = res['data']['language'];
        _userProfile.mobile = res['data']['mobile'];
        _userProfile.pic = res['data']['pic'];
        _userProfile.doctorId = res['data']['doctor_id'];
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
        widget.user!.uid,
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

  Future<void> onSubmitContact() async {
    Map<String, dynamic> res = await FirestoreDbService().addContact(
        widget.user!.uid,
        profileController.name.text,
        profileController.mobile.text);
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

  Future<void> fetchEmergency() async {
    setState(() {
      _isLoading = true;
    });
    Map<String, dynamic> res =
        await FirestoreDbService().fetchEmergency(widget.user!.uid);
    if (res['success']) {
      setState(() {
        final people = res['data'] as List<Map<String, dynamic>>;
        for (var person in people) {
          _people.add(
              ContactProfile(name: person['name'], mobile: person['mobile']));
        }
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
          spacing: AppSizes().getBlockSizeVertical(1),
          children: [
            Container(
              clipBehavior: Clip.hardEdge,
              width: AppSizes().getBlockSizeHorizontal(50),
              height: AppSizes().getBlockSizeHorizontal(50),
              decoration: BoxDecoration(
                  color: StyleSheet().btnBackground,
                  borderRadius: BorderRadius.circular(60)),
              child: _userProfile.pic.isNotEmpty
                  ? Image.memory(
                      base64Decode(_userProfile.pic),
                      fit: BoxFit
                          .cover, // Ensures the image fills the CircleAvatar nicely
                    )
                  : const Icon(
                      Icons.person,
                      size: 40, // Optional: Adjust size as needed
                      color: Colors.white, // Optional: Adjust icon color
                    ),
            ),
            Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color: StyleSheet().profileBase,
                ),
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.all(AppSizes().getBlockSizeHorizontal(5)),
                  child: Text(
                    _userProfile.name,
                    style: TextStyle(
                      fontSize: AppSizes().getBlockSizeHorizontal(5),
                      color: StyleSheet().profiletext,
                    ),
                  ),
                )),
            Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color: StyleSheet().profileBase,
                ),
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.all(AppSizes().getBlockSizeHorizontal(5)),
                  child: Text(
                    _userProfile.email,
                    style: TextStyle(
                      fontSize: AppSizes().getBlockSizeHorizontal(5),
                      color: StyleSheet().profiletext,
                    ),
                  ),
                )),
            Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color: StyleSheet().profileBase,
                ),
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.all(AppSizes().getBlockSizeHorizontal(5)),
                  child: Text(
                    _userProfile.mobile,
                    style: TextStyle(
                      fontSize: AppSizes().getBlockSizeHorizontal(5),
                      color: StyleSheet().profiletext,
                    ),
                  ),
                )),
            Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color: StyleSheet().profileBase,
                ),
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.all(AppSizes().getBlockSizeHorizontal(5)),
                  child: Text(
                    _userProfile.address,
                    style: TextStyle(
                      fontSize: AppSizes().getBlockSizeHorizontal(5),
                      color: StyleSheet().profiletext,
                    ),
                  ),
                )),
            Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color: StyleSheet().profileBase,
                ),
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.all(AppSizes().getBlockSizeHorizontal(5)),
                  child: Text(
                    _userProfile.language,
                    style: TextStyle(
                      fontSize: AppSizes().getBlockSizeHorizontal(5),
                      color: StyleSheet().profiletext,
                    ),
                  ),
                )),
            Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color: StyleSheet().profileBase,
                ),
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.all(AppSizes().getBlockSizeHorizontal(5)),
                  child: Text(
                    _userProfile.device,
                    style: TextStyle(
                      fontSize: AppSizes().getBlockSizeHorizontal(5),
                      color: StyleSheet().profiletext,
                    ),
                  ),
                )),
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
                        }));
              },
              icon: IconlyLight.edit,
              backgroundColor: StyleSheet().btnBackground,
              textColor: StyleSheet().btnText,
            ),
            Container(
                width: double.infinity,
                color: StyleSheet().uiBackground,
                child: Padding(
                  padding: EdgeInsets.all(AppSizes().getBlockSizeHorizontal(5)),
                  child: Text(
                    "Emergency Contacts",
                    style: TextStyle(
                        fontSize: AppSizes().getBlockSizeHorizontal(4),
                        color: StyleSheet().profiletext,
                        fontWeight: FontWeight.bold),
                  ),
                )),
            CustomTextButton(
                label: "Add",
                icon: IconlyLight.add_user,
                backgroundColor: StyleSheet().btnBackground,
                textColor: StyleSheet().btnText,
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) => AddContactPopup(
                          mobileController: profileController.mobile,
                          nameController: profileController.name,
                          onSubmit: () {
                            onSubmitContact();
                            profileController.clear();
                            Navigator.pop(context);
                            fetchEmergency();
                          }));
                }),
            Column(
                children: _people.map((person) {
              return ListItem1(
                  title: person.name,
                  icon: IconlyLight.profile,
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) =>
                            ShowContactPopup(profile: person));
                  });
            }).toList())
          ],
        ),
      ),
    );
  }
}
