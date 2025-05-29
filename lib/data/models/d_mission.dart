// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

/// Mission data class for the game
/// Parsed from data file entries
class DMission {
  final String imagePath; // Full image path
  final String episodeId; // Extracted episode ID
  final String levelId;   // Extracted level ID
  final int missionIndex; // Index of the mission
  final String answer;    // Decoded answer
  double picScale = 1.0;  // Image scale factor for display
  
  // Game state data
  int currentZoomLevel = 1; // Current zoom level (1, 2, or 3)
  List<String> playerAnswer = []; // Current answer state (includes spaces and filled letters)
  List<String> optionLetters = []; // Generated option letters (14 letters)
  List<bool> selectedOptions = []; // Which option letters are selected
  bool isCompleted = false; // Whether this mission is completed
  bool hasGeneratedOptions = false; // Whether options have been generated for this mission

  /// Constructor to parse from a data string like "challenger1__0__bWFyaW8"
  DMission(String data) :
    imagePath = data,
    episodeId = _extractEpisodeId(data),
    levelId = _extractLevelId(data),
    missionIndex = _extractMissionIndex(data),
    answer = _decodeAnswer(data) {
    _initializeAnswer();
  }
  
  /// Initialize the answer array with empty strings and spaces
  void _initializeAnswer() {
    playerAnswer = answer.toUpperCase().split('').map((char) => 
      char == ' ' ? ' ' : ''
    ).toList();
  }
  
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
      print("DMission._decodeAnswer Error decoding answer: $e");
      return encodedAnswer; // Return encoded version if decoding fails
    }
  }

  /// Get the key used for SharedPreferences
  String get sharedPrefKey => imagePath;
  
  /// Split the answer into individual characters
  List<String> get answerChars => answer.toUpperCase().split('');
  
  /// Get SharedPreferences key for mission state
  String get _missionStateKey => 'mission_state_$imagePath';
  
  /// Generate option letters for this mission
  void generateOptionLetters() {
    print("{DMission.generateOptionLetters} Generating options for mission: $imagePath");
    
    if (hasGeneratedOptions && optionLetters.isNotEmpty) {
      print("{DMission.generateOptionLetters} Options already generated, skipping");
      return;
    }
    
    // Get answer letters (without spaces)
    final answerLetters = answer.replaceAll(' ', '').toUpperCase().split('');
    
    // Generate random letters to fill up to 14 total
    const allLetters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final random = Random();
    final neededRandomLetters = 14 - answerLetters.length;
    
    List<String> randomLetters = [];
    for (int i = 0; i < neededRandomLetters; i++) {
      randomLetters.add(allLetters[random.nextInt(allLetters.length)]);
    }
    
    // Combine and shuffle
    optionLetters = [...answerLetters, ...randomLetters];
    optionLetters.shuffle(random);
    
    // Ensure we have exactly 14 letters
    if (optionLetters.length > 14) {
      optionLetters = optionLetters.take(14).toList();
    } else if (optionLetters.length < 14) {
      // Fill remaining with more random letters
      while (optionLetters.length < 14) {
        optionLetters.add(allLetters[random.nextInt(allLetters.length)]);
      }
    }
    
    selectedOptions = List.filled(14, false);
    hasGeneratedOptions = true;
    
    print("{DMission.generateOptionLetters} Generated letters: $optionLetters");
  }
  
  /// Check if the current answer is correct
  bool checkAnswer() {
    final currentAnswer = playerAnswer.join('');
    final correctAnswer = answer.toUpperCase();
    
    print("{DMission.checkAnswer} Current: '$currentAnswer', Correct: '$correctAnswer'");
    
    final correct = currentAnswer == correctAnswer;
    if (correct) {
      isCompleted = true;
      saveMissionState();
    }
    
    return correct;
  }
  
  /// Get the next empty position in the answer (skip spaces)
  int getNextEmptyPosition() {
    for (int i = 0; i < playerAnswer.length; i++) {
      if (playerAnswer[i] == '') {
        return i;
      }
    }
    return -1; // No empty positions
  }
  
  /// Fill a letter at the specified position
  bool fillLetterAt(int position, String letter) {
    if (position >= 0 && position < playerAnswer.length && playerAnswer[position] == '') {
      playerAnswer[position] = letter;
      return true;
    }
    return false;
  }
  
  /// Remove letter at specified position and mark corresponding option as unselected
  bool removeLetterAt(int position) {
    if (position >= 0 && position < playerAnswer.length && playerAnswer[position] != ' ' && playerAnswer[position] != '') {
      final letter = playerAnswer[position];
      
      // Find this letter in options and mark as unselected
      for (int i = 0; i < optionLetters.length; i++) {
        if (optionLetters[i] == letter && selectedOptions[i]) {
          selectedOptions[i] = false;
          playerAnswer[position] = '';
          return true;
        }
      }
      
      // If not found in options, still remove from answer
      playerAnswer[position] = '';
      return true;
    }
    return false;
  }
  
  /// Select an option letter and fill it in the answer
  bool selectOptionLetter(int optionIndex) {
    if (optionIndex >= 0 && optionIndex < optionLetters.length && 
        !selectedOptions[optionIndex] && optionLetters[optionIndex].isNotEmpty) {
      
      final letter = optionLetters[optionIndex];
      final emptyPosition = getNextEmptyPosition();
      
      if (emptyPosition != -1) {
        selectedOptions[optionIndex] = true;
        playerAnswer[emptyPosition] = letter;
        return true;
      }
    }
    return false;
  }
  
  /// Get the next correct letter for hints
  String? getNextCorrectLetter() {
    final correctAnswer = answer.toUpperCase();
    final emptyPosition = getNextEmptyPosition();
    
    if (emptyPosition != -1 && emptyPosition < correctAnswer.length) {
      return correctAnswer[emptyPosition];
    }
    return null;
  }
  
  /// Fill next correct letter (for hint system)
  bool fillNextCorrectLetter() {
    final nextLetter = getNextCorrectLetter();
    if (nextLetter == null) return false;
    
    // Find this letter in options
    for (int i = 0; i < optionLetters.length; i++) {
      if (optionLetters[i] == nextLetter && !selectedOptions[i]) {
        return selectOptionLetter(i);
      }
    }
    return false;
  }
  
  /// Remove a wrong letter from options (for remove hint system)
  bool removeWrongLetter() {
    final correctLetters = answer.replaceAll(' ', '').toUpperCase();
    
    for (int i = 0; i < optionLetters.length; i++) {
      if (!selectedOptions[i] && 
          optionLetters[i].isNotEmpty && 
          !correctLetters.contains(optionLetters[i])) {
        optionLetters[i] = ''; // Mark as removed
        return true;
      }
    }
    return false;
  }
  
  /// Reset mission state
  void resetMissionState() {
    print("{DMission.resetMissionState} Resetting mission state for: $imagePath");
    
    currentZoomLevel = 1;
    _initializeAnswer();
    optionLetters.clear();
    selectedOptions.clear();
    isCompleted = false;
    hasGeneratedOptions = false;
    
    saveMissionState();
  }
  
  /// Save mission state to SharedPreferences
  Future<void> saveMissionState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stateData = {
        'currentZoomLevel': currentZoomLevel,
        'playerAnswer': playerAnswer,
        'optionLetters': optionLetters,
        'selectedOptions': selectedOptions,
        'isCompleted': isCompleted,
        'hasGeneratedOptions': hasGeneratedOptions,
      };
      
      final jsonString = jsonEncode(stateData);
      await prefs.setString(_missionStateKey, jsonString);
      
      print("{DMission.saveMissionState} Saved state for mission: $imagePath");
    } catch (e) {
      print("{DMission.saveMissionState} Error saving mission state: $e");
    }
  }
  
  /// Load mission state from SharedPreferences
  Future<void> loadMissionState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_missionStateKey);
      
      if (jsonString != null) {
        final stateData = jsonDecode(jsonString) as Map<String, dynamic>;
        
        currentZoomLevel = stateData['currentZoomLevel'] ?? 1;
        playerAnswer = List<String>.from(stateData['playerAnswer'] ?? []);
        optionLetters = List<String>.from(stateData['optionLetters'] ?? []);
        selectedOptions = List<bool>.from(stateData['selectedOptions'] ?? []);
        isCompleted = stateData['isCompleted'] ?? false;
        hasGeneratedOptions = stateData['hasGeneratedOptions'] ?? false;
        
        print("{DMission.loadMissionState} Loaded state for mission: $imagePath");
      } else {
        print("{DMission.loadMissionState} No saved state found for mission: $imagePath");
        _initializeAnswer();
      }
    } catch (e) {
      print("{DMission.loadMissionState} Error loading mission state: $e");
      _initializeAnswer();
    }
  }
  
  /// Clear mission state from SharedPreferences
  Future<void> clearMissionState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_missionStateKey);
      print("{DMission.clearMissionState} Cleared state for mission: $imagePath");
    } catch (e) {
      print("{DMission.clearMissionState} Error clearing mission state: $e");
    }
  }
  
  /// Get mission completion progress (0.0 to 1.0)
  double get completionProgress {
    if (playerAnswer.isEmpty) return 0.0;
    
    final totalLetters = playerAnswer.where((char) => char != ' ').length;
    final filledLetters = playerAnswer.where((char) => char != ' ' && char != '').length;
    
    if (totalLetters == 0) return 0.0;
    return filledLetters / totalLetters;
  }
  
  /// Get number of filled letters (excluding spaces)
  int get filledLetterCount {
    return playerAnswer.where((char) => char != ' ' && char != '').length;
  }
  
  /// Get total number of letters (excluding spaces)
  int get totalLetterCount {
    return playerAnswer.where((char) => char != ' ').length;
  }
  
  /// Check if mission has any progress
  bool get hasProgress {
    return filledLetterCount > 0 || currentZoomLevel > 1;
  }
  
  /// Get current answer as display string
  String get currentAnswerDisplay {
    return playerAnswer.join('');
  }
}