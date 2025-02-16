import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TimeSeriesChart extends StatefulWidget {
  final Map<String, int> rawData;

  const TimeSeriesChart({super.key, required this.rawData});

  @override
  State<TimeSeriesChart> createState() => _TimeSeriesChartState();
}

class _TimeSeriesChartState extends State<TimeSeriesChart> {
  List<FlSpot> spots = [];
  List<double> timePoints = [];
  double minX = 0;
  double maxX = 0;
  double interval = 0;

  @override
  void initState() {
    super.initState();
    _processData();
  }

  void _processData() {
    final data = widget.rawData;
    if (data.isEmpty) return;

    // Convert string timestamps to DateTime and then to milliseconds
    List<MapEntry<double, int>> timeSeriesData = [];

    for (var entry in data.entries) {
      try {
        final dateTime = DateTime.parse(entry.key);
        final timestamp = dateTime.millisecondsSinceEpoch.toDouble();
        timeSeriesData.add(MapEntry(timestamp, entry.value));
      } catch (e) {
        print('Error parsing date: ${entry.key}, Error: $e');
      }
    }

    // Sort by timestamp
    timeSeriesData.sort((a, b) => a.key.compareTo(b.key));

    // Create spots for the chart
    spots =
        timeSeriesData.map((e) => FlSpot(e.key, e.value.toDouble())).toList();

    // Calculate min and max X values
    if (spots.isNotEmpty) {
      minX = spots.first.x;
      maxX = spots.last.x;

      // Select a reasonable number of points to show on x-axis (e.g., 5)
      final pointCount = 5;
      final step = (maxX - minX) / (pointCount - 1);

      timePoints = List.generate(pointCount, (i) => minX + (step * i));
      interval = step;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (spots.isEmpty) {
      return Center(child: Text('No data available'));
    }

    return AspectRatio(
      aspectRatio: 3.5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LineChart(
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
                    // Only show a subset of timestamps to avoid overcrowding
                    if (timePoints.contains(value) ||
                        timePoints.any((t) => (t - value).abs() < 0.001)) {
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
              rightTitles:
                  AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: FlGridData(show: true),
            borderData: FlBorderData(show: true),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: Colors.blue,
                barWidth: 2,
                dotData: FlDotData(show: false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
