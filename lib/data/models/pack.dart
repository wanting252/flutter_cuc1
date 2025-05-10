// lib/data/models/pack.dart
import 'level.dart';

class Pack {
  final String name;
  final List<Level> levels;
  final int unlockRequirement; // Number of pics to unlock this pack
  Pack(this.name, this.levels, {this.unlockRequirement = 0});
}

// Sample data
final List<Pack> packs = [
  Pack("CLASSIC PACK", [
    Level("assets/images/pack1/level1.jpg", "BIG FAN"),
    Level("assets/images/pack1/level2.jpg", "CAR"),
    // Add more levels (30 per pack)
  ]),
  Pack("BONUS PACK", [
    Level("assets/images/pack2/level1.jpg", "DOG"),
    Level("assets/images/pack2/level2.jpg", "CAT"),
    // Add more levels
  ], unlockRequirement: 50),
  // Add more packs (up to 20)
];