import 'package:flutter/material.dart';

class ListLevelScreen extends StatelessWidget {
  const ListLevelScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Level List Screen\n(Coming Soon)',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 24,
          color: Colors.grey,
        ),
      ),
    );
  }
}