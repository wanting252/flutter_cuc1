import 'package:flutter/material.dart';
import 'package:claude_cuc/config/const.dart';
import 'package:claude_cuc/ui/widgets/inner_shadow_button.dart';

/// Answer component that displays the answer boxes for the word guessing game
/// Players can tap filled letters to remove them
class AnswerComponent extends StatelessWidget {
  final List<String> answer;
  final Function(int)? onLetterRemoved;
  
  const AnswerComponent({
    Key? key,
    required this.answer,
    this.onLetterRemoved,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("{AnswerComponent.build} Building answer component with ${answer.length} letters");
    
    // Calculate responsive dimensions with better scaling for small screens
    final boxSize = Consts.getDimension(context, Consts.ANSWER_CELL_HEIGHT).clamp(35.0, 80.0); // Minimum 35px
    final spacing = Consts.getSpacing(context, 8.0).clamp(4.0, 12.0); // Minimum 4px spacing
    final fontSize = Consts.getFontSize(context, 32.0).clamp(16.0, 40.0); // Minimum 16px font
    final borderRadius = Consts.getRadius(context, 8.0).clamp(4.0, 12.0); // Minimum 4px radius
    
    print("{AnswerComponent.build} Calculated sizes - Box: $boxSize, Font: $fontSize, Spacing: $spacing");
    
    return Container(
      width: MediaQuery.of(context).size.width,
      child: _buildAnswerBoxes(context, boxSize, spacing, fontSize, borderRadius),
    );
  }
  
  Widget _buildAnswerBoxes(BuildContext context, double boxSize, double spacing, 
                          double fontSize, double borderRadius) {
    
    // Split answer into words for line calculation
    final words = _getWordsFromAnswer();
    final numWords = words.length;
    
    List<Widget> lines = [];
    
    if (numWords == 1) {
      // Single word - 1 line
      lines.add(_buildAnswerLine(context, answer, 0, boxSize, spacing, fontSize, borderRadius));
    } else {
      // Multiple words - split into 2 lines with approximately same number of letters
      final lineBreak = _calculateOptimalLineBreak(words);
      
      // First line
      final firstLineIndices = _getIndicesForWords(words, 0, lineBreak);
      final firstLineAnswer = firstLineIndices.map((i) => answer[i]).toList();
      lines.add(_buildAnswerLine(context, firstLineAnswer, firstLineIndices.first, boxSize, spacing, fontSize, borderRadius));
      
      // Gap between lines
      lines.add(SizedBox(height: Consts.getSpacing(context, Consts.ANSWER_CELL_GAP)));
      
      // Second line
      final secondLineIndices = _getIndicesForWords(words, lineBreak, words.length);
      final secondLineAnswer = secondLineIndices.map((i) => answer[i]).toList();
      lines.add(_buildAnswerLine(context, secondLineAnswer, secondLineIndices.first, boxSize, spacing, fontSize, borderRadius));
    }
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: lines,
    );
  }
  
  Widget _buildAnswerLine(BuildContext context, List<String> lineAnswer, int startIndex,
                         double boxSize, double spacing, double fontSize, double borderRadius) {
    
    List<Widget> boxes = [];
    
    for (int i = 0; i < lineAnswer.length; i++) {
      final letter = lineAnswer[i];
      final actualIndex = startIndex + i;
      
      if (letter == ' ') {
        // Add space between words
        boxes.add(SizedBox(width: spacing * 2));
      } else {
        boxes.add(_buildLetterBox(
          context,
          letter,
          actualIndex,
          boxSize,
          fontSize,
          borderRadius,
        ));
        
        // Add spacing between letters (except after the last one)
        if (i < lineAnswer.length - 1 && lineAnswer[i + 1] != ' ') {
          boxes.add(SizedBox(width: spacing));
        }
      }
    }
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: boxes,
    );
  }
  
  Widget _buildLetterBox(BuildContext context, String letter, int index, 
                        double boxSize, double fontSize, double borderRadius) {
    final bool isEmpty = letter.isEmpty;
    
    return InnerShadowButton(
      width: boxSize,
      height: boxSize,
      borderRadius: borderRadius,
      backgroundColor: isEmpty ? const Color(0xFFE3F2FD) : Colors.white,
      shadowColor: isEmpty ? Colors.grey.shade300 : Colors.grey.shade400,
      shadowSize: Consts.getDimension(context, 4.0),
      dropShadowSize: Consts.getDimension(context, 6.0),
      onPressed: isEmpty ? null : () => _onLetterTapped(index),
      showToastOnPress: false,
      child: Center(
        child: Text(
          isEmpty ? '' : letter,
          style: TextStyle(
            color: isEmpty ? Colors.transparent : const Color(Consts.COLOR_MAIN_TEXT),
            fontSize: fontSize,
            fontFamily: Consts.FONT_MAIN,
            fontWeight: FontWeight.bold,
            height: 1.0,
          ),
        ),
      ),
    );
  }
  
  /// Extract words from answer array (split by spaces)
  List<List<String>> _getWordsFromAnswer() {
    List<List<String>> words = [];
    List<String> currentWord = [];
    
    for (String char in answer) {
      if (char == ' ') {
        if (currentWord.isNotEmpty) {
          words.add(List.from(currentWord));
          currentWord.clear();
        }
      } else {
        currentWord.add(char);
      }
    }
    
    // Add the last word if exists
    if (currentWord.isNotEmpty) {
      words.add(currentWord);
    }
    
    return words;
  }
  
  /// Calculate optimal line break point for 2-line layout
  /// Returns the index of the word where the second line should start
  int _calculateOptimalLineBreak(List<List<String>> words) {
    final totalLetters = words.fold(0, (sum, word) => sum + word.length);
    final targetFirstLine = totalLetters ~/ 2; // Half the letters
    
    int currentLetters = 0;
    for (int i = 0; i < words.length; i++) {
      currentLetters += words[i].length;
      
      // If adding this word would exceed the target, break here
      if (currentLetters >= targetFirstLine) {
        // Ensure we don't put all words on first line
        return (i + 1).clamp(1, words.length - 1);
      }
    }
    
    // Fallback: split in the middle
    return words.length ~/ 2;
  }
  
  /// Get indices in the original answer array for specific words
  List<int> _getIndicesForWords(List<List<String>> words, int startWord, int endWord) {
    List<int> indices = [];
    int currentIndex = 0;
    
    for (int wordIndex = 0; wordIndex < words.length; wordIndex++) {
      if (wordIndex >= startWord && wordIndex < endWord) {
        // Add indices for this word
        for (int letterIndex = 0; letterIndex < words[wordIndex].length; letterIndex++) {
          indices.add(currentIndex + letterIndex);
        }
      }
      
      // Move past this word and its trailing space (if not the last word)
      currentIndex += words[wordIndex].length;
      if (wordIndex < words.length - 1) {
        currentIndex++; // Account for space
      }
    }
    
    return indices;
  }
  
  void _onLetterTapped(int index) {
    print("{AnswerComponent._onLetterTapped} Letter tapped at index $index");
    if (onLetterRemoved != null) {
      onLetterRemoved!(index);
    }
  }
}