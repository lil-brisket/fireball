import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

/// Service for handling password operations including hashing and validation
class PasswordService {
  static const int _saltLength = 16;
  static const int _minPasswordLength = 6;
  static const int _maxPasswordLength = 50;

  /// Generates a random salt for password hashing
  static String _generateSalt() {
    final random = Random.secure();
    final saltBytes = List<int>.generate(_saltLength, (i) => random.nextInt(256));
    return base64Encode(saltBytes);
  }

  /// Hashes a password with a salt using SHA-256
  /// 
  /// [password] - The plain text password to hash
  /// Returns a string containing the salt and hash separated by ':'
  static String hashPassword(String password) {
    final salt = _generateSalt();
    final saltBytes = base64Decode(salt);
    final passwordBytes = utf8.encode(password);
    final combinedBytes = [...saltBytes, ...passwordBytes];
    final hash = sha256.convert(combinedBytes);
    return '$salt:${hash.toString()}';
  }

  /// Verifies a password against a stored hash
  /// 
  /// [password] - The plain text password to verify
  /// [storedHash] - The stored hash in format 'salt:hash'
  /// Returns true if the password matches, false otherwise
  static bool verifyPassword(String password, String storedHash) {
    try {
      final parts = storedHash.split(':');
      if (parts.length != 2) return false;
      
      final salt = parts[0];
      final storedHashValue = parts[1];
      
      final saltBytes = base64Decode(salt);
      final passwordBytes = utf8.encode(password);
      final combinedBytes = [...saltBytes, ...passwordBytes];
      final hash = sha256.convert(combinedBytes);
      
      return hash.toString() == storedHashValue;
    } catch (e) {
      return false;
    }
  }

  /// Validates password strength
  /// 
  /// [password] - The password to validate
  /// Returns a PasswordValidationResult with validation details
  static PasswordValidationResult validatePassword(String password) {
    if (password.length < _minPasswordLength) {
      return PasswordValidationResult(
        isValid: false,
        message: 'Password must be at least $_minPasswordLength characters long',
      );
    }
    
    if (password.length > _maxPasswordLength) {
      return PasswordValidationResult(
        isValid: false,
        message: 'Password must be no more than $_maxPasswordLength characters long',
      );
    }
    
    // Check for at least one letter and one number
    final hasLetter = password.contains(RegExp(r'[a-zA-Z]'));
    final hasNumber = password.contains(RegExp(r'[0-9]'));
    
    if (!hasLetter) {
      return PasswordValidationResult(
        isValid: false,
        message: 'Password must contain at least one letter',
      );
    }
    
    if (!hasNumber) {
      return PasswordValidationResult(
        isValid: false,
        message: 'Password must contain at least one number',
      );
    }
    
    return PasswordValidationResult(
      isValid: true,
      message: 'Password is valid',
    );
  }

  /// Generates a random password
  /// 
  /// [length] - The length of the password (default: 12)
  /// Returns a randomly generated password
  static String generatePassword({int length = 12}) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*';
    final random = Random.secure();
    return String.fromCharCodes(
      Iterable.generate(length, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );
  }
}

/// Result of password validation
class PasswordValidationResult {
  /// Whether the password is valid
  final bool isValid;
  
  /// Validation message
  final String message;
  
  const PasswordValidationResult({
    required this.isValid,
    required this.message,
  });
}
