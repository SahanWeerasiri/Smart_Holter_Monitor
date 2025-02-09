import 'package:flutter/material.dart';

class CustomDropdown extends StatefulWidget {
  final String label;
  final List<String> options;
  final Function(String) onChanged;

  const CustomDropdown({
    super.key,
    required this.label,
    required this.options,
    required this.onChanged,
  });

  @override
  State<CustomDropdown> createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  String? selectedValue;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        widget.label,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 8),
      Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey[200],
            border: Border.all(
              color: Colors.grey[400]!,
              width: 1,
            ),
          ),
          child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
            value: selectedValue,
            icon: const Icon(Icons.arrow_drop_down),
            iconSize: 24,
            isExpanded: true,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
            ),
            hint: Text(
              'Select ${widget.label}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            items: widget.options.map((String option) {
              return DropdownMenuItem<String>(
                value: option,
                child: Text(option),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedValue = value!;
              });
              widget.onChanged(value!);
            },
          ))),
    ]);
  }
}
