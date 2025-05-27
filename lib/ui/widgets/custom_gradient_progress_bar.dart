import 'package:flutter/material.dart';
import 'package:claude_cuc/config/const.dart';

class CustomGradientProgressBar extends StatelessWidget {
  final double value;
  final double? width;
  final double height;
  final List<Color> gradientColors;
  final Color backgroundColor;
  final double borderRadius;
  final bool showPercentage;
  final double dropShadowSize;
  
  const CustomGradientProgressBar({
    Key? key,
    required this.value,
    this.width,
    this.height = 20,
    required this.gradientColors,
    required this.backgroundColor,
    this.borderRadius = 10,
    this.showPercentage = false,
    this.dropShadowSize = 4,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get responsive height for the progress bar
    final responsiveHeight = height;
    final responsiveBorderRadius = borderRadius;

    return Container(
      height: responsiveHeight,
      width: width ?? double.infinity,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(responsiveBorderRadius),
        boxShadow: dropShadowSize > 0 ? [
          BoxShadow(
            color: Colors.black.withAlpha(25), // 0.1 * 255 ≈ 25
            blurRadius: Consts.getDimension(context, dropShadowSize),
            offset: Offset(0, Consts.getDimension(context, dropShadowSize / 2)),
          ),
        ] : null,
      ),
      child: Stack(
        children: [
          // Gradient foreground
          FractionallySizedBox(
            widthFactor: value.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(responsiveBorderRadius),
              ),
            ),
          ),
          
          // Text indicator (optional)
          if (showPercentage)
            Center(
              child: Text(
                '${(value * 100).toInt()}%',
                style: Consts.getResponsiveTextStyle(
                  context,
                  color: value > 0.5 ? Colors.white : Colors.black,
                  fontSize: responsiveHeight * 0.5,
                  fontFamily: Consts.FONT_MAIN,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}