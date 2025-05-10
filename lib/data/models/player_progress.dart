// lib/data/models/player_progress.dart
class PlayerProgress {
  final int totalPicsSolved;
  final double gameCompletionPercentage;
  final int coins;
  final Map<int, List<int>> solvedLevels; // packId -> list of solved levelIds
  final int playerRankPercentage;

  PlayerProgress({
    this.totalPicsSolved = 0,
    this.gameCompletionPercentage = 0.0,
    this.coins = 0,
    required this.solvedLevels,
    this.playerRankPercentage = 0,
  });
}