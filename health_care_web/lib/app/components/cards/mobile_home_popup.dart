import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class MobileHomePopup extends StatefulWidget {
  final String device;
  const MobileHomePopup({super.key, required this.device});

  @override
  State<MobileHomePopup> createState() => _MobileHomePopupState();
}

class _MobileHomePopupState extends State<MobileHomePopup> {
  int currentHeartRate = 0;
  num avgHeartRate = 0.0;
  Color stateBoxColor = StyleSheet().stateHeartBoxBad;

  @override
  void initState() {
    super.initState();
    fetchDeviceData(widget.device);
  }

  Future<void> fetchDeviceData(String device) async {
    final FirebaseDatabase database = FirebaseDatabase.instance;
    // Reference to the device's data
    final ref = database.ref('devices').child(device).child('data');
    // Listen for real-time updates
    ref.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (!mounted) return;

      if (data != null && data.isNotEmpty) {
        // Convert the map to a sorted list of entries (descending by timestamp)
        final sortedEntries = data.entries.toList()
          ..sort((a, b) =>
              b.key.compareTo(a.key)); // Sort by key (time_stamp) descending

        final values =
            sortedEntries.map((entry) => entry.value as num).toList();
        final avgValue = values.isNotEmpty
            ? values.reduce((a, b) => a + b) / values.length
            : 0;

        // The latest entry will now be the first
        final latestEntry = sortedEntries.first;
        setState(() {
          currentHeartRate = latestEntry.value;
          avgHeartRate = avgValue;
          if (60 <= currentHeartRate && currentHeartRate <= 100) {
            stateBoxColor = StyleSheet().stateHeartBoxGood;
          } else {
            stateBoxColor = StyleSheet().stateHeartBoxBad;
          }
        });
      } else {
        setState(() {
          currentHeartRate = 0;
          avgHeartRate = 0.0;
        });
      }
    }, onError: (error) {
      if (!mounted) return;
      setState(() {
        currentHeartRate = 0;
        avgHeartRate = 0.0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = 400;
    double height = 300;
    return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Container(
          color: StyleSheet().uiBackground,
          padding: EdgeInsets.all(8),
          width: width,
          height: height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: StyleSheet().currentHeartBox,
                  ),
                  width: width * 0.9,
                  height: height * 0.4,
                  child: Padding(
                    padding: EdgeInsets.all(5),
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
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              currentHeartRate.toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            Text(
                              "bpm",
                              style: TextStyle(
                                fontSize: 13,
                              ),
                            )
                          ],
                        ),
                        Image.asset('assetes/icons/logo.png')
                      ],
                    ),
                  )),
              SizedBox(
                height: height * 0.04,
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
                          width: width * 0.4,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            color: StyleSheet().avgHeartBox,
                          ),
                          height: height * 0.4,
                          child: Padding(
                            padding: EdgeInsets.all(width * 0.05),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Avg Heart Rate",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  avgHeartRate.toString().split(".")[0],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                                Text(
                                  "bpm",
                                  style: TextStyle(
                                    fontSize: 13,
                                  ),
                                )
                              ],
                            ),
                          )),
                      Container(
                          width: width * 0.4,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            color: stateBoxColor,
                          ),
                          height: height * 0.4,
                          child: Padding(
                            padding: EdgeInsets.all(width * 0.05),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Status",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                Text(
                                  (60 < currentHeartRate &&
                                          currentHeartRate < 100)
                                      ? "Good"
                                      : "Bad",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 30,
                                  ),
                                ),
                              ],
                            ),
                          ))
                    ],
                  )),
            ],
          ),
        ));
  }
}
