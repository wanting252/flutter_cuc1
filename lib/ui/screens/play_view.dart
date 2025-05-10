import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../data/models/level.dart';

class PlayView extends StatefulWidget {
  final Level level;
  const PlayView({required this.level, super.key});

  @override
  State<PlayView> createState() => _PlayViewState();
}

class _PlayViewState extends State<PlayView> {
  double scale = 1.0; // Initial scale (SCALE_LEVEL_1)
  final List<double> scaleLevels = [1.0, 2.0, 3.0]; // SCALE_LEVEL_1, 2, 3
  int scaleIndex = 0;
  late List<String> answerSlots; // Empty slots for answer
  late List<String> options; // 14 letters for OptionComponent
  final AudioPlayer audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    answerSlots = List.filled(widget.level.answer.replaceAll(" ", "").length, "");
    options = _generateOptions(widget.level.answer);
  }

  List<String> _generateOptions(String answer) {
    String cleanAnswer = answer.replaceAll(" ", "").toUpperCase();
    List<String> answerLetters = cleanAnswer.split("");
    List<String> randomLetters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".split("")
      ..shuffle();
    return (answerLetters + randomLetters.take(14 - answerLetters.length).toList())
      ..shuffle();
  }

  void _onLetterTapped(String letter, int index) {
    setState(() {
      for (int i = 0; i < answerSlots.length; i++) {
        if (answerSlots[i].isEmpty) {
          answerSlots[i] = letter;
          options[index] = ""; // Remove used letter
          if (_checkAnswer()) {
            audioPlayer.play(AssetSource("sounds/correct.mp3"));
          }
          break;
        }
      }
    });
  }

  bool _checkAnswer() {
    String currentAnswer = answerSlots.join();
    return currentAnswer == widget.level.answer.replaceAll(" ", "").toUpperCase();
  }

  void _toggleZoom() {
    setState(() {
      scaleIndex = (scaleIndex + 1) % scaleLevels.length;
      scale = scaleLevels[scaleIndex];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Close Up Pics")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // PictureComponent
          Transform.scale(
            scale: scale,
            child: Image.asset(widget.level.imagePath, width: 200, height: 200),
          ),
          const SizedBox(height: 20),
          // AnswerComponent
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: widget.level.answer.split("").map((char) {
              if (char == " ") return const SizedBox(width: 10);
              int index = widget.level.answer.replaceAll(" ", "").split("").indexOf(char);
              return Padding(
                padding: const EdgeInsets.all(4.0),
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(border: Border.all()),
                  child: Center(child: Text(answerSlots[index])),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          // OptionComponent
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 7,
            children: options.asMap().entries.map((entry) {
              int idx = entry.key;
              String letter = entry.value;
              return Padding(
                padding: const EdgeInsets.all(4.0),
                child: ElevatedButton(
                  onPressed: letter.isEmpty ? null : () => _onLetterTapped(letter, idx),
                  child: Text(letter),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          // Zoomed In Button
          ElevatedButton(
            onPressed: _toggleZoom,
            child: Text("Zoomed In (x${scaleLevels[scaleIndex]})"),
          ),
        ],
      ),
    );
  }
}