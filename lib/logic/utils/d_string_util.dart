class DStringUtil {
  static const int caesarCipherIndex = 4;

  /// Decode level name from file
  static String decodeLevel(String file) {
    final name = file.split('.').first;
    return name.split('___').first;
  }

  /// Decode answer from filename
  static String decodeAnswer(String file) {
    final name = file.split('.').first;
    final encoded = name.split('___').last;
    final decrypted = _caesarCipherDecode(encoded);
    return decrypted.replaceAll('^', ' '); // Replace ^ with space
  }

  /// Encode answer and return formatted file name (no extension)
  static String encode(String level, String answer) {
    final safeAnswer = answer.replaceAll(' ', '^'); // Replace space with ^
    final encoded = _caesarCipherEncode(safeAnswer);
    return "${level}___$encoded";
  }

  static String _caesarCipherEncode(String input) {
    return String.fromCharCodes(input.codeUnits.map((charCode) {
      if (_isLetter(charCode)) {
        int base = _isUppercase(charCode) ? 65 : 97;
        return ((charCode - base + caesarCipherIndex) % 26) + base;
      }
      return charCode;
    }));
  }

  static String _caesarCipherDecode(String input) {
    return String.fromCharCodes(input.codeUnits.map((charCode) {
      if (_isLetter(charCode)) {
        int base = _isUppercase(charCode) ? 65 : 97;
        return ((charCode - base - caesarCipherIndex + 26) % 26) + base;
      }
      return charCode;
    }));
  }

  static bool _isLetter(int code) {
    return (code >= 65 && code <= 90) || (code >= 97 && code <= 122);
  }

  static bool _isUppercase(int code) => code >= 65 && code <= 90;
}
