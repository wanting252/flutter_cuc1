import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/pack.dart';
import 'pack_levels_screen.dart';
import 'settings_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  int totalPicsSolved = 0;
  double gameCompletion = 0.0;
  int coins = 0;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      totalPicsSolved = prefs.getInt('totalPicsSolved') ?? 0;
      coins = prefs.getInt('coins') ?? 0;
      gameCompletion = (totalPicsSolved / (packs.length * 30)) * 100;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6F0FA), // Light blue background
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "CLOSE UP PICS",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings, color: Colors.white),
                      onPressed: () {
                        // Navigate to settings screen (to be implemented)
                      },
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF4ECDC4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      "$totalPicsSolved PICS SOLVED",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "${gameCompletion.toStringAsFixed(1)}% GAME COMPLETED",
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: gameCompletion / 100,
                      backgroundColor: Colors.white,
                      valueColor: const AlwaysStoppedAnimation(Colors.orange),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "You're better than:\n82.2% players!",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
              // Daily Challenge Section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: const Text(
                  "Daily Challenge",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4ECDC4), Color(0xFF45B7D1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.person, size: 40, color: Colors.white),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        "Click to guess\nand earn 100 coins!",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const Icon(Icons.arrow_forward, color: Colors.white),
                  ],
                ),
              ),
              // Choose Game Pack Section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "Choose game pack",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ...packs.asMap().entries.map((entry) {
                int index = entry.key;
                Pack pack = entry.value;
                bool isUnlocked = totalPicsSolved >= pack.unlockRequirement;
                return GestureDetector(
                  onTap: isUnlocked
                      ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PackLevelsScreen(pack: pack, packIndex: index),
                      ),
                    );
                  }
                      : null,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                        Container(
                          width: 50,
                          height: 50,
                          color: isUnlocked ? Colors.red : Colors.grey,
                          child: const Icon(Icons.person, color: Colors.white),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                pack.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              if (isUnlocked)
                                Column(
                                  children: [
                                    LinearProgressIndicator(
                                      value: 0.03, // Replace with actual progress
                                      backgroundColor: Colors.grey[300],
                                      valueColor: const AlwaysStoppedAnimation(Color(0xFF4ECDC4)),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text("3% completed"),
                                  ],
                                )
                              else
                                Text("${pack.unlockRequirement} pics to unlock"),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward, color: Color(0xFF4ECDC4)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}