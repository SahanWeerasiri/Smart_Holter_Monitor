import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:health_care_web/models/holter_data.dart' as model;

class HolterGraph extends StatelessWidget {
  final List<model.HolterData> data;

  const HolterGraph({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final minX = data.first.timestamp.millisecondsSinceEpoch.toDouble();
    final maxX = data.last.timestamp.millisecondsSinceEpoch.toDouble();
    final interval = (maxX - minX) / 4; // Divide into 4 sections

    // Generate 4 midpoints for time labels
    final List<double> timePoints = List.generate(
      4,
      (index) => minX + interval * index,
    );

    return LineChart(
      LineChartData(
        minX: minX,
        maxX: maxX,
        minY: 0,
        maxY: 4095,
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 35,
              getTitlesWidget: (value, meta) {
                if (timePoints.contains(value)) {
                  DateTime date =
                      DateTime.fromMillisecondsSinceEpoch(value.toInt());
                  return Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Transform.rotate(
                      angle: -0.5, // Slight rotation for better fit
                      child: Text(
                        DateFormat.Hms().format(date),
                        style: TextStyle(fontSize: 10),
                      ),
                    ),
                  );
                }
                return Container();
              },
              interval: interval,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false), // Hide Y-axis values
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: data
                .map((e) => FlSpot(
                    e.timestamp.millisecondsSinceEpoch.toDouble(),
                    e.value.toDouble()))
                .toList(),
            isCurved: true,
            color: Colors.blue,
            barWidth: 2,
            dotData: FlDotData(show: false),
          ),
        ],
      ),
    );
  }
}
