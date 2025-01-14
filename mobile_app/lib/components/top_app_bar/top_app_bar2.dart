import 'package:flutter/material.dart';
import 'package:health_care/constants/consts.dart';

class CustomTopAppBar2 extends StatelessWidget implements PreferredSizeWidget {
  @override
  final Size preferredSize;
  final bool backButton;
  final String title;
  final Color backgroundColor;
  final Color titleColor;
  final VoidCallback? backOnPressed;
  final List<IconButton> actions;
  final TextAlign titleAlignment;
  final bool automaticLeading;
  const CustomTopAppBar2(
      {super.key,
      this.automaticLeading = false,
      this.backButton = false,
      required this.title,
      this.backOnPressed,
      this.titleAlignment = TextAlign.center,
      this.titleColor = Colors.white,
      this.backgroundColor = Colors.orange,
      this.actions = const []})
      : preferredSize = const Size.fromHeight(56.0);
  @override
  Widget build(BuildContext context) {
    return AppBar(
        backgroundColor: backgroundColor,
        foregroundColor: backgroundColor,
        surfaceTintColor: backgroundColor,
        elevation: 1,
        automaticallyImplyLeading: automaticLeading,
        leading: null,
        title: backButton
            ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                SizedBox(
                    width: AppSizes().getBlockSizeHorizontal(10),
                    child: IconButton(
                      icon: Icon(Icons.keyboard_arrow_left, color: titleColor),
                      onPressed: backOnPressed ?? () {},
                    )),
                Text(
                  title,
                  style: TextStyle(
                      backgroundColor: backgroundColor,
                      color: titleColor,
                      fontWeight: FontWeight.w900,
                      fontSize: 25),
                ),
                SizedBox(
                  width: AppSizes().getBlockSizeHorizontal(10),
                )
              ])
            : Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                SizedBox(
                    width: AppSizes().getBlockSizeHorizontal(5), child: null),
                Text(
                  title,
                  style: TextStyle(
                      backgroundColor: backgroundColor,
                      color: titleColor,
                      fontWeight: FontWeight.w900,
                      fontSize: 25),
                ),
                SizedBox(
                  width: AppSizes().getBlockSizeHorizontal(10),
                )
              ]),
        actions: actions);
  }
}
