import 'package:health_care/components/list/design1/list1.dart';
import 'package:health_care/components/list/design1/list_item_data.dart';
import 'package:health_care/constants/consts.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

class ReportList extends StatefulWidget {
  const ReportList({super.key});

  @override
  State<ReportList> createState() => _ReportListState();
}

class _ReportListState extends State<ReportList> {
  @override
  Widget build(BuildContext context) {
    AppSizes().initSizes(context);
    return Center(
        child: Container(
            color: StyleSheet().uiBackground,
            padding: EdgeInsets.all(AppSizes().getBlockSizeHorizontal(5)),
            child: Expanded(
                child: List1(
                    color: StyleSheet().uiBackground,
                    data: List.of([
                      ListItem1Data(
                          title: "Generatl Report 01",
                          icon: IconlyLight.document,
                          onPressed: () {}),
                      ListItem1Data(
                          title: "Generatl Report 02",
                          icon: IconlyLight.document,
                          onPressed: () {}),
                      ListItem1Data(
                          title: "Generatl Report 03",
                          icon: IconlyLight.document,
                          onPressed: () {})
                    ])))));
  }
}
