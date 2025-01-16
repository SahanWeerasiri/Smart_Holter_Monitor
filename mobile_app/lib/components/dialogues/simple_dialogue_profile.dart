import 'package:flutter/material.dart';
import 'package:health_care/constants/consts.dart';
import '../../components/buttons/custom_button_1/custom_button.dart';

class ProfileDialogue extends StatelessWidget {
  final String text;
  final String email;
  final String phone;
  final String address;
  final IconData icon;
  final Color basicColor;
  final Color backgroundColor;
  final Color fontColor;
  final Color subTextFontColor;
  final Color btnBackColor;
  final Color btnTextColor;
  final VoidCallback? onPressed;
  final String btnText;
  const ProfileDialogue(
      {super.key,
      required this.text,
      required this.email,
      required this.phone,
      required this.address,
      required this.basicColor,
      required this.fontColor,
      required this.subTextFontColor,
      this.backgroundColor = Colors.white,
      this.icon = Icons.error,
      this.onPressed,
      this.btnText = "Next",
      this.btnBackColor = Colors.blue,
      this.btnTextColor = Colors.white});
  final primaryColor = const Color(0xff4338CA);
  final accentColor = const Color(0xffffffff);

  @override
  Widget build(BuildContext context) {
    AppSizes().initSizes(context);
    return Dialog(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        width: AppSizes().getBlockSizeHorizontal(80),
        height: AppSizes().getBlockSizeVertical(30),
        decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(15.0),
            boxShadow: [
              BoxShadow(
                  offset: const Offset(12, 26),
                  blurRadius: 50,
                  spreadRadius: 0,
                  color: basicColor.withOpacity(.1)),
            ]),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: fontColor,
            ),
            Text(text,
                style: TextStyle(
                    color: fontColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(
              height: 3.5,
            ),
            Padding(
                padding: EdgeInsets.only(
                  left: AppSizes().getBlockSizeHorizontal(5),
                  right: AppSizes().getBlockSizeHorizontal(5),
                  top: AppSizes().getBlockSizeHorizontal(0),
                  bottom: AppSizes().getBlockSizeHorizontal(1),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  spacing: AppSizes().getBlockSizeHorizontal(2),
                  children: [
                    Text("Email",
                        style: TextStyle(
                          color: subTextFontColor,
                          fontSize: 15,
                        )),
                    Text(email,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: subTextFontColor,
                          fontSize: 15,
                        )),
                  ],
                )),
            Padding(
                padding: EdgeInsets.only(
                  left: AppSizes().getBlockSizeHorizontal(5),
                  right: AppSizes().getBlockSizeHorizontal(5),
                  top: AppSizes().getBlockSizeHorizontal(0),
                  bottom: AppSizes().getBlockSizeHorizontal(1),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  spacing: AppSizes().getBlockSizeHorizontal(2),
                  children: [
                    Text("Mobile",
                        style: TextStyle(
                          color: subTextFontColor,
                          fontSize: 15,
                        )),
                    Text(phone,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: subTextFontColor,
                          fontSize: 15,
                        )),
                  ],
                )),
            Padding(
                padding: EdgeInsets.only(
                  left: AppSizes().getBlockSizeHorizontal(5),
                  right: AppSizes().getBlockSizeHorizontal(5),
                  top: AppSizes().getBlockSizeHorizontal(0),
                  bottom: AppSizes().getBlockSizeHorizontal(1),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  spacing: AppSizes().getBlockSizeHorizontal(2),
                  children: [
                    Text("Address",
                        style: TextStyle(
                          color: subTextFontColor,
                          fontSize: 15,
                        )),
                    Text(address,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: subTextFontColor,
                          fontSize: 15,
                        )),
                  ],
                )),
            const SizedBox(
              height: 15,
            ),
            CustomButton(
              label: btnText,
              onPressed: onPressed ?? () {},
              backgroundColor: btnBackColor,
              textColor: btnTextColor,
            )
          ],
        ),
      ),
    );
  }
}
