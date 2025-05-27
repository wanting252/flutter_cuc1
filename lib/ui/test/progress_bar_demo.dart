import 'package:claude_cuc/ui/widgets/custom_gradient_progress_bar.dart';
import 'package:flutter/material.dart';

class ProgressBarDemo extends StatefulWidget {
  const ProgressBarDemo({Key? key}) : super(key: key);

  @override
  State<ProgressBarDemo> createState() => _ProgressBarDemoState();
}

class _ProgressBarDemoState extends State<ProgressBarDemo> {
  double _progressValue1 = 0.6;
  double _progressValue2 = 0.35;
  double _progressValue3 = 0.8;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gradient Progress Bar Examples'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Basic Gradient Progress Bar',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // Example 1: Basic Gradient Linear Progress Indicator
            LinearProgressIndicator(
              value: _progressValue1,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            
            const SizedBox(height: 40),
            const Text(
              'Custom Gradient Progress Bar',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // Example 2: Custom Gradient Progress Bar
            Container(
              height: 20,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Stack(
                children: [
                  // Gradient foreground
                  FractionallySizedBox(
                    widthFactor: _progressValue2,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.blue, Colors.purple],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            const Text(
              'Advanced Gradient Progress Bar',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // Example 3: Advanced Gradient Progress Bar with Border and Text
            CustomGradientProgressBar(
              value: _progressValue3,
              height: 25,
              gradientColors: const [Color(0xFFFF8C00), Color(0xFFFF2D55)],
              backgroundColor: const Color(0xFFEEEEEE),
              borderRadius: 12,
              showPercentage: true,
            ),
            
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  // Randomly change progress values for demonstration
                  _progressValue1 = ((_progressValue1 + 0.2) % 1.0);
                  _progressValue2 = ((_progressValue2 + 0.3) % 1.0);
                  _progressValue3 = ((_progressValue3 + 0.25) % 1.0);
                });
              },
              child: const Text('Update Progress'),
            ),
          ],
        ),
      ),
    );
  }
}
