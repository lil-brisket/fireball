import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Manages app theme settings including light, dark, and auto modes.
/// 
/// This singleton service provides:
/// - Theme mode switching (light, dark, auto)
/// - Theme persistence using Hive storage
/// - Theme data generation for light and dark modes
/// - System theme detection for auto mode
/// 
/// Example:
/// ```dart
/// final themeManager = ThemeManager.instance;
/// await themeManager.initialize();
/// final currentTheme = themeManager.currentThemeMode;
/// ```
/// Shinobi RPG Theme Manager
/// 
/// Manages light and dark themes with shinobi-inspired colors.
/// Provides consistent theming across the entire application.
/// 
/// Color Palette:
/// - Light Mode: Crimson Red (#E53935), Steel Gray (#37474F), Light Gray (#F5F5F5), Charcoal (#212121)
/// - Dark Mode: Bright Blood Red (#EF5350), Muted Gray (#90A4AE), Near Black (#121212), Deep Gray (#1E1E1E)
/// 
/// Usage:
/// ```dart
/// final themeManager = ThemeManager.instance;
/// await themeManager.setThemeMode(ThemeMode.dark);
/// ```
class ThemeManager {
  static final ThemeManager _instance = ThemeManager._internal();
  factory ThemeManager() => _instance;
  ThemeManager._internal();

  static ThemeManager get instance => _instance;

  static const String _themeBoxName = 'theme_settings';
  static const String _themeModeKey = 'theme_mode';

  // Soft theme color constants for easy access
  static const Color _softPurple = Color(0xFF6B73FF); // Light mode primary
  static const Color _softTeal = Color(0xFF4ECDC4); // Light mode secondary
  static const Color _lightSurface = Color(0xFFF8FAFC); // Light mode surface - softer
  static const Color _lightBackground = Color(0xFFFFFFFF); // Light mode background - pure white
  static const Color _mediumText = Color(0xFF475569); // Light mode text - softer dark
  static const Color _darkGrey = Color(0xFF1A202C); // Dark mode surface
  static const Color _veryDarkGrey = Color(0xFF171923); // Dark mode background
  
  late Box<String> _themeBox;
  bool _isInitialized = false;

  /// The current theme mode
  ThemeMode _currentThemeMode = ThemeMode.light;

