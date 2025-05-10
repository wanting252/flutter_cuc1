// lib/logic/utils/letter_mixer.dart
import 'dart:math';

class LetterMixer {
  static final Random _random = Random();
  static const String _alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

  /// Mixes the answer letters with random letters to create option letters
  /// The total number of letters will be 14 (or specified count)
  static List<String> mixLettersForOptions(String answer, {int totalCount = 14}) {
    // Remove spaces and convert to uppercase
    String cleanAnswer = answer.replaceAll(' ', '').toUpperCase();

    // Create a list from the answer letters
    List<String> answerLetters = cleanAnswer.split('');

    // Calculate how many random letters we need
    int randomLettersCount = totalCount - answerLetters.length;

    // If we need more than 0 random letters
    if (randomLettersCount > 0) {
      // Add random letters
      for (int i = 0; i < randomLettersCount; i++) {
        answerLetters.add(_getRandomLetter());
      }
    }

    // Shuffle the letters
    answerLetters.shuffle();

    return answerLetters;
  }

  /// Returns a random letter from the alphabet
  static String _getRandomLetter() {
    return _alphabet[_random.nextInt(_alphabet.length)];
  }
}