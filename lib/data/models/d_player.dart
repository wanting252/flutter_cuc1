import 'dart:convert';
import 'dart:math';
import 'package:claude_cuc/config/const.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';

import 'd_episode.dart';
import 'd_level.dart';
import 'd_mission.dart';

class DPlayer {
  static late List<DEpisode> episodes;
  static DLevel? levelDaily; // Single daily level, not a list
  static int levelDailyIndex = 0;
  static int coin = 0;
  static bool removeAd = false;
  
  // Settings
  static bool soundEnabled = true;
  static bool musicEnabled = true;
  static int selectedAvatarIndex = 0;
  static String playerId = "";
  
  // Current game progress
  static String _currentEpisodeId = "";
  static int _currentLevelIndex = 0;
  
  // SharedPrefs keys
  static const String _prefKeyCoin = 'coin';
  static const String _prefKeyRemoveAd = 'removeAd';
  static const String _prefKeyCurrentEpisode = 'currentEpisodeId';
  static const String _prefKeyCurrentLevel = 'currentLevelIndex';
  static const String _prefKeyLevelPrefix = 'level_index_for_episode_';
  static const String _prefKeySoundEnabled = 'sound_enabled';
  static const String _prefKeyMusicEnabled = 'music_enabled';
  static const String _prefKeySelectedAvatar = 'selected_avatar';
  static const String _prefKeyPlayerId = 'player_id';
  
  // Daily mission specific keys;
  static const String _prefKeyDailyMissionDate = 'daily_mission_date';
  // static const String _prefKeyDailyMissionIndex = 'daily_mission_index';
  
  // Test override for daily reset time (default: use Consts.DAILY_RESET_TIME_SECONDS)
  static int? _testDailyResetTimeSeconds;
  
  // Data from JSON
  static Map<String, dynamic> gameData = {};

  /// Generate a random 6-digit player ID
  static String _generatePlayerId() {
    final random = Random();
    final randomNumber = random.nextInt(900000) + 100000; // Ensures 6 digits
    return "player_$randomNumber";
  }

  /// Reset the game progress to start (all levels to 0)
  /// Optionally regenerate player ID if requested
  static Future<void> resetProgress({bool regenerateId = false}) async {
    print("DPlayer.resetProgress resetting all game progress, regenerateId: $regenerateId");
    
    // Reset all level progress
    for (var episode in episodes) {
      for (var level in episode.levels) {
        level.currentIndex = 0;
        await level.saveProgress(); // Save the reset progress
      }
    }
    
    // Reset player stats
    _currentEpisodeId = episodes.isNotEmpty ? episodes.first.id : "";
    _currentLevelIndex = 0;
    
    // Optionally regenerate player ID
    if (regenerateId) {
      await regeneratePlayerId();
    }
    
    // Save to SharedPreferences
    await savePlayerPrefs();
    
    // Clear all level-specific indices
    final prefs = await SharedPreferences.getInstance();
    
    // Get all keys that start with the level prefix
    final keys = prefs.getKeys().where((key) => key.startsWith(_prefKeyLevelPrefix));
    
    // Remove each level progress key
    for (var key in keys) {
      await prefs.remove(key);
    }
    
    print("DPlayer.resetProgress reset completed");
  }

  static Future<void> loadData() async {
    print("DPlayer.loadData loading game data from JSON");
    
    // Load game data from JSON.
    final jsonStr = await rootBundle.loadString('assets/data/data.json');
    gameData = jsonDecode(jsonStr);

    // Parse episodes.
    episodes = (gameData['episodes'] as List)
        .map((e) => DEpisode.fromJson(e))
        .toList();

    // Parse levels per episode.
    final levelsMap = gameData['levels'] as Map<String, dynamic>;
    for (var ep in episodes) {
      final epLevels = levelsMap[ep.id] ?? [];
      ep.levels = (epLevels as List).map((l) => DLevel.fromJson(l)).toList();
      
      // Load mission data for each level
      for (var level in ep.levels) {
        // Get mission data from the 'data' section of JSON
        final missionData = gameData['data'][level.id] as List?;
        if (missionData != null) {
          level.answers = missionData.map((m) => DMission(m as String)).toList();
        }
        
        // Load progress for each level
        await level.loadProgress();
      }
    }

    // Load daily missions
    final dailyMissions = gameData['data']['daily'] as List?;
    if (dailyMissions != null) {
      levelDaily = DLevel(
        icon: "daily",
        requiredCount: 0,
        id: "daily"
      );
      
      levelDaily!.answers = dailyMissions.map((m) => DMission(m as String)).toList();
      await levelDaily!.loadProgress();
    }

    // Load saved player settings from SharedPreferences.
    await _loadPlayerPrefs();
    
    print("DPlayer.loadData data loading completed");
  }
  
