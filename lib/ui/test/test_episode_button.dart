import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:claude_cuc/data/models/d_episode.dart';
import 'package:claude_cuc/ui/widgets/episode_button.dart';
import 'package:claude_cuc/data/models/d_player.dart';
import 'package:claude_cuc/config/const.dart';

class TestEpisodeButton extends StatefulWidget {
  const TestEpisodeButton({Key? key}) : super(key: key);

  @override
  State<TestEpisodeButton> createState() => _TestEpisodeButtonState();
}

class _TestEpisodeButtonState extends State<TestEpisodeButton> {
  // Mock episodes for testing
  final List<DEpisode> _mockEpisodes = [
    DEpisode(
      id: 'starter',
      name: 'STARTER PACK',
      desc: 'starter pack for beginners',
      requiredCount: 0,
      playCount: 0,
    ),
    DEpisode(
      id: 'icon',
      name: 'ICON PACK',
      desc: 'icon pack, for intermediate',
      requiredCount: 100,
      playCount: 0,
    ),
    DEpisode(
      id: 'challenger',
      name: 'CHALLENGER PACK',
      desc: 'challenger pack, for experts',
      requiredCount: 200,
      playCount: 0,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final breakpoint = ResponsiveBreakpoints.of(context).breakpoint.name;
    final fontScale = MediaQuery.of(context).textScaleFactor;
    final dimScale = screenSize.width / Consts.mockupWidth;
    
    return Scaffold(
      backgroundColor: const Color(0xFFE0F7FF),
      appBar: AppBar(
        title: const Text('Episode Button Test'),
        centerTitle: true,
        backgroundColor: const Color(0xFF33CCCC),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Display current responsive information
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.black12,
              width: double.infinity,
              child: Column(
                children: [
                  Text(
                    'Current Breakpoint: $breakpoint',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Screen Size: ${screenSize.width.round()} x ${screenSize.height.round()}',
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            // Reset button
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: ElevatedButton(
                onPressed: () async {
                  await DPlayer.resetProgress();
                  setState(() {});
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('Reset Game Progress'),
              ),
            ),
            
            // Episode buttons
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 16),
                itemCount: _mockEpisodes.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Center(
                      child: EpisodeButton(
                        episode: _mockEpisodes[index],
                        onTap: () {
                          // Show the episode was tapped
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Tapped on ${_mockEpisodes[index].name}'),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // Debug information
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.black12,
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Responsive Information:'),
                  SizedBox(height: 4),
                  Text('Font Scale: ${fontScale.toStringAsFixed(1)}x'),
                  Text('Dimension Scale: ${dimScale.toStringAsFixed(2)}x'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}