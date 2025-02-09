import 'package:flutter/material.dart';

class ProfileController {
  TextEditingController mobile = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController pic = TextEditingController();
  TextEditingController language = TextEditingController();
  TextEditingController color = TextEditingController();
  TextEditingController name = TextEditingController();

  void clear() {
    pic.clear();
    mobile.clear();
    address.clear();
    language.clear();
    color.clear();
    name.clear();
  }
}
