class Level {
  final String imagePath;
  final String answer;
  final int packId;
  final int id = 0;
  bool isCompleted;
  Level(this.imagePath, this.answer, {this.isCompleted = false, this.packId = 0});
}
