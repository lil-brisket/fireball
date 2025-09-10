import 'package:flutter/material.dart';
import '../../services/theme_manager.dart';

/// A base screen widget that provides consistent theming and structure.
/// 
/// This widget ensures all screens follow the same format and use the
/// user's chosen theme from settings. It provides:
/// - Consistent app bar styling
/// - Theme-aware background gradients
/// - Standardized padding and layout
/// - Consistent loading states
/// 
/// Example:
/// ```dart
/// class MyScreen extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     return BaseScreen(
///       title: 'My Screen',
///       body: MyScreenContent(),
///     );
///   }
/// }
/// ```
class BaseScreen extends StatelessWidget {
  /// The title to display in the app bar
  final String title;
  
  /// The main content of the screen
  final Widget body;
  
  /// Optional app bar actions
  final List<Widget>? actions;
  
  /// Whether to show a back button (default: true)
  final bool showBackButton;
  
  /// Whether to center the title (default: true)
  final bool centerTitle;
  
  /// Custom app bar height
  final double? appBarHeight;
  
  /// Whether to use a gradient background
  final bool useGradientBackground;
  
  /// Custom background color (overrides gradient if set)
  final Color? backgroundColor;
  
  /// Whether to show a loading indicator
  final bool isLoading;
  
  /// Loading indicator color
  final Color? loadingColor;

  const BaseScreen({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.showBackButton = true,
    this.centerTitle = true,
    this.appBarHeight,
    this.useGradientBackground = true,
    this.backgroundColor,
    this.isLoading = false,
    this.loadingColor,
  });

  /// Builds the theme-aware background
  Widget _buildBackground(BuildContext context) {
    if (backgroundColor != null) {
      return Container(color: backgroundColor);
    }
    
    if (!useGradientBackground) {
      return Container(color: Theme.of(context).scaffoldBackgroundColor);
    }
    
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (isDark) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.grey[900]!,
              Colors.grey[850]!,
              Colors.grey[900]!,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
      );
    } else {
      return Container(
        color: Theme.of(context).scaffoldBackgroundColor,
      );
    }
  }

  /// Builds the app bar with consistent styling
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return AppBar(
      title: Text(
        title,
        style: Theme.of(context).appBarTheme.titleTextStyle?.copyWith(
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
      centerTitle: centerTitle,
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      elevation: 2,
      shadowColor: isDark ? Colors.black : Colors.grey.withOpacity(0.2),
      surfaceTintColor: Colors.transparent,
      actions: actions,
      leading: showBackButton ? null : const SizedBox.shrink(),
      flexibleSpace: null,
    );
  }

  /// Builds the loading indicator
  Widget _buildLoadingIndicator(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = loadingColor ?? (isDark ? Colors.deepPurple : Colors.deepPurple);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(color),
            strokeWidth: 3,
          ),
          const SizedBox(height: 16),
          Text(
            'Loading...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isDark ? Colors.grey[300] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Stack(
        children: [
          _buildBackground(context),
          if (isLoading)
            _buildLoadingIndicator(context)
          else
            SafeArea(
              child: body,
            ),
        ],
      ),
    );
  }
}

/// A base screen with scrollable content
class BaseScrollableScreen extends StatelessWidget {
  /// The title to display in the app bar
  final String title;
  
  /// The main content of the screen
  final Widget body;
  
  /// Optional app bar actions
  final List<Widget>? actions;
  
  /// Whether to show a back button (default: true)
  final bool showBackButton;
  
  /// Whether to center the title (default: true)
  final bool centerTitle;
  
  /// Custom padding for the scrollable content
  final EdgeInsetsGeometry? padding;
  
  /// Whether to use a gradient background
  final bool useGradientBackground;
  
  /// Custom background color (overrides gradient if set)
  final Color? backgroundColor;
  
  /// Whether to show a loading indicator
  final bool isLoading;
  
  /// Loading indicator color
  final Color? loadingColor;

  const BaseScrollableScreen({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.showBackButton = true,
    this.centerTitle = true,
    this.padding,
    this.useGradientBackground = true,
    this.backgroundColor,
    this.isLoading = false,
    this.loadingColor,
  });

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: title,
      actions: actions,
      showBackButton: showBackButton,
      centerTitle: centerTitle,
      useGradientBackground: useGradientBackground,
      backgroundColor: backgroundColor,
      isLoading: isLoading,
      loadingColor: loadingColor,
      body: SingleChildScrollView(
        padding: padding ?? const EdgeInsets.all(16.0),
        child: body,
      ),
    );
  }
}
