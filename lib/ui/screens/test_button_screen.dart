import 'package:claude_cuc/ui/widgets/image_button.dart';
import 'package:flutter/material.dart';

class TestButtonScreen extends StatefulWidget {
  const TestButtonScreen({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<TestButtonScreen> {
  final GlobalKey<ImageButtonState> buttonKey = GlobalKey<ImageButtonState>();

  void changeCharacter() {
    buttonKey.currentState?.setCharacter("B");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("Image Button Example")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ImageButton(
                key: buttonKey,
                imagePath: 'assets/button_normal.png',
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: changeCharacter,
                child: Text("Change Character"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
