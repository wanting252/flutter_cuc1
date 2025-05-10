import 'd_mission.dart';

class DLevel {
  // final String id;
  final String name;
  final String icon;
  final int requiredCount;
  int currentIndex = 0;
  List<DMission> answers = [];

  DLevel({
    // required this.id,
    required this.name,
    required this.icon,
    required this.requiredCount,
  });

  factory DLevel.fromJson(Map<String, dynamic> json) {
    return DLevel(
      // id: json['id'],
      name: json['name'],
      icon: json['icon'],
      requiredCount: json['requiredCount'],
    );
  }

  int get levelCount => answers.length;

  bool isCompleted() =>
      answers.every((mission) => mission.isSolved());
}
