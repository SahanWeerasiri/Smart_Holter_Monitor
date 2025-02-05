class ReportModel {
  String timestamp;
  String description;
  String brief;
  String docSuggestions;
  String aiSuggestions;
  String avgHeart;
  String graph;
  String reportId;
  String anomalies;
  bool isEditing;
  String docName;
  String docEmail;
  String age;

  ReportModel(
      {required this.timestamp,
      required this.brief,
      required this.description,
      required this.aiSuggestions,
      required this.avgHeart,
      required this.docSuggestions,
      required this.graph,
      required this.reportId,
      required this.isEditing,
      required this.docName,
      required this.age,
      required this.docEmail,
      this.anomalies = ""});
}
