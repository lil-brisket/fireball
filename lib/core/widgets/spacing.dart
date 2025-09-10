import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// Consistent spacing widgets for the app
/// 
/// These widgets provide consistent spacing throughout the app
/// using the predefined constants from AppConstants.
/// 
/// Example:
/// ```dart
/// Column(
///   children: [
///     Text('First item'),
///     Spacing.small,
///     Text('Second item'),
///     Spacing.medium,
///     Text('Third item'),
///   ],
/// )
/// ```

class Spacing {
  // Vertical Spacing
  static const Widget small = SizedBox(height: AppConstants.smallPadding);
  static const Widget medium = SizedBox(height: AppConstants.defaultPadding);
  static const Widget large = SizedBox(height: AppConstants.largePadding);
  
  // Horizontal Spacing
  static const Widget smallHorizontal = SizedBox(width: AppConstants.smallPadding);
  static const Widget mediumHorizontal = SizedBox(width: AppConstants.defaultPadding);
  static const Widget largeHorizontal = SizedBox(width: AppConstants.largePadding);
  
  // Custom spacing
  static Widget vertical(double height) => SizedBox(height: height);
  static Widget horizontal(double width) => SizedBox(width: width);
  
  // Prevent instantiation
  const Spacing._();
}

/// Consistent padding widgets for the app
class AppPadding {
  // EdgeInsets
  static const EdgeInsets small = EdgeInsets.all(AppConstants.smallPadding);
  static const EdgeInsets medium = EdgeInsets.all(AppConstants.defaultPadding);
  static const EdgeInsets large = EdgeInsets.all(AppConstants.largePadding);
  
  // Symmetric padding
  static const EdgeInsets horizontalSmall = EdgeInsets.symmetric(horizontal: AppConstants.smallPadding);
  static const EdgeInsets horizontalMedium = EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding);
  static const EdgeInsets horizontalLarge = EdgeInsets.symmetric(horizontal: AppConstants.largePadding);
  
  static const EdgeInsets verticalSmall = EdgeInsets.symmetric(vertical: AppConstants.smallPadding);
  static const EdgeInsets verticalMedium = EdgeInsets.symmetric(vertical: AppConstants.defaultPadding);
  static const EdgeInsets verticalLarge = EdgeInsets.symmetric(vertical: AppConstants.largePadding);
  
  // Prevent instantiation
  const AppPadding._();
}

/// Consistent border radius for the app
class AppBorderRadius {
  static const BorderRadius small = BorderRadius.all(Radius.circular(4.0));
  static const BorderRadius medium = BorderRadius.all(Radius.circular(AppConstants.defaultBorderRadius));
  static const BorderRadius large = BorderRadius.all(Radius.circular(16.0));
  static const BorderRadius circular = BorderRadius.all(Radius.circular(50.0));
  
  // Custom border radius
  static BorderRadius custom(double radius) => BorderRadius.all(Radius.circular(radius));
  
  // Prevent instantiation
  const AppBorderRadius._();
}