  static Future<void> _loadPlayerPrefs() async {
    print("DPlayer._loadPlayerPrefs loading player preferences");
    
    final prefs = await SharedPreferences.getInstance();
    
    // Load player stats
    coin = prefs.getInt(_prefKeyCoin) ?? 0;
    removeAd = prefs.getBool(_prefKeyRemoveAd) ?? false;
    
    // Load settings
    soundEnabled = prefs.getBool(_prefKeySoundEnabled) ?? true;
    musicEnabled = prefs.getBool(_prefKeyMusicEnabled) ?? true;
    selectedAvatarIndex = prefs.getInt(_prefKeySelectedAvatar) ?? 0;
    
    // Load or generate player ID - only generate if not exists
    playerId = prefs.getString(_prefKeyPlayerId) ?? "";
    if (playerId.isEmpty) {
      playerId = _generatePlayerId();
      // Save the newly generated ID immediately
      await prefs.setString(_prefKeyPlayerId, playerId);
      print("DPlayer._loadPlayerPrefs generated new playerId: $playerId");
    } else {
      print("DPlayer._loadPlayerPrefs loaded existing playerId: $playerId");
    }
    
    // Load current progress
    _currentEpisodeId = prefs.getString(_prefKeyCurrentEpisode) ?? 
                        (episodes.isNotEmpty ? episodes.first.id : "");
    _currentLevelIndex = prefs.getInt(_prefKeyCurrentLevel) ?? 0;
    
    print("DPlayer._loadPlayerPrefs preferences loaded successfully");
  }
  
  // Saves all player preferences
  static Future<void> savePlayerPrefs() async {
    print("DPlayer.savePlayerPrefs saving all player preferences");
    
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setInt(_prefKeyCoin, coin);
    await prefs.setBool(_prefKeyRemoveAd, removeAd);
    await prefs.setString(_prefKeyCurrentEpisode, _currentEpisodeId);
    await prefs.setInt(_prefKeyCurrentLevel, _currentLevelIndex);
    
    // Save settings
    await prefs.setBool(_prefKeySoundEnabled, soundEnabled);
    await prefs.setBool(_prefKeyMusicEnabled, musicEnabled);
    await prefs.setInt(_prefKeySelectedAvatar, selectedAvatarIndex);
    await prefs.setString(_prefKeyPlayerId, playerId);
    
    // Save progress for all levels
    for (var episode in episodes) {
      for (var level in episode.levels) {
        await level.saveProgress();
      }
    }
    
    // Save progress for daily levels
    if (levelDaily != null) {
      await levelDaily!.saveProgress();
    }
    
    print("DPlayer.savePlayerPrefs preferences saved successfully");
  }
  
  // Settings getters and setters
  static bool get isSoundEnabled => soundEnabled;
  
  static set isSoundEnabled(bool value) {
    print("DPlayer.isSoundEnabled sound setting changed to: $value");
    soundEnabled = value;
    savePlayerPrefs();
  }
  
  static bool get isMusicEnabled => musicEnabled;
  
  static set isMusicEnabled(bool value) {
    print("DPlayer.isMusicEnabled music setting changed to: $value");
    musicEnabled = value;
    savePlayerPrefs();
  }
  
  static int get currentAvatarIndex => selectedAvatarIndex;
  
  static set currentAvatarIndex(int value) {
    print("DPlayer.currentAvatarIndex avatar changed to index: $value");
    selectedAvatarIndex = value.clamp(0, Consts.listAvatars.length - 1);
    savePlayerPrefs();
  }
  
