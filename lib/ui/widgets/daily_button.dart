import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:claude_cuc/config/const.dart';
import 'package:claude_cuc/data/models/d_player.dart';
import 'package:claude_cuc/core/utils/toast_utils.dart';
import 'package:claude_cuc/ui/widgets/inner_shadow_button.dart';

/// A button widget for daily challenges that shows different states
/// READY: Player can complete challenge and earn coins
/// WAIT: Player must wait for cooldown to complete
/// COMPLETE: All daily missions completed
class DailyButton extends StatefulWidget {
  /// Function to call when the button is tapped
  final VoidCallback? onTap;

  const DailyButton({
    Key? key,
    this.onTap,
  }) : super(key: key);

  @override
  State<DailyButton> createState() => _DailyButtonState();
}

class _DailyButtonState extends State<DailyButton> {
  int _currentState = Consts.READY;
  late Timer _timer;
  Duration _remainingTime = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initializeDailyButton();
    _startTimer();
    _updateRemainingTime(); // Initialize remaining time
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  /// Force refresh the timer and state (public method for external access)
  void forceRefresh() {
    print('{DailyButton.forceRefresh} Force refreshing daily button timer...');
    final oldState = _currentState;
    final oldRemainingTime = _remainingTime;
    
    _updateRemainingTime();
    setState(() {
      _currentState = DPlayer.getDailyMissionState();
    });
    
    String stateName = _currentState == Consts.READY ? "READY" : 
                     _currentState == Consts.LOCKED ? "WAIT" : 
                     _currentState == Consts.COMPLETED ? "COMPLETE" : "UNKNOWN";
    print('{DailyButton.forceRefresh} After force refresh: state=${stateName}, countdown=${_getFormattedRemainingTime()}, isCompleted=${DPlayer.isDailyMissionCompletedToday()}');
  }

  /// Initialize daily button and set up state change listener
  Future<void> _initializeDailyButton() async {
    setState(() {
      _currentState = DPlayer.getDailyMissionState();
    });
  }

  /// Start timer to update the UI every second
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        final oldState = _currentState;
        final oldRemainingTime = _remainingTime;
        
        _updateRemainingTime(); // Update remaining time
        setState(() {
          _currentState = DPlayer.getDailyMissionState();
        });
        
