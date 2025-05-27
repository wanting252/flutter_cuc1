import 'package:flutter/material.dart';

class LevelButton extends StatelessWidget {
  final int index;
  final String desc;
  final double progress; // 0.0 to 1.0
  final bool completed;
  final bool locked;
  final VoidCallback? onTap;

  const LevelButton({
    super.key,
    required this.index,
    required this.desc,
    required this.progress,
    required this.completed,
    required this.locked,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: locked ? null : onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 3)],
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.lightBlue.shade100,
              child: Text('${index + 1}',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                desc,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            if (completed)
              const Icon(Icons.check, color: Colors.green)
            else if (locked)
              const Icon(Icons.lock, color: Colors.grey)
            else
              Expanded(
                child: LinearProgressIndicator(value: progress),
              ),
          ],
        ),
      ),
    );
  }
}
