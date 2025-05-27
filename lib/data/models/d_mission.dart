// ignore_for_file: avoid_print

import 'dart:convert';

/// Mission data class for the game
/// Parsed from data file entries
class DMission {
  final String imagePath; // Full image path
  final String episodeId; // Extracted episode ID
  final String levelId;   // Extracted level ID
  final int missionIndex; // Index of the mission
  final String answer;    // Decoded answer
  double picScale = 1.0;  // Image scale factor for display

  /// Constructor to parse from a data string like "challenger1__0__bWFyaW8"
  DMission(String data) :
    imagePath = data,
    episodeId = _extractEpisodeId(data),
    levelId = _extractLevelId(data),
    missionIndex = _extractMissionIndex(data),
    answer = _decodeAnswer(data);
  
  /// Extract episode ID from data string
  static String _extractEpisodeId(String data) {
    final parts = data.split('__');
    if (parts.isEmpty) return "";
    
    final levelPart = parts[0];
    final episodeMatch = RegExp(r'([a-zA-Z]+)').firstMatch(levelPart);
    return episodeMatch?.group(1) ?? "";
  }
  
  /// Extract level ID from data string
  static String _extractLevelId(String data) {
    final parts = data.split('__');
    if (parts.isEmpty) return "";
    
    return parts[0];
  }
  
  /// Extract mission index from data string
  static int _extractMissionIndex(String data) {
    final parts = data.split('__');
    if (parts.length < 2) return 0;
    
    return int.tryParse(parts[1]) ?? 0;
  }
  
  /// Decode the Base64 answer from data string
  static String _decodeAnswer(String data) {
    final parts = data.split('__');
    if (parts.length < 3) return "";
    
    final encodedAnswer = parts[2];
    try {
      // Handle URL-safe Base64 characters
      String base64String = encodedAnswer.replaceAll('-', '+').replaceAll('_', '/');
      
      // Add padding if needed
      switch (base64String.length % 4) {
        case 2: base64String += '=='; break;
        case 3: base64String += '='; break;
      }
      
      // Decode Base64
      final bytes = base64.decode(base64String);
      return utf8.decode(bytes);
    } catch (e) {
      print("Error decoding answer: $e");
      return encodedAnswer; // Return encoded version if decoding fails
    }
  }

  /// Get the key used for SharedPreferences
  String get sharedPrefKey => imagePath;
  
  /// Split the answer into individual characters
  List<String> get answerChars => answer.toUpperCase().split('');
}