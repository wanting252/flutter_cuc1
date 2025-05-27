import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:claude_cuc/config/const.dart';
import 'package:claude_cuc/data/models/d_episode.dart';
import 'package:claude_cuc/data/models/d_player.dart';
import 'package:claude_cuc/ui/widgets/episode_button.dart';

/// Screen showing a list of episodes
class EpisodeListScreen extends StatefulWidget {
  const EpisodeListScreen({Key? key}) : super(key: key);

  @override
  State<EpisodeListScreen> createState() => _EpisodeListScreenState();
}

class _EpisodeListScreenState extends State<EpisodeListScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGameData();
  }

  // Load game data from DPlayer
  Future<void> _loadGameData() async {
    try {
      await DPlayer.loadData();
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      Fluttertoast.showToast(
        msg: "Error loading game data: $e",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      debugPrint('Error loading game data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Episodes"),
        backgroundColor: const Color(0xFFD0F7FE),
        elevation: 0,
      ),
      body: Container(
        color: const Color(0xFFE6F7FB), // Light blue background
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                itemCount: DPlayer.episodes.length,
                itemBuilder: (context, index) {
                  final episode = DPlayer.episodes[index];
                  
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: Center(
                      child: EpisodeButton(
                        episode: episode,
                        onTap: () => _handleEpisodeTap(episode),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  // Handle episode button tap
  void _handleEpisodeTap(DEpisode episode) {
    final state = DPlayer.getState(episode.id);
    
    if (state == Consts.LOCKED) {
      Fluttertoast.showToast(
        msg: "Complete ${episode.requiredCount} pics to unlock this episode!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black87,
        textColor: Colors.white,
      );
      return;
    }
    
    // Save the current episode ID to the player
    DPlayer.currentEpisodeId = episode.id;
    DPlayer.currentLevelIndex = 0;
    
    // Use a toast for now instead of navigating
    Fluttertoast.showToast(
      msg: "Selected episode: ${episode.name}",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black87,
      textColor: Colors.white,
    );
    
    // Save the player preferences
    DPlayer.savePlayerPrefs();
    
    // Here you would navigate to the level selection screen
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => EpisodeLevelView(episode: episode),
    //   ),
    // );
  }
}