import 'package:flutter/material.dart';
import 'package:health_care_web/models/app_sizes.dart';

class CustomTopAppBar3 extends StatelessWidget implements PreferredSizeWidget {
  @override
  final Size preferredSize;
  final String title;
  final Color backgroundColor;
  final Color titleColor;
  final VoidCallback? backOnPressed;
  final List<IconButton> actions;
  final TextAlign titleAlignment;
  final Widget? leadingIcon;
  const CustomTopAppBar3(
      {super.key,
      this.leadingIcon,
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
      automaticallyImplyLeading: false,
      leading: SizedBox(
          width: AppSizes().getBlockSizeHorizontal(10), child: leadingIcon),
      title: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
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
      actions: actions,
    );
  }
}
