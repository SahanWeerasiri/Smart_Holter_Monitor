import 'package:health_care/components/list/design1/list1.dart';
import 'package:health_care/components/list/design1/list_item_data.dart';
import 'package:health_care/constants/consts.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

class Summary extends StatefulWidget {
  const Summary({super.key});

  @override
  State<Summary> createState() => _SummaryState();
}

class _SummaryState extends State<Summary> {
  @override
  Widget build(BuildContext context) {
    AppSizes().initSizes(context);
    return Padding(
      padding: EdgeInsets.all(AppSizes().getBlockSizeHorizontal(8)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                color: StyleSheet().currentHeartBox,
              ),
              width: AppSizes().getBlockSizeHorizontal(90),
              height: AppSizes().getBlockSizeVertical(20),
              child: Padding(
                padding: EdgeInsets.all(AppSizes().getBlockSizeHorizontal(5)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          "Heart Rate",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: AppSizes().getBlockSizeHorizontal(5),
                          ),
                        ),
                        Text(
                          "120",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: AppSizes().getBlockSizeHorizontal(17),
                          ),
                        ),
                        Text(
                          "bpm",
                          style: TextStyle(
                            fontSize: AppSizes().getBlockSizeHorizontal(4),
                          ),
                        )
                      ],
                    ),
                    Image.asset('assetes/icons/logo.png')
                  ],
                ),
              )),
          SizedBox(
            height: AppSizes().getBlockSizeVertical(2),
          ),
          Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                      width: AppSizes().getBlockSizeHorizontal(40),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        color: StyleSheet().avgHeartBox,
                      ),
                      height: AppSizes().getBlockSizeVertical(20),
                      child: Padding(
                        padding: EdgeInsets.all(
                            AppSizes().getBlockSizeHorizontal(5)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Avg Heart Rate",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: AppSizes().getBlockSizeHorizontal(5),
                              ),
                            ),
                            Text(
                              "125",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: AppSizes().getBlockSizeHorizontal(17),
                              ),
                            ),
                            Text(
                              "bpm",
                              style: TextStyle(
                                fontSize: AppSizes().getBlockSizeHorizontal(4),
                              ),
                            )
                          ],
                        ),
                      )),
                  Container(
                      width: AppSizes().getBlockSizeHorizontal(40),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        color: StyleSheet().stateHeartBox,
                      ),
                      height: AppSizes().getBlockSizeVertical(20),
                      child: Padding(
                        padding: EdgeInsets.all(
                            AppSizes().getBlockSizeHorizontal(5)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Status",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: AppSizes().getBlockSizeHorizontal(5),
                              ),
                            ),
                            Text(
                              "Good",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: AppSizes().getBlockSizeHorizontal(10),
                              ),
                            ),
                          ],
                        ),
                      ))
                ],
              )),
          SizedBox(
            height: AppSizes().getBlockSizeVertical(3),
          ),
          Container(
            padding:
                EdgeInsets.only(left: AppSizes().getBlockSizeHorizontal(3)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "Assigned Doctor",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                )
              ],
            ),
          ),
          Expanded(
              child: List1(
                  color: StyleSheet().uiBackground,
                  data: List.of([
                    ListItem1Data(
                        title: "Dr.ABCD",
                        icon: IconlyLight.heart,
                        onPressed: () {}),
                  ])))
        ],
      ),
    );
  }
}
