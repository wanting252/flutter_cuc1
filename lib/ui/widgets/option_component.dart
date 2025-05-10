import 'package:flutter/material.dart';

class OptionComponent extends StatelessWidget {
  final List<String> letters;
  final List<int> selectedIndices;
  final Function(String, int) onLetterSelect;

  const OptionComponent({
    Key? key,
    required this.letters,
    required this.selectedIndices,
    required this.onLetterSelect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue.shade100,
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          // First row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(7, (index) {
              return _buildLetterButton(index);
            }),
          ),
          const SizedBox(height: 8),
          // Second row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(7, (index) {
              return _buildLetterButton(index + 7);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildLetterButton(int index) {
    bool isSelected = selectedIndices.contains(index);
    return GestureDetector(
      onTap: isSelected ? null : () => onLetterSelect(letters[index], index),
      child: Container(
        margin: const EdgeInsets.all(4.0),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected ? Colors.grey : Colors.white,
          borderRadius: BorderRadius.circular(4.0),
          border: Border.all(color: Colors.grey.shade400),
        ),
        alignment: Alignment.center,
        child: Text(
          letters[index],
          style: TextStyle(
            color: isSelected ? Colors.grey.shade400 : Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
    );
  }
}