  static String get currentAvatarFileName => Consts.listAvatars[selectedAvatarIndex];
  
  static String get currentPlayerId => playerId;
  
  /// This setter is mainly for testing purposes or special cases
  /// Normal generation should happen automatically in _loadPlayerPrefs
  static set currentPlayerId(String value) {
    print("DPlayer.currentPlayerId player ID manually changed to: $value");
    playerId = value;
    savePlayerPrefs();
  }
  
  /// Force regenerate player ID (for reset or special cases)
  static Future<void> regeneratePlayerId() async {
    print("DPlayer.regeneratePlayerId regenerating player ID");
    playerId = _generatePlayerId();
    await savePlayerPrefs();
    print("DPlayer.regeneratePlayerId new playerId: $playerId");
  }
  
  // Current episode getter and setter
  static String get currentEpisodeId => _currentEpisodeId;
  
  static set currentEpisodeId(String id) {
    _currentEpisodeId = id;
    savePlayerPrefs();
  }
  
  // Current level index getter and setter
  static int get currentLevelIndex => _currentLevelIndex;
  
  static set currentLevelIndex(int index) {
    _currentLevelIndex = index;
    savePlayerPrefs();
  }
  
  // Get current level index for a specific episode
  static Future<int> currentLevelIndexOf(String episodeId) {
    final prefs = SharedPreferences.getInstance();
    return prefs.then((p) => p.getInt('$_prefKeyLevelPrefix$episodeId') ?? 0);
  }
  
  // Set current level index for a specific episode
  static Future<void> setCurrentLevelIndexOf(String episodeId, int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('$_prefKeyLevelPrefix$episodeId', index);
  }
  
  // Determine the state of an episode (READY, COMPLETED, LOCKED)
  static int getState(String episodeId) {
    try {
      // Find the episode or throw exception if not found
      final episode = episodes.firstWhere(
        (ep) => ep.id == episodeId,
        orElse: () => throw Exception('Episode with id $episodeId not found'),
      );
      
      // Debug
      print('DPlayer.getState getting state for episode: $episodeId, isCompleted: ${episode.isCompleted()}');
      print('DPlayer.getState required count: ${episode.requiredCount}');
      
      // Check if it's completed - this should be checked first
      if (episode.isCompleted()) {
        return Consts.COMPLETED;
      }
      
      // Check if it's locked
      if (episode.requiredCount > 0) {
        // Find the index of current episode
        int currentEpIndex = episodes.indexWhere((ep) => ep.id == episodeId);
        
        // If this is not the first episode, check previous episodes' completion
        if (currentEpIndex > 0) {
          // Sum up completed levels from previous episodes
          int completedLevelsCount = 0;
          
          // Sum up completed levels from previous episodes
          for (int i = 0; i < currentEpIndex; i++) {
            completedLevelsCount += episodes[i].levels
                .where((level) => level.isCompleted())
                .length;
            
            print('DPlayer.getState episode ${episodes[i].id} has ${episodes[i].levels.where((level) => level.isCompleted()).length} completed levels');
          }
          
          print('DPlayer.getState required: ${episode.requiredCount}, completed: $completedLevelsCount');
          
          if (completedLevelsCount < episode.requiredCount) {
            return Consts.LOCKED;
          }
        }
      }
      
      // If not completed and not locked, it's ready
      return Consts.READY;
    } catch (e) {
      print('DPlayer.getState error: $e');
      return Consts.READY; // Default to READY to avoid crashing
    }
  }
  
  // Get total level count in the game
  static int get levelCount =>
      episodes.fold(0, (sum, ep) => sum + ep.levels.length);

  // Get total completed level count
  static int get levelCompletedCount => episodes.fold(
      0, (sum, ep) => sum + ep.levels.where((lvl) => lvl.isCompleted()).length);

  // Get game completion ratio
  static double get gameCompleteRatio =>
      (levelCompletedCount / levelCount).clamp(0.0, 1.0);

  // Get completed level count for a specific episode
  static int getLevelCountOfEpisode(String id) {
    final episode = episodes.firstWhere(
      (ep) => ep.id == id,
      orElse: () => throw Exception('Episode with id $id not found'),
    );
    return episode.levels.where((level) => level.isCompleted()).length;
  }
  