        // Debug print when state or time changes
        if (oldState != _currentState || oldRemainingTime != _remainingTime) {
          String stateName = _currentState == Consts.READY ? "READY" : 
                           _currentState == Consts.LOCKED ? "WAIT" : 
                           _currentState == Consts.COMPLETED ? "COMPLETE" : "UNKNOWN";
          print('{DailyButton._startTimer} State change: new state=${stateName}, current countdown=${_getFormattedRemainingTime()}, isCompleted=${DPlayer.isDailyMissionCompletedToday()}');
        }
      }
    });
  }

  /// Update remaining time asynchronously
  void _updateRemainingTime() {
    _getRemainingTimeAsync().then((duration) {
      if (mounted) {
        final oldTime = _remainingTime;
        setState(() {
          _remainingTime = duration;
        });
        
        // Debug print when time updates
        if (oldTime != _remainingTime && _remainingTime.inSeconds > 0) {
          print('{DailyButton._updateRemainingTime} Timer update: ${_getFormattedRemainingTime()}');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Calculate responsive dimensions
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonWidth = screenWidth * 0.9;
    final buttonHeight = Consts.getDimension(context, Consts.LEVEL_HEIGHT);
    
    // Calculate spacing and sizes
    final borderRadius = Consts.getRadius(context, 44);
    final iconSize = Consts.getDimension(context, 240);
    final iconLeftGap = Consts.getDimension(context, 36);
    final padding = Consts.getDimension(context, 20);
    final arrowSize = Consts.getDimension(context, 60);
    
    // Use the current state from DPlayer - this is the source of truth
    final currentState = DPlayer.getDailyMissionState();
    
    // Simple state determination based on Consts values
    final isReady = currentState == Consts.READY;
    final isWait = currentState == Consts.LOCKED;
    final isComplete = currentState == Consts.COMPLETED;
    
    // Debug current state
    String debugState = isReady ? "READY" : isWait ? "WAIT" : isComplete ? "COMPLETE" : "UNKNOWN";
    print('{DailyButton.build} Current state: ${debugState} (${currentState}), hasCompletedToday=${DPlayer.isDailyMissionCompletedToday()}, countdown=${_getFormattedRemainingTime()}');

    return InnerShadowButton(
      width: buttonWidth,
      height: buttonHeight,
      borderRadius: borderRadius,
      backgroundColor: Colors.transparent,
      shadowColor: const Color(0xFFd0f7fe),
      shadowSize: Consts.getDimension(context, 12.0),
      dropShadowSize: Consts.getDimension(context, 8.0),
      onPressed: _handleTap,
      showToastOnPress: false,
      padding: EdgeInsets.zero,
      useExactBorderRadius: true,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Color(0xFF02a3ff),
              Color(0xFF2af6cd),
            ],
          ),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Stack(
          children: [
            // Left icon (character)
            Positioned(
              left: iconLeftGap,
              top: 0,
              bottom: 0,
              width: buttonHeight * 0.8,
              child: Center(
                child: Container(
                  width: iconSize,
                  height: iconSize,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(51),
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      '${Consts.PATH_ICONS}ic_daily_avatar.png',
                      width: iconSize,
                      height: iconSize,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.person,
                          size: iconSize * 0.6,
                          color: Colors.white,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            
            // Content area (text and icons)
            Positioned(
              left: buttonHeight * 0.8 + padding,
              right: padding,
              top: 0,
              bottom: 0,
              child: isReady 
                ? _buildReadyContent(context) 
                : isWait 
                  ? _buildWaitContent(context)
                  : _buildCompleteContent(context),
            ),
            
            // Right arrow (only for READY state)
            if (isReady)
              Positioned(
                right: Consts.getDimension(context, 62),
                top: 0,
                bottom: 0,
                child: Center(
                  child: Image.asset(
                    '${Consts.PATH_ICONS}ic_state_ready.png',
                    width: arrowSize,
                    height: arrowSize,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.arrow_forward_ios,
                        size: arrowSize,
                        color: Colors.white,
                      );
                    },
                  ),
                ),
              ),
            
            // Right locked icon (only for WAIT state)
            if (isWait)
              Positioned(
                right: Consts.getDimension(context, 62),
                top: 0,
                bottom: 0,
                child: Center(
                  child: Image.asset(
                    '${Consts.PATH_ICONS}ic_state_locked.png',
                    width: arrowSize,
                    height: arrowSize,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.lock,
                        size: arrowSize,
                        color: Colors.orange,
                      );
                    },
                  ),
                ),
              ),
            
            // Right completed icon (only for COMPLETE state)
            if (isComplete)
              Positioned(
                right: Consts.getDimension(context, 62),
                top: 0,
                bottom: 0,
                child: Center(
                  child: Image.asset(
                    '${Consts.PATH_ICONS}ic_state_completed.png',
                    width: arrowSize,
                    height: arrowSize,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.check_circle,
                        size: arrowSize,
                        color: Colors.green,
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Build content for READY state
  Widget _buildReadyContent(BuildContext context) {
    final avatarGap = Consts.getDimension(context, 45);
    
    return Row(
      children: [
        SizedBox(width: avatarGap),
        Expanded(
          child: Text(
            'Complete daily challenge\nand earn 100 coins!', // Fixed: Changed from 200 to 100 coins
            style: TextStyle(
              color: Colors.white,
              fontSize: Consts.getFontSize(context, 38), // Fixed: Changed from 48 to 38
              fontFamily: Consts.FONT_MAIN,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
        ),
        SizedBox(width: Consts.getDimension(context, 62 + 60)),
      ],
    );
  }

  /// Build content for WAIT state
  Widget _buildWaitContent(BuildContext context) {
    final remainingTime = _getFormattedRemainingTime();
    final clockSize = Consts.getDimension(context, 120);
    final avatarGap = Consts.getDimension(context, 45);
    
    return Row(
      children: [
        SizedBox(width: avatarGap),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Clock icon
              Image.asset(
                '${Consts.PATH_ICONS}ic_daily_clock.png',
                width: clockSize,
                height: clockSize,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.access_time,
                    size: clockSize,
                    color: Colors.white,
                  );
                },
              ),
              
              SizedBox(width: Consts.getSpacing(context, 16)),
              
              // Time and text
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Time display
                  Text(
                    remainingTime,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: Consts.getFontSize(context, 38), // Fixed: Changed from 56 to 38
                      fontFamily: Consts.FONT_MAIN,
                      fontWeight: FontWeight.bold,
                      height: 1.0,
                    ),
                  ),
                  
                  SizedBox(height: Consts.getSpacing(context, 4)),
                  
                  // "for next challenge" text
                  Text(
                    'for next challenge',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: Consts.getFontSize(context, 38), // This was already 38, keeping it
                      fontFamily: Consts.FONT_MAIN,
                      height: 1.0,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(width: Consts.getDimension(context, 62 + 60)),
      ],
    );
  }

  /// Build content for COMPLETE state
  Widget _buildCompleteContent(BuildContext context) {
    final avatarGap = Consts.getDimension(context, 45);
    
    return Row(
      children: [
        SizedBox(width: avatarGap),
        Expanded(
          child: Text(
            'All completed. New mission coming soon',
            style: TextStyle(
              color: Colors.white,
              fontSize: Consts.getFontSize(context, 38), // This was already 38, keeping it
              fontFamily: Consts.FONT_MAIN,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
        ),
        SizedBox(width: Consts.getDimension(context, 62 + 60)),
      ],
    );
  }

  /// Handle tap action based on current state
  void _handleTap() {
    if (widget.onTap != null) {
      widget.onTap!();
      return;
    }
    
    final currentState = DPlayer.getDailyMissionState();
    
    if (currentState == Consts.READY) {
      // READY state - show play screen (for now just complete the mission)
      DPlayer.completeDailyMission().then((success) {
        if (success) {
          ToastUtils.showSuccess("Daily challenge completed! You earned 100 coins!"); // Fixed: Changed from 200 to 100 coins
          
          // Force immediate timer update to start countdown
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) {
              _updateRemainingTime();
              setState(() {
                _currentState = DPlayer.getDailyMissionState();
              });
            }
          });
        } else {
          ToastUtils.showError("Cannot complete daily challenge right now");
        }
      });
    } else if (currentState == Consts.COMPLETED) {
      // COMPLETE state - all missions completed
      ToastUtils.showInfo("All completed. New mission coming soon!");
    } else {
      // WAIT state (LOCKED) - waiting for next day
      ToastUtils.showWarning("Today mission not ready!");
    }
  }

  /// Get remaining time until next daily mission reset (async version)
  Future<Duration> _getRemainingTimeAsync() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastResetMs = prefs.getInt('daily_mission_date');
      
      if (lastResetMs == null) {
        print('🔍 No reset time recorded, mission available');
        return Duration.zero;
      }
      
      final lastResetTime = DateTime.fromMillisecondsSinceEpoch(lastResetMs);
      final now = DateTime.now().toUtc();
      final nextResetTime = lastResetTime.add(Duration(seconds: DPlayer.dailyResetTimeSeconds));
      
      print('🔍 Timer check: now=$now, lastReset=$lastResetTime, nextReset=$nextResetTime');
      
      // Always show countdown if mission is completed
      if (DPlayer.isDailyMissionCompletedToday()) {
        if (now.isBefore(nextResetTime)) {
          final remaining = nextResetTime.difference(now);
          print('🔍 Mission completed, remaining time: ${remaining.inSeconds}s');
          return remaining;
        } else {
          // Reset time has passed, trigger reset check
          print('🔍 Reset time passed for completed mission, triggering reset check');
          await DPlayer.checkAndResetDailyMission();
          return Duration.zero;
        }
      } else {
        // Mission not completed - don't trigger reset, just check if available
        if (now.isBefore(nextResetTime)) {
          // Still within the current period, mission should be available
          print('🔍 Mission available (within current period)');
          return Duration.zero;
        } else {
          // Time has passed but mission not completed - this shouldn't happen in normal flow
          print('🔍 Time passed but mission not completed - making available');
          return Duration.zero;
        }
      }
    } catch (e) {
      print('❌ Error getting remaining time: $e');
      return Duration.zero;
    }
  }

  /// Get formatted remaining time string
  String _getFormattedRemainingTime() {
    if (_remainingTime.inSeconds <= 0) {
      return "00:00:00";
    }
    
    final hours = _remainingTime.inHours;
    final minutes = _remainingTime.inMinutes % 60;
    final seconds = _remainingTime.inSeconds % 60;
    
    return "${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }
}