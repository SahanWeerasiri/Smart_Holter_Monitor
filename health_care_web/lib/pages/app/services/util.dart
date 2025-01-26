List<String> generateTags(String name) {
  // Convert the name to lowercase to make all tags simple
  String lowerCaseName = name.toLowerCase();

  // Generate the tags
  List<String> tags = [];
  for (int i = 1; i <= lowerCaseName.length; i++) {
    tags.add(lowerCaseName.substring(0, i));
  }

  return tags;
}
