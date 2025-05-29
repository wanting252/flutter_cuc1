import 'package:flutter/material.dart';
import 'package:claude_cuc/config/const.dart';
import 'package:claude_cuc/data/models/d_player.dart';

/// Coin display widget that shows the current coin count
/// Used in the top bar of game screens
class CoinDisplay extends StatelessWidget {
  final bool showBackground;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? iconColor;
  final double? fontSize;
  final EdgeInsetsGeometry? padding;
  
  const CoinDisplay({
    Key? key,
    this.showBackground = true,
    this.backgroundColor,
    this.textColor,
    this.iconColor,
    this.fontSize,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("{CoinDisplay.build} Building coin display with ${DPlayer.coin} coins");
    
    // Calculate responsive dimensions
    final displayHeight = Consts.getDimension(context, 80.0);
    final iconSize = Consts.getDimension(context, 32.0);
    final coinFontSize = fontSize ?? Consts.getFontSize(context, 36.0);
    final borderRadius = Consts.getRadius(context, 16.0);
    final horizontalPadding = Consts.getSpacing(context, 16.0);
    final iconSpacing = Consts.getSpacing(context, 8.0);
    
    // Define colors
    final bgColor = backgroundColor ?? const Color(Consts.COLOR_MAIN);
    final txtColor = textColor ?? Colors.white;
    final icnColor = iconColor ?? Colors.white;
    
    Widget coinContent = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Coin icon
        Icon(
          Icons.monetization_on,
          size: iconSize,
          color: icnColor,
        ),
        
        SizedBox(width: iconSpacing),
        
        // Coin count
        Text(
          _formatCoinCount(DPlayer.coin),
          style: TextStyle(
            color: txtColor,
            fontSize: coinFontSize,
            fontFamily: Consts.FONT_MAIN,
            fontWeight: FontWeight.bold,
            height: 1.0,
          ),
        ),
      ],
    );
    
    if (showBackground) {
      return Container(
        height: displayHeight,
        padding: padding ?? EdgeInsets.symmetric(horizontal: horizontalPadding),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(51), // 0.2 opacity
              blurRadius: Consts.getDimension(context, 4.0),
              offset: Offset(0, Consts.getDimension(context, 2.0)),
            ),
          ],
        ),
        child: Center(child: coinContent),
      );
    } else {
      return coinContent;
    }
  }
  
  /// Format coin count for display
  /// Shows abbreviated numbers for large amounts (e.g., 1.2K, 1.5M)
  String _formatCoinCount(int coins) {
    if (coins < 1000) {
      return coins.toString();
    } else if (coins < 1000000) {
      final k = coins / 1000;
      if (k == k.toInt()) {
        return '${k.toInt()}K';
      } else {
        return '${k.toStringAsFixed(1)}K';
      }
    } else if (coins < 1000000000) {
      final m = coins / 1000000;
      if (m == m.toInt()) {
        return '${m.toInt()}M';
      } else {
        return '${m.toStringAsFixed(1)}M';
      }
    } else {
      final b = coins / 1000000000;
      if (b == b.toInt()) {
        return '${b.toInt()}B';
      } else {
        return '${b.toStringAsFixed(1)}B';
      }
    }
  }
}

/// Animated coin display that shows coin changes with animation
class AnimatedCoinDisplay extends StatefulWidget {
  final bool showBackground;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? iconColor;
  final double? fontSize;
  final EdgeInsetsGeometry? padding;
  final Duration animationDuration;
  
  const AnimatedCoinDisplay({
    Key? key,
    this.showBackground = true,
    this.backgroundColor,
    this.textColor,
    this.iconColor,
    this.fontSize,
    this.padding,
    this.animationDuration = const Duration(milliseconds: 500),
  }) : super(key: key);

  @override
  State<AnimatedCoinDisplay> createState() => _AnimatedCoinDisplayState();
}

class _AnimatedCoinDisplayState extends State<AnimatedCoinDisplay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  int _previousCoinCount = 0;
  
  @override
  void initState() {
    super.initState();
    _previousCoinCount = DPlayer.coin;
    
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    // Check if coin count has changed
    if (DPlayer.coin != _previousCoinCount) {
      _previousCoinCount = DPlayer.coin;
      _animationController.forward().then((_) {
        _animationController.reverse();
      });
    }
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: CoinDisplay(
              showBackground: widget.showBackground,
              backgroundColor: widget.backgroundColor,
              textColor: widget.textColor,
              iconColor: widget.iconColor,
              fontSize: widget.fontSize,
              padding: widget.padding,
            ),
          ),
        );
      },
    );
  }
}

/// Compact coin display for smaller spaces
class CompactCoinDisplay extends StatelessWidget {
  final Color? textColor;
  final Color? iconColor;
  
  const CompactCoinDisplay({
    Key? key,
    this.textColor,
    this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CoinDisplay(
      showBackground: false,
      textColor: textColor ?? Colors.white,
      iconColor: iconColor ?? Colors.white,
      fontSize: Consts.getFontSize(context, 28.0),
    );
  }
}

/// Large coin display for main menu or achievement screens
class LargeCoinDisplay extends StatelessWidget {
  final Color? backgroundColor;
  final Color? textColor;
  final Color? iconColor;
  
  const LargeCoinDisplay({
    Key? key,
    this.backgroundColor,
    this.textColor,
    this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CoinDisplay(
      showBackground: true,
      backgroundColor: backgroundColor ?? Colors.orange,
      textColor: textColor ?? Colors.white,
      iconColor: iconColor ?? Colors.white,
      fontSize: Consts.getFontSize(context, 48.0),
      padding: EdgeInsets.symmetric(
        horizontal: Consts.getSpacing(context, 24.0),
        vertical: Consts.getSpacing(context, 12.0),
      ),
    );
  }
}