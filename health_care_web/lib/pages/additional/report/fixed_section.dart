import 'package:flutter/material.dart';

class FixedSection extends StatefulWidget {
  final String title;
  final String text;

  const FixedSection({
    super.key,
    required this.title,
    required this.text,
  });

  @override
  State<FixedSection> createState() => _FixedSectionState();
}

class _FixedSectionState extends State<FixedSection> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            widget.text,
            style: TextStyle(
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          Divider(thickness: 1, color: Colors.grey[400]),
        ],
      ),
    );
  }
}
