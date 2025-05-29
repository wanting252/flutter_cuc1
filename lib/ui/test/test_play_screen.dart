import 'package:flutter/material.dart';
import 'package:claude_cuc/config/const.dart';
import 'package:claude_cuc/data/models/d_player.dart';
import 'package:claude_cuc/data/models/d_mission.dart';
import 'package:claude_cuc/ui/screens/play_screen.dart';
import 'package:claude_cuc/ui/widgets/inner_shadow_button.dart';

/// Enhanced test screen to demonstrate the play screen functionality
/// with mission state management and debugging tools
class TestPlayScreen extends StatefulWidget {
  const TestPlayScreen({Key? key}) : super(key: key);

  @override
  State<TestPlayScreen> createState() => _TestPlayScreenState();
}

class _TestPlayScreenState extends State<TestPlayScreen> {
  @override
  void initState() {
    super.initState();
    _checkDataLoading();
  }
  
  void _checkDataLoading() {
    // Check if data is loaded, if not show loading state
    if (DPlayer.episodes.isEmpty) {
      // Data might still be loading
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if we have episodes loaded
    if (DPlayer.episodes.isEmpty) {
      return Scaffold(
        backgroundColor: Consts.mainBackgroundColor,
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 16),
              Text(
                'Loading game data...',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ],
          ),
        ),
      );
    }

    // Get the first episode and level for testing
    final firstEpisode = DPlayer.episodes.first;
    final levels = firstEpisode.levels;

    if (levels.isEmpty) {
      return Scaffold(
        backgroundColor: Consts.mainBackgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.white),
              const SizedBox(height: 16),
              const Text(
                'No levels found in first episode',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Reload data
                  DPlayer.loadData().then((_) {
                    if (mounted) setState(() {});
                  });
                },
                child: const Text('Reload Data'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Consts.mainBackgroundColor,
      appBar: AppBar(
        title: const Text('Play Screen Test'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(Consts.getSpacing(context, 24.0)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Player stats section
            _buildPlayerStatsSection(context),
            
            SizedBox(height: Consts.getSpacing(context, 32.0)),
            
            // Episode info section
            _buildEpisodeInfoSection(context, firstEpisode),
            
            SizedBox(height: Consts.getSpacing(context, 32.0)),
            
            // Levels section
            _buildLevelsSection(context, firstEpisode, levels),
            
            SizedBox(height: Consts.getSpacing(context, 32.0)),
            
            // Debug controls section
            _buildDebugControlsSection(context),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPlayerStatsSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Consts.getSpacing(context, 16.0)),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(51), // 0.2 opacity
        borderRadius: BorderRadius.circular(Consts.getRadius(context, 16.0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Player Stats',
            style: TextStyle(
              color: Colors.white,
              fontSize: Consts.getFontSize(context, 48.0),
              fontFamily: Consts.FONT_TITLE,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: Consts.getSpacing(context, 16.0)),
          Text(
            'Coins: ${DPlayer.coin}',
            style: TextStyle(
              color: Colors.white,
              fontSize: Consts.getFontSize(context, 36.0),
              fontFamily: Consts.FONT_MAIN,
            ),
          ),
          Text(
            'Player ID: ${DPlayer.currentPlayerId}',
            style: TextStyle(
              color: Colors.white,
              fontSize: Consts.getFontSize(context, 32.0),
              fontFamily: Consts.FONT_MAIN,
            ),
          ),
          Text(
            'Sound: ${DPlayer.isSoundEnabled ? "ON" : "OFF"}',
            style: TextStyle(
              color: Colors.white,
              fontSize: Consts.getFontSize(context, 32.0),
              fontFamily: Consts.FONT_MAIN,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEpisodeInfoSection(BuildContext context, episode) {
    return Container(
      padding: EdgeInsets.all(Consts.getSpacing(context, 16.0)),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(51), // 0.2 opacity
        borderRadius: BorderRadius.circular(Consts.getRadius(context, 16.0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Episode: ${episode.name}',
            style: TextStyle(
              color: Colors.white,
              fontSize: Consts.getFontSize(context, 48.0),
              fontFamily: Consts.FONT_TITLE,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: Consts.getSpacing(context, 8.0)),
          Text(
            episode.description,
            style: TextStyle(
              color: Colors.white,
              fontSize: Consts.getFontSize(context, 32.0),
              fontFamily: Consts.FONT_MAIN,
            ),
          ),
          SizedBox(height: Consts.getSpacing(context, 8.0)),
          Text(
            'Progress: ${episode.progress}%',
            style: TextStyle(
              color: Colors.white,
              fontSize: Consts.getFontSize(context, 32.0),
              fontFamily: Consts.FONT_MAIN,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLevelsSection(BuildContext context, episode, levels) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Levels',
          style: TextStyle(
            color: Colors.white,
            fontSize: Consts.getFontSize(context, 48.0),
            fontFamily: Consts.FONT_TITLE,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: Consts.getSpacing(context, 16.0)),
        ...levels.map((level) => _buildLevelCard(context, episode, level)).toList(),
      ],
    );
  }
  
  Widget _buildLevelCard(BuildContext context, episode, level) {
    return Container(
      margin: EdgeInsets.only(bottom: Consts.getSpacing(context, 16.0)),
      child: InnerShadowButton(
        width: double.infinity,
        height: Consts.getDimension(context, 120.0),
        borderRadius: Consts.getRadius(context, 16.0),
        backgroundColor: Colors.white,
        shadowColor: Colors.grey.shade400,
        onPressed: () => _navigateToPlayScreen(context, episode.id, level.id),
        child: Padding(
          padding: EdgeInsets.all(Consts.getSpacing(context, 16.0)),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Level: ${level.id.toUpperCase()}',
                      style: TextStyle(
                        color: const Color(Consts.COLOR_MAIN),
                        fontSize: Consts.getFontSize(context, 36.0),
                        fontFamily: Consts.FONT_TITLE,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: Consts.getSpacing(context, 4.0)),
                    Text(
                      'Missions: ${level.currentIndex}/${level.answers.length}',
                      style: TextStyle(
                        color: const Color(Consts.COLOR_DESCRIPTION),
                        fontSize: Consts.getFontSize(context, 28.0),
                        fontFamily: Consts.FONT_MAIN,
                      ),
                    ),
                    Text(
                      'Progress: ${level.progress}%',
                      style: TextStyle(
                        color: const Color(Consts.COLOR_DESCRIPTION),
                        fontSize: Consts.getFontSize(context, 28.0),
                        fontFamily: Consts.FONT_MAIN,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.play_arrow,
                size: Consts.getDimension(context, 48.0),
                color: const Color(Consts.COLOR_MAIN),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildDebugControlsSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Consts.getSpacing(context, 16.0)),
      decoration: BoxDecoration(
        color: Colors.red.withAlpha(51), // 0.2 opacity
        borderRadius: BorderRadius.circular(Consts.getRadius(context, 16.0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Debug Controls',
            style: TextStyle(
              color: Colors.white,
              fontSize: Consts.getFontSize(context, 48.0),
              fontFamily: Consts.FONT_TITLE,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: Consts.getSpacing(context, 16.0)),
          
          Wrap(
            spacing: Consts.getSpacing(context, 12.0),
            runSpacing: Consts.getSpacing(context, 12.0),
            children: [
              _buildDebugButton(context, 'Add 100 Coins', () {
                setState(() {
                  DPlayer.coin += 100;
                });
                DPlayer.savePlayerPrefs();
              }),
              
              _buildDebugButton(context, 'Reset Progress', () async {
                await DPlayer.resetProgress();
                setState(() {});
              }),
              
              _buildDebugButton(context, 'Clear All Mission States', () async {
                await _clearAllMissionStates();
                setState(() {});
              }),
              
              _buildDebugButton(context, 'Complete Current Level', () async {
                if (DPlayer.episodes.isNotEmpty && DPlayer.episodes.first.levels.isNotEmpty) {
                  final level = DPlayer.episodes.first.levels.first;
                  level.currentIndex = level.answers.length;
                  await level.saveProgress();
                  setState(() {});
                }
              }),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildDebugButton(BuildContext context, String label, VoidCallback onPressed) {
    return InnerShadowButton(
      width: Consts.getDimension(context, 160.0),
      height: Consts.getDimension(context, 80.0),
      borderRadius: Consts.getRadius(context, 12.0),
      backgroundColor: Colors.orange,
      shadowColor: Colors.orange.shade700,
      onPressed: onPressed,
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontSize: Consts.getFontSize(context, 24.0),
          fontFamily: Consts.FONT_MAIN,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
  
  void _navigateToPlayScreen(BuildContext context, String episodeId, String levelId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlayScreen(
          episodeId: episodeId,
          levelId: levelId,
        ),
      ),
    ).then((_) {
      // Refresh the screen when returning from play screen
      if (mounted) {
        setState(() {});
      }
    });
  }
  
  Future<void> _clearAllMissionStates() async {
    for (final episode in DPlayer.episodes) {
      for (final level in episode.levels) {
        for (final mission in level.answers) {
          await mission.clearMissionState();
        }
      }
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All mission states cleared'),
        backgroundColor: Colors.green,
      ),
    );
  }
}