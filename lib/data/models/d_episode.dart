import 'd_level.dart';

class DEpisode {
  final String id;
  final String name;
  final String desc;
  final int requiredCount;
  int playCount;
  List<DLevel> levels = [];

  DEpisode({
    required this.id,
    required this.name,
    required this.desc,
    required this.requiredCount,
    required this.playCount,
  });

  factory DEpisode.fromJson(Map<String, dynamic> json) {
    return DEpisode(
      id: json['id'],
      name: json['name'],
      desc: json['desc'],
      requiredCount: json['requiredCount'],
      playCount: json['playCount'],
    );
  }

  bool isCompleted() => levels.every((level) => level.isCompleted());

  int required() => requiredCount;
}