  // Get progress percentage of an episode
  static int getEpisodeProgress(String id) {
    final episode = episodes.firstWhere(
      (ep) => ep.id == id,
      orElse: () => throw Exception('Episode with id $id not found'),
    );
    
    if (episode.levels.isEmpty) return 0;
    
    // Calculate progress based on the sum of each level's progress
    double totalProgress = 0;
    for (var level in episode.levels) {
      totalProgress += level.currentIndex / level.answers.length;
    }
    
    // Convert to percentage
    int progressPercent = ((totalProgress / episode.levels.length) * 100).round();
    return progressPercent.clamp(0, 100);
  }
  
  // ========== DAILY MISSION METHODS ==========
  
  /// Check if daily mission is completed for today
  static bool isDailyMissionCompletedToday() {
    if (levelDaily == null) {
      print('{DPlayer.isDailyMissionCompletedToday} false (no level daily)');
      return false;
    }
    
    // Check if player has completed at least one mission today (any progress means completed for today)
    final hasProgress = levelDaily!.currentIndex > 0;
    print('{DPlayer.isDailyMissionCompletedToday} $hasProgress (completed ${levelDaily!.currentIndex} missions today)');
    return hasProgress;
  }
  
  /// Check if all daily missions are completed
  static bool isDailyMissionAllCompleted() {
    if (levelDaily == null || levelDaily!.answers.isEmpty) {
      print('{DPlayer.isDailyMissionAllCompleted} false (no level daily or no missions)');
      return false;
    }
    
    final allCompleted = levelDaily!.currentIndex >= levelDaily!.answers.length;
    print('{DPlayer.isDailyMissionAllCompleted} $allCompleted (completed ${levelDaily!.currentIndex}/${levelDaily!.answers.length} missions)');
    return allCompleted;
  }
  
  /// Check if current daily mission index matches the date
  static bool _isCurrentDailyMissionForDate(DateTime date) {
    // Implementation depends on how you want to associate missions with dates
    // For now, we'll use a simple approach based on saved date
    return true; // You can implement date-based mission selection here
  }
  
  /// Reset daily mission if it's a new day
  static Future<void> checkAndResetDailyMission() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now().toUtc();
    
    // Get the last reset time
    final lastResetMs = prefs.getInt(_prefKeyDailyMissionDate);
    DateTime? lastResetTime;
    if (lastResetMs != null) {
      lastResetTime = DateTime.fromMillisecondsSinceEpoch(lastResetMs);
    }
    
    print('{DPlayer.checkAndResetDailyMission} now=$now, lastReset=$lastResetTime');
    
    // Check if enough time has passed for reset
    bool shouldReset = false;
    if (lastResetTime == null) {
      print('{DPlayer.checkAndResetDailyMission} No previous reset time - allowing mission');
      shouldReset = false; // No reset needed, just allow mission
    } else {
      final timeSinceLastReset = now.difference(lastResetTime).inSeconds;
      shouldReset = timeSinceLastReset >= dailyResetTimeSeconds;
      print('{DPlayer.checkAndResetDailyMission} Time since last reset: ${timeSinceLastReset}s, reset needed: $shouldReset (threshold: ${dailyResetTimeSeconds}s)');
    }
    
