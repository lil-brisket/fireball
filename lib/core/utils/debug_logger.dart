import 'dart:developer' as developer;

/// A debug logger that provides better logging than print statements
/// 
/// This utility provides structured logging that can be easily disabled
/// in production builds and includes proper log levels.
/// 
/// Example:
/// ```dart
/// DebugLogger.info('User logged in successfully');
/// DebugLogger.error('Failed to load data', error: e);
/// ```
class DebugLogger {
  static const String _name = 'ShinobiRPG';
  static const bool _debugMode = true; // Set to false for production

  /// Log an informational message
  static void info(String message, {Object? error, StackTrace? stackTrace}) {
    if (_debugMode) {
      developer.log(
        message,
        name: _name,
        level: 800, // INFO level
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Log a warning message
  static void warning(String message, {Object? error, StackTrace? stackTrace}) {
    if (_debugMode) {
      developer.log(
        message,
        name: _name,
        level: 900, // WARNING level
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Log an error message
  static void error(String message, {Object? error, StackTrace? stackTrace}) {
    if (_debugMode) {
      developer.log(
        message,
        name: _name,
        level: 1000, // ERROR level
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Log a debug message (lowest priority)
  static void debug(String message, {Object? error, StackTrace? stackTrace}) {
    if (_debugMode) {
      developer.log(
        message,
        name: _name,
        level: 700, // DEBUG level
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Log player action for game analytics
  static void playerAction(String action, {Map<String, dynamic>? data}) {
    if (_debugMode) {
      final message = data != null ? '$action: $data' : action;
      developer.log(
        message,
        name: '$_name:PlayerAction',
        level: 800,
      );
    }
  }

  /// Log battle events for game balance analysis
  static void battleEvent(String event, {Map<String, dynamic>? data}) {
    if (_debugMode) {
      final message = data != null ? '$event: $data' : event;
      developer.log(
        message,
        name: '$_name:Battle',
        level: 800,
      );
    }
  }
}
