import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:claude_cuc/config/const.dart';
import 'package:claude_cuc/data/models/d_episode.dart';
import 'package:claude_cuc/data/models/d_player.dart';
import 'package:claude_cuc/ui/widgets/inner_shadow_button.dart';
import 'package:claude_cuc/ui/widgets/custom_gradient_progress_bar.dart';

/// A button widget that displays episode information with different states.
/// Used to display episode data and state in episode selection screen.
class EpisodeButton extends StatelessWidget {
  /// The episode data to display
  final DEpisode episode;
  
  /// Function to call when the button is tapped
  final VoidCallback? onTap;

  const EpisodeButton({
    Key? key,
    required this.episode,
    this.onTap,
  }) : super(key: key);

  /// Get the state of the episode from DPlayer
  int get currentState => DPlayer.getState(episode.id);

  @override
  Widget build(BuildContext context) {
    // Use responsive width instead of fixed percentage
    final buttonWidth = Consts.getDimension(context, Consts.mockupWidth * 0.9);
    // Use responsive height based on mockup dimensions
    final buttonHeight = Consts.getDimension(context, Consts.LEVEL_HEIGHT);
    
    // Calculate border radius as 15% of button height
    final borderRadius = buttonHeight * 0.15;
    
    // Calculate responsive spacings
    final iconToTextGap = Consts.getSpacing(context, Consts.GAP_ICON_MAIN_TO_TEXT);
    final stateIconGap = Consts.getSpacing(context, Consts.GAP_ICON_STATE);
    
    // Calculate icon sizes
    final lockIconSize = Consts.getDimension(context, 48);
    
    // Get font sizes using Consts.getFontSize for proper scaling with breakpoint adjustments
    final titleFontSize = Consts.getFontSize(context, Consts.FONT_SIZE_EPISODE_TITLE);
    final descriptionFontSize = Consts.getFontSize(context, Consts.FONT_SIZE_EPISODE_DESCRIPTION);
    final progressTextFontSize = Consts.getFontSize(context, Consts.FONT_SIZE_PROGRESS_TEXT);
    
    // Calculate if episode is locked
    final bool isLocked = currentState == Consts.LOCKED;
    final bool isCompleted = currentState == Consts.COMPLETED;
    
    // Right side icon
    final stateIcon = isLocked 
        ? const SizedBox.shrink() 
        : Positioned(
            right: stateIconGap,
            top: 0,
            bottom: 0,
            child: Center(
              child: isCompleted
                ? Image.asset(
                    '${Consts.PATH_ICONS}ic_state_completed.png',
                    width: Consts.getDimension(context, 42),
                    height: Consts.getDimension(context, 42),
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.check_circle, 
                        size: Consts.getDimension(context, 42), 
                        color: Colors.green
                      );
                    },
                  )
                : Image.asset(
                    '${Consts.PATH_ICONS}ic_state_ready.png',
                    width: Consts.getDimension(context, 42),
                    height: Consts.getDimension(context, 42),
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.arrow_forward_ios, 
                        size: Consts.getDimension(context, 42), 
                        color: Colors.blue
                      );
                    },
                  ),
            ),
          );

    return InnerShadowButton(
      width: buttonWidth,
      height: buttonHeight,
      borderRadius: borderRadius,
      backgroundColor: Colors.white,
      shadowColor: const Color(0xffd0f7fe),
      shadowSize: 12.0,
      dropShadowSize: 10.0,
      onPressed: () => _handleTap(context),
      showToastOnPress: false,
      padding: EdgeInsets.zero,
      useExactBorderRadius: true, // Use the exact border radius value without additional scaling
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Row(
          children: [
            // Image section - exactly square and with proper clipping
            Container(
              width: buttonHeight,
              height: buttonHeight,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('${Consts.PATH_ICONS}ic_episode_${episode.id}.png'),
                  fit: BoxFit.cover,
                  colorFilter: isLocked
                      ? const ColorFilter.matrix([
                          0.2126, 0.7152, 0.0722, 0, 0,
                          0.2126, 0.7152, 0.0722, 0, 0,
                          0.2126, 0.7152, 0.0722, 0, 0,
                          0, 0, 0, 1, 0,
                        ])
                      : null,
                ),
              ),
              child: isLocked
                  ? Center(
                      child: Image.asset(
                        '${Consts.PATH_ICONS}ic_locked.png',
                        width: lockIconSize,
                        height: lockIconSize,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.lock,
                            size: lockIconSize,
                            color: Colors.white,
                          );
                        },
                      ),
                    )
                  : null,
            ),
            
            // Content section
            Expanded(
              child: Stack(
                children: [
                  // Content
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      iconToTextGap,
                      0,
                      stateIconGap + Consts.getDimension(context, 42),
                      0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Episode name
                        Text(
                          episode.name,
                          style: TextStyle(
                            color: const Color(Consts.COLOR_MAIN),
                            fontSize: titleFontSize,
                            fontFamily: Consts.FONT_TITLE,
                            height: 1.0,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        
                        // Add a small gap
                        SizedBox(height: Consts.getSpacing(context, 4.0)),
                        
                        // Episode description
                        Text(
                          episode.description,
                          style: TextStyle(
                            color: const Color(Consts.COLOR_DESCRIPTION),
                            fontSize: descriptionFontSize,
                            fontFamily: Consts.FONT_MAIN,
                            fontStyle: FontStyle.italic,
                            height: 1.0,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        
                        // Add a gap before progress
                        SizedBox(height: Consts.getSpacing(context, 16.0)),
                        
                        // Progress section or unlock text
                        isLocked
                          ? Text(
                              'Complete ${episode.requiredCount} pics to unlock',
                              style: TextStyle(
                                color: const Color(Consts.COLOR_DESCRIPTION),
                                fontSize: descriptionFontSize,
                                fontFamily: Consts.FONT_MAIN,
                                fontWeight: FontWeight.bold,
                                height: 1.0,
                              ),
                            )
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: CustomGradientProgressBar(
                                    value: isCompleted ? 1.0 : _safeProgressValue(episode.id),
                                    height: Consts.getDimension(context, 16.0),
                                    gradientColors: isCompleted 
                                      ? [
                                          const Color(0xFF00CC66),
                                          const Color(0xFF00DD77),
                                        ] 
                                      : [
                                          const Color(0xFF02A3FF),
                                          const Color(0xFF2AF6CD),
                                        ],
                                    backgroundColor: const Color(0xFFE0E0E0),
                                    borderRadius: buttonHeight * 0.08,
                                  ),
                                ),
                                SizedBox(width: Consts.getSpacing(context, 8.0)),
                                Text(
                                  isCompleted ? '100%' : '${_safeProgressPercent(episode.id)}%',
                                  style: TextStyle(
                                    color: const Color(Consts.COLOR_DESCRIPTION),
                                    fontSize: progressTextFontSize,
                                    fontFamily: Consts.FONT_MAIN,
                                    fontStyle: FontStyle.italic,
                                    height: 1.0,
                                  ),
                                ),
                              ],
                            ),
                      ],
                    ),
                  ),
                  
                  // State icon overlay
                  stateIcon,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Helper method to get a safe progress value (0.0-1.0) for the progress bar
  double _safeProgressValue(String episodeId) {
    try {
      final progress = DPlayer.getEpisodeProgress(episodeId);
      
      // Handle NaN, infinity, or null values
      if (progress.isNaN || progress.isInfinite || progress < 0) {
        return 0.0;
      }
      
      return (progress / 100).clamp(0.0, 1.0);
    } catch (e) {
      debugPrint("Error calculating progress value: $e");
      return 0.0;
    }
  }
  
  /// Helper method to get a safe progress percentage (0-100) for display
  int _safeProgressPercent(String episodeId) {
    try {
      final progress = DPlayer.getEpisodeProgress(episodeId);
      
      // Handle NaN, infinity, or null values
      if (progress.isNaN || progress.isInfinite || progress < 0) {
        return 0;
      }
      
      return progress.clamp(0, 100);
    } catch (e) {
      debugPrint("Error calculating progress percentage: $e");
      return 0;
    }
  }

  /// Handles tap action based on episode state
  void _handleTap(BuildContext context) {
    if (onTap != null) {
      onTap!();
      return;
    }
    
    if (currentState == Consts.COMPLETED) {
      Fluttertoast.showToast(
        msg: "This episode is completed",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black87,
        textColor: Colors.white,
      );
    } else if (currentState == Consts.LOCKED) {
      Fluttertoast.showToast(
        msg: "Complete ${episode.requiredCount} pics to unlock this episode!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black87,
        textColor: Colors.white,
      );
    } else {
      // Set this episode as the current one
      DPlayer.currentEpisodeId = episode.id;
      
      // Show toast notification
      Fluttertoast.showToast(
        msg: "Opening episode: ${episode.name}",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black87,
        textColor: Colors.white,
      );
    }
  }
}