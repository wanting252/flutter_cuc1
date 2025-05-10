import 'package:flutter/material.dart';
import 'play_view.dart'; // Import the PlayView from your previous code
import '../../data/models/level.dart';
import '../../data/models/pack.dart';


class PackLevelsScreen extends StatelessWidget {
  final Pack pack;
  final int packIndex;

  const PackLevelsScreen({required this.pack, required this.packIndex, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pack.name),
        backgroundColor: const Color(0xFF4ECDC4),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: pack.levels.length,
        itemBuilder: (context, index) {
          Level level = pack.levels[index];
          bool isUnlocked = index == 0 || pack.levels[index - 1].isCompleted;
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: isUnlocked ? Colors.red : Colors.grey,
                  child: Text(
                    "${index + 1}",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("0/10 PICS"), // Replace with actual progress
                      SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: 0.0, // Replace with actual progress
                        backgroundColor: Colors.grey,
                        valueColor: AlwaysStoppedAnimation(Colors.orange),
                      ),
                    ],
                  ),
                ),
                if (isUnlocked)
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PlayView(level: level),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("PLAY"),
                  )
                else
                  const Icon(Icons.lock, color: Colors.red),
              ],
            ),
          );
        },
      ),
    );
  }
}