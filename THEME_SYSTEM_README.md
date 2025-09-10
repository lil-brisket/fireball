# 🎨 Theme System Documentation

## Overview

The Shinobi RPG app now includes a comprehensive theme system that supports light, dark, and auto (system) theme modes. The theme system is built using Flutter's Material 3 design system and provides a consistent, modern look across the entire application.

## Features

- ✅ **Light Theme**: Clean, bright interface with light colors
- ✅ **Dark Theme**: Modern dark interface with dark colors  
- ✅ **Auto Theme**: Automatically follows the system theme setting
- ✅ **Theme Persistence**: Settings are saved and restored across app restarts
- ✅ **Smooth Transitions**: Seamless theme switching with animations
- ✅ **Material 3 Design**: Uses the latest Material Design guidelines

## Architecture

### ThemeManager Service

The `ThemeManager` is a singleton service that handles all theme-related functionality:

```dart
// lib/services/theme_manager.dart
class ThemeManager {
  // Singleton instance
  static ThemeManager get instance => _instance;
  
  // Theme mode management
  ThemeMode get currentThemeMode => _currentThemeMode;
  String get currentThemeModeString => /* converts to string */;
  
  // Theme data
  ThemeData get lightTheme => /* light theme configuration */;
  ThemeData get darkTheme => /* dark theme configuration */;
  
  // Theme switching
  Future<void> setThemeMode(ThemeMode themeMode);
  Future<void> setThemeModeFromString(String themeString);
}
```

### Key Components

1. **ThemeManager Service** (`lib/services/theme_manager.dart`)
   - Manages theme state and persistence
   - Provides theme data for light and dark modes
   - Handles theme switching logic

2. **Main App Integration** (`lib/main.dart`)
   - Initializes the theme manager at startup
   - Applies theme configuration to MaterialApp
   - Supports theme mode switching

3. **Settings Screen Integration** (`lib/screens/settings_screen.dart`)
   - Provides UI for theme selection
   - Saves theme changes to persistent storage
   - Shows user feedback for theme changes

## Usage

### Basic Theme Switching

```dart
// Get the theme manager instance
final themeManager = ThemeManager.instance;

// Change theme to light mode
await themeManager.setThemeMode(ThemeMode.light);

// Change theme to dark mode
await themeManager.setThemeMode(ThemeMode.dark);

// Change theme to auto (system) mode
await themeManager.setThemeMode(ThemeMode.system);

// Change theme using string values
await themeManager.setThemeModeFromString('Light');
await themeManager.setThemeModeFromString('Dark');
await themeManager.setThemeModeFromString('Auto');
```

### Getting Current Theme

```dart
// Get current theme mode
ThemeMode currentMode = themeManager.currentThemeMode;

// Get current theme as string
String currentThemeString = themeManager.currentThemeModeString;

// Get theme data
ThemeData lightTheme = themeManager.lightTheme;
ThemeData darkTheme = themeManager.darkTheme;
```

### UI Integration

The theme system is automatically applied to the entire app through the `MaterialApp` configuration:

```dart
MaterialApp(
  title: 'Shinobi RPG',
  theme: themeManager.lightTheme,        // Light theme
  darkTheme: themeManager.darkTheme,     // Dark theme
  themeMode: themeManager.currentThemeMode, // Current mode
  home: const LandingScreen(),
)
```

## Theme Configuration

### Light Theme

The light theme uses:
- **Primary Color**: Deep Purple (Material 3 seed color)
- **Brightness**: Light
- **Surface Colors**: Light backgrounds
- **Text Colors**: Dark text on light backgrounds
- **Accent Colors**: Deep purple variants

### Dark Theme

The dark theme uses:
- **Primary Color**: Deep Purple (Material 3 seed color)
- **Brightness**: Dark
- **Surface Colors**: Dark backgrounds
- **Text Colors**: Light text on dark backgrounds
- **Accent Colors**: Deep purple variants

### Auto Theme

The auto theme automatically switches between light and dark based on the system setting:
- **System Light**: Uses light theme
- **System Dark**: Uses dark theme
- **Dynamic**: Changes automatically when system setting changes

