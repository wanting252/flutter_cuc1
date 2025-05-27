/// Constants used throughout the application
// ignore_for_file: constant_identifier_names
import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

/// App colors constants
class AppColors {
  // Background colors
  static const Color backgroundBlue = Color(0xFF33CCCC);
  static const Color statsPanelColor = Color(0xFF33BBBB);
  
  // Progress bar colors
  static const Color progressBarStart = Color(0xFFFF9500);
  static const Color progressBarEnd = Color(0xFFFFCC00);
  
  // Text colors
  static const Color primaryText = Color(0xFF444444);
  static const Color secondaryText = Color(0xFF888888);
  
  // Button colors
  static const Color buttonBlue = Color(0xFF00CCFF);
  static const Color buttonGreen = Color(0xFF00FF99);
  
  // Locked/Unlocked colors
  static const Color lockedColor = Color(0xFFFF6600);
  static const Color unlockedColor = Color(0xFF00CC66);
  
  // Original colors from Consts
  static const Color mainText = Color(0xFF00b2f2);
  static const Color state = Color(0xFFD0F7FE);
  static const Color description = Color(0xFF777F8C);
  static const Color progressBar = Color(0xFF00A3FF);
  static const Color progressCompleted = Color(0xFF00CC66);
}

/// Game constants
class GameConstants {
  static const int totalLevels = 100;
  static const int picsToUnlockNextLevel = 20;
}

/// Original Consts class with all existing variables preserved
class Consts {
  // Episode states
  static const int READY = 1;
  static const int COMPLETED = 0;
  static const int LOCKED = -1;
  
  // UI Constants
  static const double LEVEL_HEIGHT = 300.0;
  
  // Daily Mission Constants
  static const int DAILY_RESET_TIME_SECONDS = 24 * 60 * 60; // 24 hours in seconds (86400)
  
  // Colors
  static const int COLOR_MAIN_TEXT = 0xFF00b2f2;
  static const int COLOR_STATE = 0xFFD0F7FE;
  static const int COLOR_DESCRIPTION = 0xFF777F8C;
  static const int COLOR_PROGRESS_BAR = 0xFF00A3FF;
  static const int COLOR_PROGRESS_COMPLETED = 0xFF00CC66;
  static const int COLOR_LINE_GRAY = 0xFFDCDCDC;
  
  // Main background color for the game
  static const Color mainBackgroundColor = Color(0xFF14D5F7);
  
  // Font Sizes - These are based on the mockup at 1080px width
  static const double FONT_SIZE_EPISODE_TITLE = 56.0;
  static const double FONT_SIZE_EPISODE_DESCRIPTION = 36.0;
  static const double FONT_SIZE_PROGRESS_TEXT = 36.0;
  
  // Fonts
  static const String FONT_TITLE = 'Futura';
  static const String FONT_MAIN = 'CenturyGothic';
  
  // Gaps and Spacing
  static const double GAP_ICON_MAIN_TO_TEXT = 24.0;
  static const double GAP_ICON_STATE = 24.0;
  
  // Radius
  static const double BORDER_RADIUS = 32.0;
  
  // Paths - Corrected for web compatibility
  static const String PATH_ICONS = 'images/';
  static const String PATH_SOUNDS = 'sounds/';
  static const String PATH_FONTS = 'fonts/';
  
  // Avatar list
  static const List<String> listAvatars = [
    "ic_avatar1.png",
    "ic_avatar2.png", 
    "ic_avatar3.png",
    "ic_avatar4.png",
    "ic_avatar5.png",
    "ic_avatar6.png",
  ];
  
  // Private constructor to prevent instantiation
  Consts._();

  /// The reference width from the mockup (1080px)
  static const double mockupWidth = 1080.0;
  
  /// The reference height from the mockup (1920px)
  static const double mockupHeight = 1920.0;
  
  /// Returns a responsive font size based on device type and screen size
  /// Prevents text from becoming too large on smaller screens
  static double getFontSize(BuildContext context, double fontSize) {
    // Calculate the scaling factor based on screen width relative to mockup width
    final screenWidth = MediaQuery.of(context).size.width;
    final scaleFactor = screenWidth / mockupWidth;
    
    // Get the breakpoint name
    final breakpointName = ResponsiveBreakpoints.of(context).breakpoint.name;
    
    
    // Apply device-specific scaling adjustments
    switch (breakpointName) {
      case MOBILE:
        // For mobile devices, use a more aggressive scaling down
        // to prevent text from becoming too large
        
        // For very small screens (< 400px), use even more constraints
        if (screenWidth < 400) {
          return fontSize * 0.35; // Fixed multiplier for very small screens
        }
        
        // For regular mobile screens, use constrained scaling
        return fontSize * (scaleFactor * 0.65).clamp(0.35, 0.5);
        
      case TABLET:
        // For tablets, use slightly reduced scaling
        return fontSize * (scaleFactor * 0.8).clamp(0.5, 0.75);
        
      case DESKTOP:
        // For desktop, use a more standard scaling approach
        return fontSize * scaleFactor.clamp(0.6, 1.0);
        
      case '4K':
        // For very large screens, prevent text from becoming too large
        return fontSize * scaleFactor.clamp(0.8, 1.2);
        
      default:
        // Fallback scaling that should work reasonably well
        return fontSize * 0.5;
    }
  }
  
  /// Returns a responsive dimension (width or height) based on screen width
  static double getDimension(BuildContext context, double dimension) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scaleFactor = screenWidth / mockupWidth;
    
    // Apply a minimum scale factor to prevent elements from becoming too small
    final minScaleFactor = 0.3;
    final effectiveScaleFactor = scaleFactor < minScaleFactor ? minScaleFactor : scaleFactor;
    
    return dimension * effectiveScaleFactor;
  }
  
  /// Returns a responsive spacing value based on screen width
  static double getSpacing(BuildContext context, double spacing) {
    return getDimension(context, spacing);
  }
  
  /// Returns a responsive radius value based on screen width
  static double getRadius(BuildContext context, double radius) {
    return getDimension(context, radius);
  }
  
  /// Returns a responsive height value based on screen width
  /// This maintains aspect ratio based on the original mockup
  static double getHeight(BuildContext context, double height) {
    return getDimension(context, height);
  }
  
  /// Applies responsive scaling to a TextStyle
  static TextStyle getResponsiveTextStyle(
    BuildContext context, {
    required Color color,
    required double fontSize,
    required String fontFamily,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
  }) {
    return TextStyle(
      color: color,
      fontSize: getFontSize(context, fontSize),
      fontFamily: fontFamily,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      height: 1.0, // Add a fixed line height to ensure consistency
    );
  }
}

/// Additional responsive utility functions
class ResponsiveUtil {
  static double scaleFontSize(BuildContext context, double baseFontSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 360) {
      return baseFontSize * 0.7;
    } else if (screenWidth < 480) {
      return baseFontSize * 0.8;
    } else {
      return baseFontSize;
    }
  }
  
  static double scaleIconSize(BuildContext context, double baseIconSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 360) {
      return baseIconSize * 0.7;
    } else if (screenWidth < 480) {
      return baseIconSize * 0.8;
    } else {
      return baseIconSize;
    }
  }
  
  static EdgeInsets scalePadding(BuildContext context, EdgeInsets basePadding) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 360) {
      return basePadding * 0.7;
    } else if (screenWidth < 480) {
      return basePadding * 0.8;
    } else {
      return basePadding;
    }
  }
}