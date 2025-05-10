import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';

import 'd_episode.dart';
import 'd_level.dart';

class DPlayer {
  static late List<DEpisode> episodes;
  static List<DLevel> levelDaily = [];
  static int levelDailyIndex = 0;
  static int coin = 0;
  static bool removeAd = false;

  static Future<void> loadData() async {
    // Load game data from JSON.
    final jsonStr = await rootBundle.loadString('data/data.json');
    final data = jsonDecode(jsonStr);

    // Parse episodes.
    episodes = (data['episodes'] as List)
        .map((e) => DEpisode.fromJson(e))
        .toList();

    // Parse levels per episode.
    final levelsMap = data['levels'] as Map<String, dynamic>;
    for (var ep in episodes) {
      final epLevels = levelsMap[ep.id] ?? [];
      ep.levels = (epLevels as List).map((l) => DLevel.fromJson(l)).toList();
    }

    // Load saved player settings from SharedPreferences.
    final prefs = await SharedPreferences.getInstance();
    coin = prefs.getInt('coin') ?? 0;
    removeAd = prefs.getBool('removeAd') ?? false;
  }

  static int get levelCount =>
      episodes.fold(0, (sum, ep) => sum + ep.levels.length);

  static int get levelCompletedCount => episodes.fold(
      0, (sum, ep) => sum + ep.levels.where((lvl) => lvl.isCompleted()).length);

  static double get gameCompleteRatio =>
      (levelCompletedCount / levelCount).clamp(0.0, 1.0);
}
