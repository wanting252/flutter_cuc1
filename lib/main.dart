import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:claude_cuc/data/models/d_player.dart';
import 'package:claude_cuc/ui/screens/play_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize DPlayer data
  await DPlayer.loadData();
  
  // Set up test data as requested
  if (DPlayer.episodes.isNotEmpty) {
    DPlayer.currentEpisodeId = DPlayer.episodes.first.id;
    DPlayer.currentLevelIndex = 0;
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Word Guessing Game',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'CenturyGothic',
      ),
      builder: (context, child) => ResponsiveBreakpoints.builder(
        child: child!,
        breakpoints: [
          const Breakpoint(start: 0, end: 450, name: MOBILE),
          const Breakpoint(start: 451, end: 800, name: TABLET),
          const Breakpoint(start: 801, end: 1920, name: DESKTOP),
          const Breakpoint(start: 1921, end: double.infinity, name: '4K'),
        ],
      ),
      home: const PlayScreenDirect(),
    );
  }
}

/// Direct PlayScreen test as requested
class PlayScreenDirect extends StatelessWidget {
  const PlayScreenDirect({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Check if episodes are loaded
    if (DPlayer.episodes.isEmpty) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading game data...'),
            ],
          ),
        ),
      );
    }

    // Get the first episode and level as set in main()
    final firstEpisode = DPlayer.episodes.first;
    final firstLevel = firstEpisode.levels.isNotEmpty ? firstEpisode.levels.first : null;

    if (firstLevel == null) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text('No levels found in first episode'),
            ],
          ),
        ),
      );
    }

    // Show PlayScreen directly as requested
    return PlayScreen(
      episodeId: firstEpisode.id,
      levelId: firstLevel.id,
    );
  }
}