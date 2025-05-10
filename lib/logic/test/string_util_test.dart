import '../utils/d_string_util.dart';

class StringUtilTest {
  static void testEncode() {
    const level = 'level1';
    const answer = 'BIG FAN';

    final encoded = DStringUtil.encode(level, answer);
    print('Test Encode:');
    print('Level: $level');
    print('Answer: $answer');
    print('Encoded Filename: $encoded.png');
    print('---');
  }

  static void testDecode() {
    const fileName = 'level1___FMK^JER.png'; // Corresponds to 'BIG FAN' with Caesar +4

    final decodedLevel = DStringUtil.decodeLevel(fileName);
    final decodedAnswer = DStringUtil.decodeAnswer(fileName);

    print('Test Decode:');
    print('File: $fileName');
    print('Decoded Level: $decodedLevel');
    print('Decoded Answer: $decodedAnswer');
    print('---');
  }
}
