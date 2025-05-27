import 'package:flutter/material.dart';

class EmptyButton extends StatelessWidget {

  const EmptyButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: null,
      child: Container(
  margin: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      // Drop shadow (outer shadow)
      BoxShadow(
        color: Colors.black.withAlpha(51),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
      // Inner shadow (using a custom shader)
      const BoxShadow(
        color: Color(0xFFD0F7FE),
        blurRadius: 8,
        spreadRadius: -4,
        offset: Offset(0, -2),
      ),
    ],
  ),
  child: const SizedBox(
    height: 100,
    width: 300,
  ),
)

    );
  }
}
