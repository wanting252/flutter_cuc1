import 'package:shared_preferences/shared_preferences.dart';
import 'd_mission.dart';

class DLevel {
  final String icon;
  final int requiredCount;
  final String id;
  List<DMission> answers = [];
  int currentIndex = 0;
  
  DLevel({
    required this.icon,
    required this.requiredCount,
    required this.id,
  });
  
  factory DLevel.fromJson(Map<String, dynamic> json) {
    return DLevel(
      icon: json['icon'] ?? "default_icon",
      requiredCount: json['requiredCount'] ?? 0,
      id: json['id'],
    );
  }

  int get levelCount => answers.length;

  // Check if this level is locked based on required count
  bool isLocked(int completedCount) {
    return requiredCount > completedCount;
  }
  
  // Check if this level is completed
  bool isCompleted() {
    bool completed = currentIndex >= answers.length && answers.isNotEmpty;
    // Debug
    print('Level $id isCompleted: $completed (currentIndex: $currentIndex, answers: ${answers.length})');
    return completed;
  }
  
  // Get the progress percentage of this level
  int get progress {
    if (answers.isEmpty) return 0;
    int progressPercent = ((currentIndex / answers.length) * 100).round();
    return progressPercent.clamp(0, 100);
  }
  
  // Save the level progress to SharedPreferences
  Future<void> saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'level_index_$id';
    await prefs.setInt(key, currentIndex);
    
    // Debug
    // print('Saved progress for level $id: $currentIndex');
  }
  
  // Load the level progress from SharedPreferences
  Future<void> loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'level_index_$id';
    currentIndex = prefs.getInt(key) ?? 0;
    
    // Debug
    print('Loaded progress for level $id: $currentIndex (answers: ${answers.length})');
  }
}