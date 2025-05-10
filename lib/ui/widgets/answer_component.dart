// lib/ui/widgets/answer_component.dart
import 'package:flutter/material.dart';

class AnswerComponent extends StatelessWidget {
  final String answer;
  final List<String> selectedLetters;
  final Function(int) onLetterRemove;

  const AnswerComponent({
    Key? key,
    required this.answer,
    required this.selectedLetters,
    required this.onLetterRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(answer.length, (index) {
        bool isLetterSelected = index < selectedLetters.length;
        return GestureDetector(
          onTap: isLetterSelected ? () => onLetterRemove(index) : null,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isLetterSelected ? Colors.blue : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(4.0),
            ),
            alignment: Alignment.center,
            child: isLetterSelected
                ? Text(
              selectedLetters[index],
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            )
                : null,
          ),
        );
      }),
    );
  }
}