  /// Notifier for theme changes
  final ValueNotifier<ThemeMode> _themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);

  /// Gets the current theme mode
  ThemeMode get currentThemeMode => _currentThemeMode;

  /// Gets the theme notifier for listening to changes
  ValueNotifier<ThemeMode> get themeNotifier => _themeNotifier;

  /// Gets the current theme mode as a string
  String get currentThemeModeString {
    switch (_currentThemeMode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'Auto';
    }
  }

  /// Checks if the manager is initialized
  bool get isInitialized => _isInitialized;

  /// Initializes the theme manager and loads saved settings
  /// 
  /// This method should be called at app startup
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Open the theme settings box
    _themeBox = await Hive.openBox<String>(_themeBoxName);
    
    // Load saved theme mode
    await _loadThemeMode();
    
    _isInitialized = true;
  }

  /// Loads the saved theme mode from storage
  Future<void> _loadThemeMode() async {
    final savedTheme = _themeBox.get(_themeModeKey, defaultValue: 'Light') ?? 'Light';
    _currentThemeMode = _stringToThemeMode(savedTheme);
    _themeNotifier.value = _currentThemeMode;
  }

  /// Converts string to ThemeMode
  ThemeMode _stringToThemeMode(String themeString) {
    switch (themeString) {
      case 'Light':
        return ThemeMode.light;
      case 'Dark':
        return ThemeMode.dark;
      case 'Auto':
      default:
        return ThemeMode.system;
    }
  }

  /// Converts ThemeMode to string
  String _themeModeToString(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'Auto';
    }
  }

  /// Sets the theme mode and saves it to storage
  /// 
  /// [themeMode] The new theme mode to set
  Future<void> setThemeMode(ThemeMode themeMode) async {
    _currentThemeMode = themeMode;
    _themeNotifier.value = themeMode;
    await _themeBox.put(_themeModeKey, _themeModeToString(themeMode));
  }

  /// Sets the theme mode using a string and saves it to storage
  /// 
  /// [themeString] The theme mode as a string ('Light', 'Dark', 'Auto')
  Future<void> setThemeModeFromString(String themeString) async {
    final themeMode = _stringToThemeMode(themeString);
    await setThemeMode(themeMode);
  }

  /// Gets the light theme data - Soft and pleasant aesthetic
  ThemeData get lightTheme {
    return ThemeData(
      colorScheme: ColorScheme.light(
        primary: _softPurple, // Soft purple
        secondary: _softTeal, // Soft teal
        surface: _lightSurface, // Light surface
        background: _lightBackground, // Pure white background
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: _mediumText, // Softer text color
        onBackground: _mediumText, // Softer text color
        error: const Color(0xFFE53E3E), // Soft red
        onError: Colors.white,
        brightness: Brightness.light,
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: _lightBackground, // Pure white background
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 1,
        backgroundColor: _lightSurface, // Light surface
        foregroundColor: _mediumText, // Softer text color
        titleTextStyle: TextStyle(
          color: _mediumText, // Softer text color
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 1,
        color: _lightSurface, // Light surface
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          backgroundColor: _softPurple, // Soft purple
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _softPurple, // Soft purple
        ),
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: _mediumText, fontWeight: FontWeight.w400), // Softer text
        bodyMedium: TextStyle(color: _mediumText, fontWeight: FontWeight.w400), // Softer text
        bodySmall: TextStyle(color: _mediumText, fontWeight: FontWeight.w400), // Softer text
        titleLarge: TextStyle(color: _mediumText, fontWeight: FontWeight.w600), // Softer text
        titleMedium: TextStyle(color: _mediumText, fontWeight: FontWeight.w600), // Softer text
        titleSmall: TextStyle(color: _mediumText, fontWeight: FontWeight.w600), // Softer text
        headlineLarge: TextStyle(color: _mediumText, fontWeight: FontWeight.w700), // Softer text
        headlineMedium: TextStyle(color: _mediumText, fontWeight: FontWeight.w700), // Softer text
        headlineSmall: TextStyle(color: _mediumText, fontWeight: FontWeight.w700), // Softer text
      ),
      iconTheme: IconThemeData(
        color: _mediumText, // Softer text
      ),
    );
  }

  /// Gets the dark theme data - Soft and pleasant aesthetic
  ThemeData get darkTheme {
    return ThemeData(
      colorScheme: ColorScheme.dark(
        primary: _softPurple, // Soft purple
        secondary: _softTeal, // Soft teal
        surface: _darkGrey, // Dark grey
        background: _veryDarkGrey, // Very dark grey
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.white,
        onBackground: Colors.white,
        error: const Color(0xFFE53E3E), // Soft red
        onError: Colors.white,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: _veryDarkGrey, // Very dark grey
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 2,
        backgroundColor: _darkGrey, // Dark grey
        foregroundColor: Colors.white,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        color: _darkGrey, // Dark grey
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          backgroundColor: _softPurple, // Soft purple
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _softPurple, // Soft purple
        ),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        bodyMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        bodySmall: TextStyle(color: Color(0xFFA0AEC0), fontWeight: FontWeight.w500), // Light grey
        titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        titleMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        titleSmall: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        headlineLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        headlineSmall: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      iconTheme: const IconThemeData(
        color: Colors.white,
      ),
    );
  }

  /// Gets all available theme mode options
  List<String> get availableThemeModes => ['Light', 'Dark', 'Auto'];

  /// Gets the primary color for the current theme
  Color get primaryColor => _softPurple;

  /// Gets the secondary color for the current theme
  Color get secondaryColor => _softTeal;

  /// Gets the background color for the current theme
  Color get backgroundColor => _currentThemeMode == ThemeMode.light ? _lightBackground : _veryDarkGrey;

  /// Gets the surface color for the current theme
  Color get surfaceColor => _currentThemeMode == ThemeMode.light ? _lightSurface : _darkGrey;

  /// Gets the text color for the current theme
  Color get textColor => _currentThemeMode == ThemeMode.light ? _mediumText : Colors.white;

  /// Disposes the theme manager
  void dispose() {
    _themeBox.close();
    _isInitialized = false;
  }
}
