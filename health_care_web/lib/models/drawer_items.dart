import 'package:flutter/material.dart';

class DrawerItems {
  final int index;
  final String title;
  final IconData icon;
  final Function() onTap;
  DrawerItems(
      {required this.index,
      required this.title,
      required this.icon,
      required this.onTap});
}
