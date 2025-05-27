import 'package:flutter/material.dart';

import '../../../data/models/d_episode.dart';

/// Temporary placeholder screen for episode levels
/// This is a minimal implementation just to make the navigation work
class EpisodeLevelView extends StatelessWidget {
  /// The selected episode
  final DEpisode episode;

  const EpisodeLevelView({
    Key? key,
    required this.episode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6F7FB),
      appBar: AppBar(
        title: Text(episode.name),
        backgroundColor: const Color(0xFFD0F7FE),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'This is a placeholder for ${episode.name}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Episode description: ${episode.desc}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Back to Episodes"),
            ),
          ],
        ),
      ),
    );
  }
}