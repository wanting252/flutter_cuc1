import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

/// Utility class for responsive design based on a 1080x1920 mockup
class ResponsiveUtils {
  /// The reference width from the mockup (1080px)
  static const double mockupWidth = 1080.0;
  
  /// The reference height from the mockup (1920px)
  static const double mockupHeight = 1920.0;
  
  /// Returns a responsive font size based on screen width
  static double getFontSize(BuildContext context, double fontSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scaleFactor = screenWidth / mockupWidth;
    
    // Apply breakpoint-specific adjustments if needed
    final breakpointName = getBreakpointName(context);
    
    switch (breakpointName) {
      case MOBILE:
        // For small phones - adjust to ensure readability with a minimum size
        if (screenWidth < 340) {
          return fontSize * 0.7;
        }
        return fontSize * scaleFactor;
      case TABLET:
        // For tablets - prevent fonts from becoming too small with a minimum scale
        final minScaleFactor = 0.7;
        return fontSize * (scaleFactor < minScaleFactor ? minScaleFactor : scaleFactor);
      default: // 'LARGE_TABLET'
        // For large tablets - prevent fonts from becoming too large
        final maxScaleFactor = 1.2;
        return fontSize * (scaleFactor > maxScaleFactor ? maxScaleFactor : scaleFactor);
    }
  }
  
  /// Returns a responsive dimension (width or height) based on screen width
  static double getDimension(BuildContext context, double dimension) {
    final screenWidth = MediaQuery.of(context).size.width;
    return dimension * (screenWidth / mockupWidth);
  }

  /// Returns a responsive dimension based on screen height (useful for vertical spacing)
  static double getHeightDimension(BuildContext context, double dimension) {
    final screenHeight = MediaQuery.of(context).size.height;
    return dimension * (screenHeight / mockupHeight);
  }
  
  /// Returns a responsive radius value based on screen width
  static double getRadius(BuildContext context, double radius) {
    return getDimension(context, radius);
  }
  
  /// Returns responsive padding based on screen width
  static EdgeInsets getPadding(BuildContext context, EdgeInsets padding) {
    final factor = MediaQuery.of(context).size.width / mockupWidth;
    return EdgeInsets.only(
      left: padding.left * factor,
      top: padding.top * factor,
      right: padding.right * factor,
      bottom: padding.bottom * factor,
    );
  }
  
  /// Returns a responsive spacing value based on screen width
  static double getSpacing(BuildContext context, double spacing) {
    return getDimension(context, spacing);
  }
  
  /// Applies responsive scaling to a TextStyle
  static TextStyle getResponsiveTextStyle(
    BuildContext context, {
    required Color color,
    required double fontSize,
    required String fontFamily,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? height,
  }) {
    return TextStyle(
      color: color,
      fontSize: getFontSize(context, fontSize),
      fontFamily: fontFamily,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      height: height ?? 1.0, // Default line height for consistency
    );
  }
  
  /// Returns a Boolean indicating if the device is a tablet
  static bool isTablet(BuildContext context) {
    final breakpoint = getBreakpointName(context);
    return breakpoint == TABLET || breakpoint == 'LARGE_TABLET';
  }
  
  /// Returns a Boolean indicating if the device is a small mobile device
  static bool isSmallMobile(BuildContext context) {
    // Check screen width directly for more reliable detection
    return MediaQuery.of(context).size.width < 340;
  }
  
  /// Returns the current device breakpoint name with fallback
  static String? getBreakpointName(BuildContext context) {
    try {
      return ResponsiveBreakpoints.of(context).breakpoint.name;
    } catch (e) {
      // Fallback to size-based detection if ResponsiveBreakpoints isn't working
      final width = MediaQuery.of(context).size.width;
      if (width <= 390) return MOBILE;
      if (width <= 600) return TABLET;
      return 'LARGE_TABLET';
    }
  }
}