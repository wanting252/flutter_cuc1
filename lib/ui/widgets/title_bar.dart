import 'package:flutter/material.dart';
import 'package:claude_cuc/config/const.dart';

/// A reusable title bar widget for screens like Settings, Shop, etc.
/// Displays a back button, title text, and optional action button
class TitleBar extends StatelessWidget {
  /// The title text to display
  final String title;
  
  /// Callback when back button is pressed
  final VoidCallback? onBackPressed;
  
  /// Optional action widget (e.g., button) on the right side
  final Widget? actionWidget;
  
  /// Background color of the title bar
  final Color backgroundColor;
  
  /// Text color for the title
  final Color textColor;

  const TitleBar({
    Key? key,
    required this.title,
    this.onBackPressed,
    this.actionWidget,
    this.backgroundColor = Consts.mainBackgroundColor,
    this.textColor = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final titleBarHeight = Consts.getDimension(context, 120.0);
    final titleFontSize = Consts.getFontSize(context, 48.0);
    final backButtonSize = titleBarHeight * 0.5; // Back button = 0.5 of titleBar height (not text)
    final horizontalPadding = Consts.getDimension(context, 24.0);
    
    return Container(
      height: titleBarHeight,
      width: double.infinity,
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            offset: Offset(0, Consts.getDimension(context, 2.0)),
            blurRadius: Consts.getDimension(context, 4.0),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Row(
            children: [
              // Back button
              GestureDetector(
                onTap: onBackPressed ?? () => Navigator.of(context).pop(),
                child: Container(
                  padding: EdgeInsets.all(Consts.getDimension(context, 8.0)),
                  child: Icon(
                    Icons.arrow_back_ios,
                    color: textColor,
                    size: backButtonSize,
                  ),
                ),
              ),
              
              // Title
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: textColor,
                    fontSize: titleFontSize,
                    fontFamily: Consts.FONT_MAIN, // Changed from FONT_TITLE to FONT_MAIN
                    fontWeight: FontWeight.bold,
                    height: 1.0,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              // Action widget or spacer
              if (actionWidget != null)
                actionWidget!
              else
                SizedBox(width: Consts.getDimension(context, 40.0)),
            ],
          ),
        ),
      ),
    );
  }
}