## Storage

Theme settings are persisted using Hive storage:

- **Storage Key**: `theme_settings`
- **Theme Mode Key**: `theme_mode`
- **Default Value**: `'Auto'` (system theme)
- **Persistence**: Survives app restarts and device reboots

## Testing

### Manual Testing

1. **Settings Screen**: Navigate to Settings → Theme to change theme
2. **Theme Test App**: Run `lib/test_theme.dart` for isolated testing
3. **System Integration**: Test auto mode with system theme changes

### Test Commands

```bash
# Run the main app
flutter run

# Run theme test app
flutter run lib/test_theme.dart

# Run with specific theme
flutter run --dart-define=THEME_MODE=dark
```

## Customization

### Adding New Themes

To add a new theme (e.g., high contrast):

1. **Add Theme Data**:
```dart
ThemeData get highContrastTheme {
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.light,
    ),
    // ... other configurations
  );
}
```

2. **Update Theme Mode Enum**:
```dart
enum CustomThemeMode { light, dark, system, highContrast }
```

3. **Update UI**:
```dart
// Add new option to settings screen
RadioListTile<String>(
  title: const Text('High Contrast'),
  value: 'HighContrast',
  groupValue: _selectedTheme,
  onChanged: (value) async {
    await _changeTheme(value!);
    Navigator.of(context).pop();
  },
),
```

### Modifying Existing Themes

To modify the existing light or dark themes:

1. **Edit Theme Data** in `ThemeManager`:
```dart
ThemeData get lightTheme {
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue, // Change primary color
      brightness: Brightness.light,
    ),
    // ... other customizations
  );
}
```

2. **Add Custom Properties**:
```dart
ThemeData get lightTheme {
  return ThemeData(
    // ... existing configuration
    cardTheme: CardTheme(
      elevation: 4, // Increase elevation
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // More rounded corners
      ),
    ),
  );
}
```

## Troubleshooting

### Common Issues

1. **Theme Not Changing**:
   - Ensure `ThemeManager.instance.initialize()` is called in `main()`
   - Check that `MaterialApp` is using the theme manager
   - Verify theme changes are being saved to storage

2. **Theme Not Persisting**:
   - Check Hive initialization
   - Verify storage permissions
   - Ensure theme is being saved after changes

3. **Auto Mode Not Working**:
   - Check system theme detection
   - Verify `ThemeMode.system` is being used
   - Test on different devices/platforms

### Debug Commands

```bash
# Check theme storage
flutter run --dart-define=DEBUG_THEME=true

# Reset theme to default
flutter run --dart-define=RESET_THEME=true

# Enable theme logging
flutter run --dart-define=THEME_LOGGING=true
```

## Future Enhancements

### Planned Features

- 🎨 **Custom Color Schemes**: User-defined color palettes
- 🌈 **Accent Color Selection**: Multiple accent color options
- 📱 **Platform-Specific Themes**: iOS/Android specific styling
- 🎭 **Theme Animations**: Smooth transition animations
- 🔧 **Theme Editor**: Built-in theme customization UI

### Integration Opportunities

- **User Preferences**: Link theme to user account settings
- **Accessibility**: High contrast and large text themes
- **Seasonal Themes**: Holiday and special event themes
- **Clan Themes**: Clan-specific color schemes
- **Jutsu Themes**: Element-based theme variations

## Contributing

When contributing to the theme system:

1. **Follow Material 3 Guidelines**: Use the latest design principles
2. **Test All Modes**: Ensure changes work in light, dark, and auto modes
3. **Maintain Consistency**: Keep theme changes consistent across the app
4. **Update Documentation**: Document any new theme features
5. **Add Tests**: Include tests for new theme functionality

## References

- [Flutter Theming Guide](https://docs.flutter.dev/ui/design/themes)
- [Material 3 Design System](https://m3.material.io/)
- [Hive Storage Documentation](https://docs.hivedb.dev/)
- [Flutter ThemeData Class](https://api.flutter.dev/flutter/material/ThemeData-class.html)

---

**Last Updated**: December 2024  
**Version**: 1.0.0  
**Maintainer**: Development Team
