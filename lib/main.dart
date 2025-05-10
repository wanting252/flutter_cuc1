import 'package:claude_cuc/ui/test/test_episode_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'data/models/d_player.dart';
import 'logic/test/string_util_test.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await DPlayer.loadData(); // Or any other async initialization
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Close Up Pics',
      theme: ThemeData(
        fontFamily: 'CenturyGothic',
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontWeight: FontWeight.w400),
        ), // Set global font
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFE6F0FA),
      ),
      home: const TestEpisodeButton(),
    );
  }
}
