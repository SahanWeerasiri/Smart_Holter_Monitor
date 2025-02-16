import 'package:flutter/material.dart';
import 'package:health_care_web/app/components/report/date_time_range_picker.dart';
import 'package:health_care_web/app/components/report/time_series_chart.dart';

class HolterGraph extends StatefulWidget {
  final Map<String, int> data;

  const HolterGraph({super.key, required this.data});

  @override
  State<HolterGraph> createState() => _HolterGraphState();
}

class _HolterGraphState extends State<HolterGraph> {
  Map<String, int> selectedData = {};
  late DateTime firstTimestamp;
  late DateTime lastTimestamp;

  @override
  void initState() {
    super.initState();
    _initializeTimestamps();
    _setInitialSelectedData();
  }

  void _initializeTimestamps() {
    if (widget.data.isEmpty) {
      firstTimestamp = DateTime.now();
      lastTimestamp = DateTime.now();
      return;
    }

    List<DateTime> timestamps = [];
    for (var key in widget.data.keys) {
      try {
        timestamps.add(DateTime.parse(key));
      } catch (e) {
        print('Error parsing date: $key, Error: $e');
      }
    }

    if (timestamps.isEmpty) {
      firstTimestamp = DateTime.now();
      lastTimestamp = DateTime.now();
      return;
    }

    timestamps.sort();
    firstTimestamp = timestamps.first;
    lastTimestamp = timestamps.last;
  }

  void _setInitialSelectedData() {
    final endTime = lastTimestamp.add(const Duration(seconds: 30));

    setState(() {
      selectedData = Map.fromEntries(widget.data.entries.where((entry) {
        try {
          final timestamp = DateTime.parse(entry.key);
          return timestamp.isAfter(firstTimestamp) &&
              timestamp.isBefore(endTime);
        } catch (e) {
          return false;
        }
      }));
    });

    // Debug prints to see what data we have
    print('Total data points: ${widget.data.length}');
    print('Selected data points: ${selectedData.length}');
    print('Start time: $firstTimestamp');
    print('End time: $endTime');
  }

  void _onDateTimeRangeSelected(DateTime start, DateTime end) {
    print('New date range selected: $start to $end');

    final newSelectedData = Map.fromEntries(widget.data.entries.where((entry) {
      try {
        final timestamp = DateTime.parse(entry.key);
        return timestamp.isAfter(start) && timestamp.isBefore(end);
      } catch (e) {
        return false;
      }
    }));

    print('New selected data points: ${newSelectedData.length}');

    // Always update the state to ensure the UI refreshes
    setState(() {
      selectedData = newSelectedData;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    // Key forces the chart to rebuild when data changes
    final chartKey =
        ValueKey(selectedData.length.toString() + selectedData.keys.join());

    return Column(
      children: [
        Row(
          children: [
            DateTimeRangePicker(
              initialStart: firstTimestamp,
              initialEnd: lastTimestamp.add(const Duration(seconds: 30)),
              onDateTimeRangeSelected: _onDateTimeRangeSelected,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: TimeSeriesChart(
            key: chartKey,
            rawData: selectedData,
          ),
        ),
      ],
    );
  }
}
