import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:health_care/components/buttons/custom_text_button/custom_text_button.dart';
import 'package:health_care/components/list/design1/list_item1.dart';
import 'package:health_care/constants/consts.dart';
import 'package:health_care/controllers/textController.dart';
import 'package:health_care/pages/app/services/firestore_db_service.dart';
import 'package:iconly/iconly.dart';

class Profile extends StatefulWidget {
  final User? user;

  const Profile({super.key, required this.user});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String name = "Name";
  String email = "Email";
  late final CredentialController credentialController = CredentialController();
  bool _isLoading = true; // Loading state

  @override
  void initState() {
    super.initState();
    fetchProfileData();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> fetchProfileData() async {
    Map<String, dynamic> res =
        await FirestoreDbService().fetchAccount(widget.user!.uid);
    if (res['success']) {
      setState(() {
        name = res['data']['name'];
        email = res['data']['email'];
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
        backgroundColor: Colors.white,
        color: CustomColors().blue,
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
            CircleAvatar(
              radius: 60,
              backgroundColor: StyleSheet().btnBackground,
              child: const Icon(
                Icons.person,
                size: 60,
                color: Colors.white,
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
                    name,
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
                    email,
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
                    "Mobile",
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
                    "Address",
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
                    "Birthday",
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
                    "Language",
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
                    "Device",
                    style: TextStyle(
                      fontSize: AppSizes().getBlockSizeHorizontal(5),
                      color: StyleSheet().profiletext,
                    ),
                  ),
                )),
            CustomTextButton(
              label: "Edit Profile",
              onPressed: () {},
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
                onPressed: () {}),
            ListItem1(
                title: "Amma", icon: IconlyLight.profile, onPressed: () {})
          ],
        ),
      ),
    );
  }
}
