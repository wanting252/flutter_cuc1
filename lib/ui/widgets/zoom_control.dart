// lib/ui/widgets/zoom_control.dart
import 'package:flutter/material.dart';

class ZoomControl extends StatelessWidget {
  final int currentLevel;
  final int maxLevel;
  final VoidCallback onZoomChange;

  const ZoomControl({
    Key? key,
    required this.currentLevel,
    required this.maxLevel,
    required this.onZoomChange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onZoomChange,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.zoom_in,
              color: Colors.white,
            ),
            Text(
              '$currentLevel',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}