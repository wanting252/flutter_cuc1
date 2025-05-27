import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:claude_cuc/config/const.dart';

// MARK: - Inner Shadow Button Implementation

class InnerShadowButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final Color backgroundColor;
  final Color shadowColor;
  final double shadowSize;
  final double dropShadowSize;
  final double borderRadius;
  final double width;
  final double height;
  final EdgeInsetsGeometry padding;
  final bool showToastOnPress;
  final bool useExactBorderRadius; // New flag to control border radius scaling
  
  const InnerShadowButton({
    Key? key,
    required this.child,
    this.onPressed,
    this.backgroundColor = const Color(0xFFd0f7fe),
    this.shadowColor = Colors.cyan,
    this.shadowSize = 5.0,
    this.dropShadowSize = 10.0,
    this.borderRadius = 16.0,
    this.width = double.infinity,
    this.height = 60.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
    this.showToastOnPress = false,
    this.useExactBorderRadius = false, // Default to false for backward compatibility
  }) : super(key: key);

  @override
  State<InnerShadowButton> createState() => _InnerShadowButtonState();
}

class _InnerShadowButtonState extends State<InnerShadowButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    // Get responsive dimensions for shadow
    final responsiveShadowSize = Consts.getDimension(context, widget.shadowSize);
    final responsiveDropShadowSize = Consts.getDimension(context, widget.dropShadowSize);
    
    // Apply border radius based on the flag
    final responsiveBorderRadius = widget.useExactBorderRadius 
        ? widget.borderRadius // Use exact value
        : Consts.getRadius(context, widget.borderRadius); // Scale based on screen size
    
    return GestureDetector(
      onTapDown: (_) {
        if (widget.onPressed != null) {
          setState(() {
            _isPressed = true;
          });
        }
      },
      onTapUp: (_) {
        if (widget.onPressed != null) {
          setState(() {
            _isPressed = false;
          });
          widget.onPressed!();
          
          if (widget.showToastOnPress) {
            Fluttertoast.showToast(
              msg: "Button pressed",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
            );
          }
        }
      },
      onTapCancel: () {
        if (widget.onPressed != null) {
          setState(() {
            _isPressed = false;
          });
        }
      },
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: Stack(
          children: [
            // Decorated bottom layer (shadow provider)
            Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                color: widget.shadowColor,
                borderRadius: BorderRadius.circular(responsiveBorderRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: responsiveDropShadowSize,
                    spreadRadius: Consts.getDimension(context, 1),
                    offset: Offset(0, Consts.getDimension(context, 4)),
                  ),
                ],
              ),
            ),
            
            // Main button (top layer)
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              height: _isPressed 
                  ? widget.height // When pressed, fill the entire height
                  : widget.height - responsiveShadowSize, // When not pressed, show the shadow
              child: Container(
                decoration: BoxDecoration(
                  color: widget.backgroundColor,
                  borderRadius: BorderRadius.circular(responsiveBorderRadius),
                ),
                padding: widget.padding,
                child: Center(child: widget.child),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// MARK: - Specialized Button Variants

class InnerShadowIconButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final Color backgroundColor;
  final Color shadowColor;
  final Color iconColor;
  final double shadowSize;
  final double dropShadowSize;
  final double size;
  final double borderRadius;
  final bool useExactBorderRadius;
  
  const InnerShadowIconButton({
    Key? key,
    required this.icon,
    this.onPressed,
    this.backgroundColor = const Color(0xFFd0f7fe),
    this.shadowColor = Colors.cyan,
    this.iconColor = const Color(0xFF345560),
    this.shadowSize = 5.0,
    this.dropShadowSize = 10.0,
    this.size = 60.0,
    this.borderRadius = 16.0,
    this.useExactBorderRadius = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InnerShadowButton(
      onPressed: onPressed,
      backgroundColor: backgroundColor,
      shadowColor: shadowColor,
      shadowSize: shadowSize,
      dropShadowSize: dropShadowSize,
      borderRadius: borderRadius,
      width: size,
      height: size,
      useExactBorderRadius: useExactBorderRadius,
      child: Icon(
        icon,
        color: iconColor,
        size: Consts.getDimension(context, size * 0.5),
      ),
    );
  }
}

class InnerShadowTextButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final Color backgroundColor;
  final Color shadowColor;
  final Color textColor;
  final double shadowSize;
  final double dropShadowSize;
  final double borderRadius;
  final double width;
  final double height;
  final double fontSize;
  final bool useExactBorderRadius;
  
  const InnerShadowTextButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.backgroundColor = const Color(0xFFd0f7fe),
    this.shadowColor = Colors.cyan,
    this.textColor = const Color(0xFF345560),
    this.shadowSize = 5.0,
    this.dropShadowSize = 10.0,
    this.borderRadius = 16.0,
    this.width = double.infinity,
    this.height = 60.0,
    this.fontSize = 18.0,
    this.useExactBorderRadius = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InnerShadowButton(
      onPressed: onPressed,
      backgroundColor: backgroundColor,
      shadowColor: shadowColor,
      shadowSize: shadowSize,
      dropShadowSize: dropShadowSize,
      borderRadius: borderRadius,
      width: width,
      height: height,
      useExactBorderRadius: useExactBorderRadius,
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: Consts.getFontSize(context, fontSize),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}