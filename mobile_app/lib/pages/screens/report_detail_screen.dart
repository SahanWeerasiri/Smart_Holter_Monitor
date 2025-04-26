import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:health_care/models/report.dart';
import 'package:health_care/models/user.dart';
import 'package:health_care/pages/app/services/firestore_db_service.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class ReportDetailScreen extends StatefulWidget {
  final Report report;
  final Account patient;
  final ReportDoctor doctor;
  final List<Map<String, int>> heartRateData;

  const ReportDetailScreen({
    super.key,
    required this.report,
    required this.patient,
    required this.doctor,
    required this.heartRateData,
  });

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _startTime = DateTime.now().subtract(const Duration(hours: 24));
  DateTime _endTime = DateTime.now();
  String label = "Normal";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    if (widget.heartRateData.isNotEmpty) {
      _startTime = DateTime.parse(widget.heartRateData.first.entries.first.key);
      _endTime = _startTime.add(const Duration(seconds: 10));
    }
    _update();
  }

  Future<void> _update() async {
    await FirestoreDbService().updateReportSeen(
        FirebaseAuth.instance.currentUser!.uid, widget.report.reportId);
    print("Read");
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("General Report - ${widget.report.timestamp}"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          color: Colors.teal,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.report.timestamp,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 12),
                    _buildInfoRow('Patient', widget.patient.name),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      'Doctor',
                      widget.doctor.name,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Heart Rate Data',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildTimeRangeSelector(),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TabBar(
                        controller: _tabController,
                        labelColor: Colors.teal,
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: Colors.teal,
                        tabs: const [
                          Tab(text: 'Channel 1'),
                          Tab(text: 'Channel 2'),
                          Tab(text: 'Channel 3'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildHeartRateChart(1),
                            _buildHeartRateChart(2),
                            _buildHeartRateChart(3),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: label != "Normal"
                      ? Colors.red
                      : Colors.green, // Fixed ternary operator
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionCard('Summary', widget.report.brief),
            const SizedBox(height: 16),
            _buildSectionCard('Anomaly Detection', widget.report.anomalies),
            const SizedBox(height: 16),
            _buildSectionCard(
                'Doctor Suggestions', widget.report.docSuggestions),
            // const SizedBox(height: 16),
            // _buildSectionCard('AI Suggestions', widget.report.aiSuggestions),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeRangeSelector() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Time Range',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Column(
              children: [
                _buildDateTimeSelector('Start', _startTime, (newDateTime) {
                  if (newDateTime.isBefore(_endTime)) {
                    setState(() {
                      _startTime = newDateTime;
                      _endTime = newDateTime.add(const Duration(seconds: 10));
                    });
                  }
                }),
                // const SizedBox(width: 16),
                // _buildDateTimeSelector('End', _endTime, (newDateTime) {
                //   if (newDateTime.isAfter(_startTime)) {
                //     setState(() {
                //       _endTime = newDateTime;
                //     });
                //   }
                // }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimeSelector(
      String label, DateTime dateTime, Function(DateTime) onChanged) {
    final dateFormat = DateFormat('yyyy-MM-dd');
    final timeFormat = DateFormat('HH:mm');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: () async {
            final DateTime? selectedDate = await showDatePicker(
              context: context,
              initialDate: dateTime,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );

            if (selectedDate != null) {
              final TimeOfDay? selectedTime = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.fromDateTime(dateTime),
              );

              if (selectedTime != null) {
                final newDateTime = DateTime(
                  selectedDate.year,
                  selectedDate.month,
                  selectedDate.day,
                  selectedTime.hour,
                  selectedTime.minute,
                );

                onChanged(newDateTime);
              }
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${dateFormat.format(dateTime)} ${timeFormat.format(dateTime)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Icon(
                  Icons.access_time,
                  size: 16,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  DateTime convertTimestamp(String timestamp) {
    // Replace the first two colons (in the date part) with hyphens
    String normalizedTimestamp =
        timestamp.replaceFirst(':', '-').replaceFirst(':', '-');

    // Replace the last colon (before milliseconds) with a dot
    normalizedTimestamp = normalizedTimestamp.replaceFirst(
      RegExp(r':\d{3}$'),
      '.${normalizedTimestamp.substring(normalizedTimestamp.length - 3)}',
    );
    print(DateTime.parse(normalizedTimestamp));
    return DateTime.parse(normalizedTimestamp);
  }

  Widget _buildHeartRateChart(int channel) {
    // Select the appropriate channel data
    Map<String, int> channelData;
    switch (channel) {
      case 1:
        channelData = widget.heartRateData[0]; // Channel 1
        break;
      case 2:
        channelData = widget.heartRateData[1]; // Channel 2
        break;
      case 3:
        channelData = widget.heartRateData[2]; // Channel 3
        break;
      default:
        channelData = widget.heartRateData[0]; // Default to Channel 1
    }

    // Convert the channel data into a list of maps with timestamp and value
    List<Map<String, dynamic>> dataPoints = channelData.entries.map((entry) {
      return {
        'timestamp': entry.key,
        'value': entry.value,
      };
    }).toList();

    // Filter data based on the selected time range
    final filteredData = dataPoints.where((data) {
      final timestamp = DateTime.parse(data['timestamp']);
      return timestamp.isAfter(_startTime) && timestamp.isBefore(_endTime);
    }).toList();

    // Debug print to verify filtered data
    debugPrint('Filtered Data: ${filteredData.length} points');

    if (filteredData.isEmpty) {
      return const Center(
        child: Text(
          'No data available for the selected time range',
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
      );
    }

    // Create line chart data
    List<FlSpot> spots = [];

    for (int i = 0; i < filteredData.length; i++) {
      final data = filteredData[i];
      final value = data['value'] as int;

      spots.add(FlSpot(i.toDouble(), value.toDouble()));
    }

    return LineChart(
      LineChartData(
        lineTouchData: LineTouchData(
          enabled: true,
          handleBuiltInTouches: true,
          touchCallback: (p0, p1) => {
            //zoom
          },
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          drawHorizontalLine: true,
          horizontalInterval: 40, // Adjust the interval for horizontal lines
          verticalInterval: 40, // Adjust the interval for vertical lines
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: const Color.fromARGB(255, 255, 2, 2)
                  .withOpacity(0.5), // Grid line color
              strokeWidth: 1,
              dashArray: [1, 2], // Dash pattern: 5 pixels drawn, 5 pixels gap
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: const Color.fromARGB(255, 255, 0, 0)
                  .withOpacity(0.5), // Grid line color
              strokeWidth: 1,
              dashArray: [1, 1], // Dash pattern: 5 pixels drawn, 5 pixels gap
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false), // Hide X-axis values
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false), // Hide Y-axis values
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(
            color: Colors.grey.withOpacity(0.5),
            width: 1,
          ),
        ),
        minX: 0,
        maxX: filteredData.length.toDouble() - 1,
        minY: 0,
        maxY: 4096,
        backgroundColor: const Color.fromARGB(255, 255, 146, 146)
            .withOpacity(0.8), // Light pink background
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            aboveBarData: BarAreaData(
              show: true,
              color: Colors.black
                  .withOpacity(0.1), // Light black for area above the line
            ),
            isCurved: true,
            color: Colors.black, // Black for the main line
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.black
                  .withOpacity(0.1), // Light black for area below the line
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(String title, String content) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),
            Text(
              content,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
