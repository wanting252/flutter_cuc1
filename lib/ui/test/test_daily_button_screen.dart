import 'package:flutter/material.dart';
import 'package:claude_cuc/config/const.dart';
import 'package:claude_cuc/data/models/d_player.dart';
import 'package:claude_cuc/ui/widgets/daily_button.dart';

class TestDailyButtonScreen extends StatefulWidget {
  const TestDailyButtonScreen({Key? key}) : super(key: key);

  @override
  State<TestDailyButtonScreen> createState() => _TestDailyButtonScreenState();
}

class _TestDailyButtonScreenState extends State<TestDailyButtonScreen> {
  @override
  void initState() {
    super.initState();
    // Set test daily reset time to 10 seconds for testing
    DPlayer.setTestDailyResetTime(10);
  }

  @override
  void dispose() {
    // Reset to default when leaving the screen
    DPlayer.resetTestDailyResetTime();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Button Test'),
        backgroundColor: AppColors.buttonBlue,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Color(0xFF42c0ce), // Bottom color
              Color(0xFF15d5f6), // Top color
            ],
          ),
        ),
        child: Column(
          children: [
            // Daily Button at center
            const Expanded(
              flex: 2,
              child: Center(
                child: DailyButton(),
              ),
            ),
            
            // Test buttons at bottom
            Expanded(
              flex: 1,
              child: Container(
                padding: EdgeInsets.all(Consts.getDimension(context, 20)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Info text
                    Text(
                      'Test Controls (Reset Time: 10 seconds)\nDaily missions: ${DPlayer.levelDaily?.answers.length ?? 0} total',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: Consts.getFontSize(context, 28),
                        fontFamily: Consts.FONT_MAIN,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    // Button 1: Reset Daily Progress
                    ElevatedButton(
                      onPressed: () async {
                        await DPlayer.resetDailyProgress();
                        setState(() {}); // Refresh UI
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Daily progress reset to 0')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: Consts.getDimension(context, 16)),
                      ),
                      child: Text(
                        'Reset Daily Progress',
                        style: TextStyle(
                          fontSize: Consts.getFontSize(context, 32),
                          fontFamily: Consts.FONT_MAIN,
                        ),
                      ),
                    ),
                    
                    // Button 2: Complete Daily
                    ElevatedButton(
                      onPressed: () async {
                        await DPlayer.completeDaily();
                        setState(() {}); // Refresh UI
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Daily mission completed (max)')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: Consts.getDimension(context, 16)),
                      ),
                      child: Text(
                        'Complete Daily (Max)',
                        style: TextStyle(
                          fontSize: Consts.getFontSize(context, 32),
                          fontFamily: Consts.FONT_MAIN,
                        ),
                      ),
                    ),
                    
                    // Button 3: Complete Single Daily
                    ElevatedButton(
                      onPressed: () async {
                        print('{TestDailyButtonScreen.onPressed} Button pressed: Complete Single Step');
                        print('{TestDailyButtonScreen.onPressed} Before: completed missions today=${DPlayer.levelDaily?.currentIndex ?? 0}');
                        
                        await DPlayer.completeSingleDaily();
                        
                        print('{TestDailyButtonScreen.onPressed} After: completed missions today=${DPlayer.levelDaily?.currentIndex ?? 0}');
                        print('{TestDailyButtonScreen.onPressed} isCompleted: ${DPlayer.isDailyMissionCompletedToday()}');
                        print('{TestDailyButtonScreen.onPressed} State: ${DPlayer.getDailyMissionState()}');
                        
                        // Multiple state updates to ensure timer refreshes
                        setState(() {});
                        await Future.delayed(const Duration(milliseconds: 100));
                        setState(() {});
                        await Future.delayed(const Duration(milliseconds: 100));
                        setState(() {});
                        
                        final completedToday = DPlayer.levelDaily?.currentIndex ?? 0;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Daily missions completed today: $completedToday')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: Consts.getDimension(context, 16)),
                      ),
                      child: Text(
                        'Complete Single Step',
                        style: TextStyle(
                          fontSize: Consts.getFontSize(context, 32),
                          fontFamily: Consts.FONT_MAIN,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}