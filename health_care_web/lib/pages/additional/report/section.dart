import 'package:flutter/material.dart';

class ReportSection extends StatefulWidget {
  final String title;
  final TextEditingController controller;
  final String inputType; // "paragraph", "bullet", "numbered"

  const ReportSection({
    super.key,
    required this.title,
    required this.controller,
    required this.inputType,
  });

  @override
  State<ReportSection> createState() => _ReportSectionState();
}

class _ReportSectionState extends State<ReportSection> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    // If the input type is bullet or numbered, handle formatting
    if (widget.inputType == "bullet" || widget.inputType == "numbered") {
      List<String> lines = widget.controller.text.split('\n');

      for (int i = 0; i < lines.length; i++) {
        // Handle bullet format
        if (widget.inputType == "bullet") {
          // Ensure each line starts with a bullet point (unless it's a deletion scenario)
          if (!lines[i].startsWith("• ") && lines[i].isNotEmpty) {
            lines[i] = "• ${lines[i].trim()}";
          }
          // If the user deletes the bullet point, remove it only if the line is empty after removing the bullet
          if (lines[i] == "• ") {
            lines.removeAt(i); // Remove the bullet point
          }
        }
        // Handle numbered list format
        else if (widget.inputType == "numbered") {
          // Ensure each line starts with the correct number (unless it's a deletion scenario)
          if (!RegExp(r"^\d+\.\s").hasMatch(lines[i]) && lines[i].isNotEmpty) {
            lines[i] = "${i + 1}. ${lines[i].trim()}";
          }
          // If the user deletes a number, remove it only if the line is empty after removing the number
          if (lines[i] == "${i + 1}. ") {
            lines.removeAt(i); // Remove the number
          }
        }
      }

      // Rebuild the text content after applying the above logic
      String updatedText = lines.join('\n');

      // If the updated text is different from the current text, update the controller's text
      if (updatedText != widget.controller.text) {
        widget.controller.value = TextEditingValue(
          text: updatedText,
          selection: TextSelection.collapsed(offset: updatedText.length),
        );
      }
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

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
          TextField(
            controller: widget.controller,
            maxLines: null,
            keyboardType: TextInputType.multiline,
            decoration: InputDecoration(
              hintText: widget.inputType == "bullet"
                  ? "• Enter bullet points..."
                  : widget.inputType == "numbered"
                      ? "1. Enter numbered list..."
                      : "Write here...",
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.all(10),
            ),
          ),
          const SizedBox(height: 10),
          Divider(thickness: 1, color: Colors.grey[400]),
        ],
      ),
    );
  }
}
