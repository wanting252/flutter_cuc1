class DMission {
  final String imageName;
  final String answer;
  double picScale = 1.0;

  DMission({
    required this.imageName,
    required this.answer,
  });

  String get sharedPrefKey => imageName;

  // Here you can plug SharedPreferences to get/save progress

  bool isSolved() {
    // Return true if answer is saved in prefs
    return false; // TODO: Implement SharedPref logic
  }

  // Optional helpers
  List<String> get answerChars => answer.toUpperCase().split('');
}
