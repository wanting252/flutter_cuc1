import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/d_player.dart';
import '../../data/models/d_player_provider.dart';
import '../widgets/episode_button.dart';

class TestEpisodeButton extends ConsumerWidget {
  const TestEpisodeButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dPlayerAsync = ref.watch(dPlayerProvider);

    return dPlayerAsync.when(
      data: (_) {
        final episodes = DPlayer.episodes;
        return Scaffold(
          appBar: AppBar(title: const Text('Test Episode Buttons')),
          body: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: episodes.length,
            itemBuilder: (context, index) {
              final ep = episodes[index];
              return Center(
                child: EpisodeButton(
                  name: ep.name,
                  description: ep.desc,
                  progress: ep.levels.isNotEmpty
                      ? ep.levels.where((lvl) => lvl.isCompleted()).length /
                      ep.levels.length
                      : 0.0,
                  episodeId: ep.id, // Adjust as needed.
                  unlocked: DPlayer.coin >= ep.requiredCount, // Example condition.
                  requiredCount: ep.requiredCount,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Clicked ${ep.name}')),
                    );
                  },
                ),
              );
            },
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(child: Text('Error: $error')),
      ),
    );
  }
}