    // Reset if needed
    if (shouldReset) {
      print('{DPlayer.checkAndResetDailyMission} Resetting daily mission progress');
      // Reset daily level progress
      if (levelDaily != null) {
        levelDaily!.currentIndex = 0;
        await levelDaily!.saveProgress();
      }
      
      // Save the new reset time
      await prefs.setInt(_prefKeyDailyMissionDate, now.millisecondsSinceEpoch);
      
      print('{DPlayer.checkAndResetDailyMission} Daily mission reset at: $now (reset interval: ${dailyResetTimeSeconds}s)');
    } else {
      print('{DPlayer.checkAndResetDailyMission} No reset needed');
    }
  }
  
  /// Check if two DateTime objects represent the same day
  static bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }
  
  /// Complete daily mission and award coins
  static Future<bool> completeDailyMission() async {
    print('{DPlayer.completeDailyMission} called');
    
    // Check if daily mission is available (no missions completed today)
    if (isDailyMissionCompletedToday()) {
      print('{DPlayer.completeDailyMission} Daily mission already completed today');
      return false; // Already completed
    }
    
    // Complete one daily mission (one picture)
    if (levelDaily != null) {
      // Player completes 1 mission today
      levelDaily!.currentIndex = 1; 
      await levelDaily!.saveProgress();
      
      // Award coins (100 coins as per UI requirements)
      coin += 100; // Daily mission reward
      await savePlayerPrefs();
      
      // Update the reset timestamp to start countdown for next mission
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now().toUtc();
      await prefs.setInt(_prefKeyDailyMissionDate, now.millisecondsSinceEpoch);
      
      print('{DPlayer.completeDailyMission} DAILY MISSION COMPLETED!');
      print('{DPlayer.completeDailyMission} Player solved 1 picture from daily level!');
      print('{DPlayer.completeDailyMission} Awarded 100 coins! Total coins: $coin');
      print('{DPlayer.completeDailyMission} Reset timestamp updated to: $now');
      print('{DPlayer.completeDailyMission} Next daily mission available in: ${dailyResetTimeSeconds} seconds');
      return true;
    }
    
    print('{DPlayer.completeDailyMission} No daily level available');
    return false;
  }
  
  /// Get the current daily mission state
  static int getDailyMissionState() {
    // Check if all missions are completed
    if (isDailyMissionAllCompleted()) {
      print('{DPlayer.getDailyMissionState} COMPLETED (all missions done)');
      return Consts.COMPLETED; // All missions completed
    }
    
    // Check if completed today (but not all missions)
    if (isDailyMissionCompletedToday()) {
      print('{DPlayer.getDailyMissionState} LOCKED (completed today, waiting for reset)');
      return Consts.LOCKED; // WAIT state (completed today, waiting for next reset)
    }
    
    print('{DPlayer.getDailyMissionState} READY (available)');
    return Consts.READY; // Ready to play
  }
  
  /// Initialize daily mission system
  static Future<void> initializeDailyMission() async {
    await checkAndResetDailyMission();
    print('{DPlayer.initializeDailyMission} Daily mission system initialized');
  }
  
  // ========== TEST METHODS FOR DAILY MISSION ==========
  
  /// Reset daily mission progress (for testing)
  static Future<void> resetDailyProgress() async {
    if (levelDaily != null) {
      levelDaily!.currentIndex = 0;
      await levelDaily!.saveProgress();
      
      // Also clear the reset timestamp so mission becomes available immediately
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefKeyDailyMissionDate);
      
      print('{DPlayer.resetDailyProgress} Daily mission progress reset to 0 and timestamp cleared');
    }
  }
  
  /// Complete all daily missions (for testing)
  static Future<void> completeDaily() async {
    if (levelDaily != null) {
      levelDaily!.currentIndex = levelDaily!.answers.length; // Complete ALL missions
      await levelDaily!.saveProgress();
      
      // Update the reset timestamp when completing missions
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now().toUtc();
      await prefs.setInt(_prefKeyDailyMissionDate, now.millisecondsSinceEpoch);
      
      print('{DPlayer.completeDaily} 🎯 All daily missions completed (${levelDaily!.answers.length}/${levelDaily!.answers.length})');
    }
  }
  
  /// Complete single daily mission step (for testing) - FIXED VERSION
  static Future<void> completeSingleDaily() async {
    print('{DPlayer.completeSingleDaily} called');
    
    if (levelDaily != null) {
      final currentIndex = levelDaily!.currentIndex;
      final totalMissions = levelDaily!.answers.length;
      
      print('{DPlayer.completeSingleDaily} Current daily level state: completed $currentIndex missions (total available: $totalMissions)');
      
      // Check if already at max
      if (currentIndex >= totalMissions) {
        print('{DPlayer.completeSingleDaily} Already completed all daily missions!');
        return;
      }
      
      // Increase mission index by 1
      levelDaily!.currentIndex = currentIndex + 1;
      await levelDaily!.saveProgress();
      
      // Award coins for progressing (100 coins as per UI requirements)
      coin += 100;
      await savePlayerPrefs();
      
      // Update the reset timestamp to start countdown for next mission
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now().toUtc();
      await prefs.setInt(_prefKeyDailyMissionDate, now.millisecondsSinceEpoch);
      
      print('{DPlayer.completeSingleDaily} DAILY MISSION STEP COMPLETED!');
      print('{DPlayer.completeSingleDaily} Progress: ${levelDaily!.currentIndex}/$totalMissions missions completed');
      print('{DPlayer.completeSingleDaily} Awarded 100 coins! Total coins: $coin');
      print('{DPlayer.completeSingleDaily} Reset timestamp updated to: $now');
      print('{DPlayer.completeSingleDaily} Next daily mission available in: ${dailyResetTimeSeconds} seconds');
      
      if (levelDaily!.currentIndex >= totalMissions) {
        print('{DPlayer.completeSingleDaily} 🎯 ALL DAILY MISSIONS COMPLETED! 🎯');
      }
    } else {
      print('{DPlayer.completeSingleDaily} No daily level available');
    }
  }
  
  /// Complete daily mission in 5 steps (for easier testing)
  static Future<void> completeDailyInFiveSteps() async {
    print('{DPlayer.completeDailyInFiveSteps} 🎯 completeDailyInFiveSteps() called');
    
    if (levelDaily != null) {
      final maxIndex = levelDaily!.answers.length;
      final stepsToComplete = (maxIndex / 5).ceil(); // Divide into 5 steps
      
      levelDaily!.currentIndex += stepsToComplete;
      if (levelDaily!.currentIndex > maxIndex) {
        levelDaily!.currentIndex = maxIndex;
      }
      
      await levelDaily!.saveProgress();
      
      print('{DPlayer.completeDailyInFiveSteps} 🎯 Progress jumped by $stepsToComplete: ${levelDaily!.currentIndex}/$maxIndex');
      
      // If completed at least one mission today, update timestamp and award coins
      if (levelDaily!.currentIndex > 0) {
        coin += 100;
        await savePlayerPrefs();
        
        // Update the reset timestamp to start countdown for next mission
        final prefs = await SharedPreferences.getInstance();
        final now = DateTime.now().toUtc();
        await prefs.setInt(_prefKeyDailyMissionDate, now.millisecondsSinceEpoch);
        
        if (levelDaily!.currentIndex >= maxIndex) {
          print('{DPlayer.completeDailyInFiveSteps} 🎯 ✅ ALL DAILY MISSIONS COMPLETED! 🎯');
        } else {
          print('{DPlayer.completeDailyInFiveSteps} 🎯 ✅ DAILY MISSION COMPLETED! 🎯');
        }
        print('{DPlayer.completeDailyInFiveSteps} 🎯 💰 Awarded 100 coins! Total coins: $coin');
        print('{DPlayer.completeDailyInFiveSteps} 🎯 📅 Reset timestamp updated to: $now');
        print('{DPlayer.completeDailyInFiveSteps} 🎯 ⏰ Next reset in: ${dailyResetTimeSeconds} seconds');
      } else {
        print('{DPlayer.completeDailyInFiveSteps} 🎯 📊 Daily mission progress: ${levelDaily!.currentIndex}/$maxIndex (${((levelDaily!.currentIndex / maxIndex) * 100).toStringAsFixed(1)}%)');
      }
    } else {
      print('{DPlayer.completeDailyInFiveSteps} 🎯 ❌ No daily level available');
    }
  }
  
  /// Get the current daily reset time in seconds
  static int get dailyResetTimeSeconds => _testDailyResetTimeSeconds ?? Consts.DAILY_RESET_TIME_SECONDS;
  
  /// Set test daily reset time (for testing purposes)
  static void setTestDailyResetTime(int seconds) {
    _testDailyResetTimeSeconds = seconds;
    print('{DPlayer.setTestDailyResetTime} Test daily reset time set to: ${seconds}s');
  }
  
  /// Reset test daily reset time to default
  static void resetTestDailyResetTime() {
    _testDailyResetTimeSeconds = null;
    print('{DPlayer.resetTestDailyResetTime} Reset time restored to default: ${Consts.DAILY_RESET_TIME_SECONDS}s');
  }
}