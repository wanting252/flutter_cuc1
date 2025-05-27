import 'package:claude_cuc/config/const.dart';

import 'd_level.dart';
import 'd_player.dart';

class DEpisode {
  final String id;
  final String name;
  final String desc;
  final int requiredCount;
  int playCount;
  List<DLevel> levels = [];

  DEpisode({
    required this.id,
    required this.name,
    required this.desc,
    required this.requiredCount,
    required this.playCount,
  });

  factory DEpisode.fromJson(Map<String, dynamic> json) {
    return DEpisode(
      id: json['id'],
      name: json['name'],
      desc: json['desc'],
      requiredCount: json['requiredCount'],
      playCount: json['playCount'],
    );
  }

  // Return true if all levels in this episode are completed
  bool isCompleted() {
    if (levels.isEmpty) return false;
    
    bool allCompleted = true;
    for (var level in levels) {
      if (!level.isCompleted()) {
        allCompleted = false;
        break;
      }
    }
    
    // Debug
    print('Episode $id isCompleted check: $allCompleted');
    return allCompleted;
  }
  
  // Get the required count of completed levels to unlock this episode
  int required() => requiredCount;
  
  // Get the description of the episode
  String get description => desc;
  
  // Get the progress percentage of the episode
  int get progress => DPlayer.getEpisodeProgress(id);
  
  // Get total levels in this episode
  int get totalPictures => levels.length;
  
  // Check if this episode is locked
  bool get isLocked => DPlayer.getState(id) == Consts.LOCKED;
  
  // Check if this episode is completed
  bool get isComplete => DPlayer.getState(id) == Consts.COMPLETED;
}