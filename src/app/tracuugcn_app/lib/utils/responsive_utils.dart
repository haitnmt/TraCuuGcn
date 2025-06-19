import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class ResponsiveUtils {
  /// Check if the current screen size is mobile
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < AppConstants.mobileBreakpoint;
  }

  /// Check if the current screen size is tablet or larger
  static bool isTabletOrLarger(BuildContext context) {
    return MediaQuery.of(context).size.width >= AppConstants.mobileBreakpoint;
  }

  /// Get the screen width
  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Get the screen height
  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// Get responsive padding based on screen size
  static EdgeInsets getResponsivePadding(BuildContext context) {
    return isMobile(context) 
        ? AppConstants.smallPadding 
        : AppConstants.defaultPadding;
  }

  /// Get responsive margin based on screen size
  static EdgeInsets getResponsiveMargin(BuildContext context) {
    return isMobile(context) 
        ? const EdgeInsets.all(12.0)
        : AppConstants.defaultPadding;
  }

  /// Get responsive icon size based on screen size
  static double getResponsiveIconSize(BuildContext context) {
    return isMobile(context) 
        ? AppConstants.smallIconSize 
        : AppConstants.mediumIconSize;
  }

  /// Get responsive text size based on screen size
  static double getResponsiveTextSize(BuildContext context) {
    return isMobile(context) 
        ? AppConstants.smallTextSize 
        : AppConstants.mediumTextSize;
  }
}
