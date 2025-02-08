import 'package:flutter/material.dart';
import 'package:health_care_web/constants/consts.dart';
import '../../../components/buttons/custom_button_1/custom_button.dart';

class DialogReport extends StatelessWidget {
  final String text;
  final ReportModel reportModel;
  final IconData icon;
  final Color basicColor;
  final Color backgroundColor;
  final Color fontColor;
  final Color subTextFontColor;
  final Color btnBackColor;
  final Color btnTextColor;
  final VoidCallback? onPressed;
  final String btnText;
  const DialogReport({
    super.key,
    required this.text,
    required this.reportModel,
    required this.basicColor,
    required this.fontColor,
    required this.subTextFontColor,
    this.backgroundColor = Colors.white,
    this.icon = Icons.error,
    this.onPressed,
    this.btnText = "Close",
    this.btnBackColor = Colors.blue,
    this.btnTextColor = Colors.white,
  });
  final primaryColor = const Color(0xff4338CA);
  final accentColor = const Color(0xffffffff);

  @override
  Widget build(BuildContext context) {
    AppSizes().initSizes(context);
    return Dialog(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        padding: EdgeInsets.all(AppSizes().getBlockSizeHorizontal(3)),
        width: AppSizes().getBlockSizeHorizontal(60),
        height: AppSizes().getBlockSizeHorizontal(
            80), // Increased height for better visibility
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(15.0),
          boxShadow: [
            BoxShadow(
              offset: const Offset(12, 26),
              blurRadius: 50,
              spreadRadius: 0,
              color: basicColor.withOpacity(.1),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: fontColor,
            ),
            Text(
              text,
              style: TextStyle(
                color: fontColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Summary",
                      style: TextStyle(color: subTextFontColor, fontSize: 15),
                    ),
                    Text(
                      reportModel.brief,
                      style: TextStyle(
                        color: fontColor,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Date Time",
                      style: TextStyle(color: subTextFontColor, fontSize: 15),
                    ),
                    Text(
                      reportModel.timestamp,
                      style: TextStyle(
                        color: fontColor,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Graph",
                      style: TextStyle(color: subTextFontColor, fontSize: 15),
                    ),
                    Text(
                      reportModel.graph,
                      style: TextStyle(
                        color: fontColor,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Average Heart Rate (bpm)",
                      style: TextStyle(color: subTextFontColor, fontSize: 15),
                    ),
                    Text(
                      reportModel.avgHeart,
                      style: TextStyle(
                        color: fontColor,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Description",
                      style: TextStyle(color: subTextFontColor, fontSize: 15),
                    ),
                    Text(
                      reportModel.description,
                      style: TextStyle(
                        color: fontColor,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Suggestions by the doctor",
                      style: TextStyle(color: subTextFontColor, fontSize: 15),
                    ),
                    Text(
                      reportModel.docSuggestions,
                      style: TextStyle(
                        color: fontColor,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Second opinions by the AI",
                      style: TextStyle(color: subTextFontColor, fontSize: 15),
                    ),
                    Text(
                      reportModel.aiSuggestions,
                      style: TextStyle(
                        color: fontColor,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            CustomButton(
              label: btnText,
              onPressed: onPressed ?? () {},
              backgroundColor: btnBackColor,
              textColor: btnTextColor,
            ),
          ],
        ),
      ),
    );
  }
}
