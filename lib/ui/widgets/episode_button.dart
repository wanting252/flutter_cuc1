import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../../config/const.dart';

class EpisodeButton extends StatelessWidget {
  final String name;
  final String description;
  final double progress; // 0.0 to 1.0
  final String episodeId;
  final bool unlocked;
  final int requiredCount;
  final VoidCallback onTap;

  const EpisodeButton({
    super.key,
    required this.name,
    required this.description,
    required this.progress,
    required this.episodeId,
    required this.unlocked,
    required this.requiredCount,
    required this.onTap,
  });

  @override
Widget build(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  final buttonWidth = screenWidth * 0.9;

  // Dynamically adjust values based on screen width
  final isSmallScreen = screenWidth < 400; // e.g., Galaxy S8
  final titleFontSize = isSmallScreen ? 16.0 : 18.0;
  final descriptionFontSize = isSmallScreen ? 12.0 : 14.0;
  final progressTextFontSize = isSmallScreen ? 11.0 : 13.0;
  final progressBarWidth = isSmallScreen ? buttonWidth * 0.3 : buttonWidth * 0.4;
  final iconHeight = Const.LEVEL_HEIGHT;
  final iconWidth = iconHeight * (288 / 280);
  final iconPath = 'assets/images/ic_episode_$episodeId.png';

  return GestureDetector(
    onTap: unlocked ? onTap : null,
    child: Container(
      width: buttonWidth,
      height: Const.LEVEL_HEIGHT,
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        children: [
          // Left Icon
          SizedBox(
            height: iconHeight,
            width: iconWidth,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                bottomLeft: Radius.circular(20),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ColorFiltered(
                    colorFilter: unlocked
                        ? const ColorFilter.mode(Colors.transparent, BlendMode.multiply)
                        : const ColorFilter.mode(Colors.grey, BlendMode.saturation),
                    child: Image.asset(iconPath, fit: BoxFit.cover),
                  ),
                  if (!unlocked)
                    const Icon(Icons.lock, size: 40, color: Colors.white),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Text and Progress
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 10, right: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: titleFontSize,
                      fontFamily: 'Futura',
                      color: const Color(0xFF00B2F2),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Description
                  Text(
                    unlocked
                        ? description
                        : 'Complete $requiredCount pics of this episode to unlock',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: descriptionFontSize,
                      color: const Color(0xff777f8c),
                    ),
                  ),
                  if (unlocked) ...[
                    const SizedBox(height: 6),
                    LinearPercentIndicator(
                      width: progressBarWidth,
                      lineHeight: 10,
                      percent: progress,
                      backgroundColor: Colors.grey.shade300,
                      progressColor: const Color(0xFF00B2F2),
                      barRadius: const Radius.circular(20),
                      padding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: progressTextFontSize,
                        fontFamily: 'CenturyGothic-Bold',
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          // Arrow icon (if unlocked)
          if (unlocked)
            Padding(
              padding: EdgeInsets.only(right: buttonWidth * 0.08),
              child: const Icon(Icons.arrow_forward_ios, size: 20, color: Colors.grey),
            ),
        ],
      ),
    ),
  );
}

}
