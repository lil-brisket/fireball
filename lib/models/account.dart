import 'package:hive/hive.dart';
import 'player.dart';

part 'account.g.dart';

/// Represents a user account in the Shinobi RPG game.
/// 
/// This class contains all account-related data including player data,
/// account metadata, and login information.
/// 
/// Example:
/// ```dart
/// final account = Account(
///   id: 'account_123',
///   username: 'NarutoPlayer',
///   player: player,
/// );
/// ```
@HiveType(typeId: 6)
class Account {
  /// The unique identifier for this account
  @HiveField(0)
  final String id;
  
  /// The account username
  @HiveField(1)
  final String username;
  
  /// The account password (hashed)
  @HiveField(2)
  final String password;
  
  /// The account email
  @HiveField(3)
  final String email;
  
  /// The account gender
  @HiveField(4)
  final String gender;
  
  /// Optional avatar URL for the account
  @HiveField(5)
  final String? avatar;
  
  /// The player data associated with this account
  @HiveField(6)
  final Player player;
  
  /// When this account was created
  @HiveField(7)
  final DateTime? createdAt;
  
  /// When this account was last accessed
  @HiveField(8)
  final DateTime? lastLoginAt;
  
  /// Whether this account is currently active
  @HiveField(9)
  final bool isActive;

  /// Creates a new Account instance
  /// 
  /// [id] - Unique identifier for the account
  /// [username] - Username for the account
  /// [password] - Password for the account (should be hashed)
  /// [email] - Email for the account
  /// [gender] - Gender for the account
  /// [player] - Player data associated with this account
  /// [avatar] - Optional avatar URL
  /// [createdAt] - When the account was created (defaults to now)
  /// [lastLoginAt] - When the account was last accessed (defaults to now)
  /// [isActive] - Whether this account is currently active (defaults to true)
  Account({
    required this.id,
    required this.username,
    required this.password,
    required this.email,
    required this.gender,
    required this.player,
    this.avatar,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    this.isActive = true,
  }) : createdAt = createdAt ?? DateTime.now(),
       lastLoginAt = lastLoginAt ?? DateTime.now();

  /// Creates a copy of this account with updated fields
  /// 
  /// [id] - New ID (optional)
  /// [username] - New username (optional)
  /// [password] - New password (optional)
  /// [email] - New email (optional)
  /// [gender] - New gender (optional)
  /// [player] - New player data (optional)
  /// [avatar] - New avatar (optional)
  /// [createdAt] - New creation date (optional)
  /// [lastLoginAt] - New last login date (optional)
  /// [isActive] - New active status (optional)
  Account copyWith({
    String? id,
    String? username,
    String? password,
    String? email,
    String? gender,
    Player? player,
    String? avatar,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? isActive,
  }) {
    return Account(
      id: id ?? this.id,
      username: username ?? this.username,
      password: password ?? this.password,
      email: email ?? this.email,
      gender: gender ?? this.gender,
      player: player ?? this.player,
      avatar: avatar ?? this.avatar,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isActive: isActive ?? this.isActive,
    );
  }

  /// Updates the last login timestamp
  /// 
  /// Returns a new Account instance with updated lastLoginAt
  Account updateLastLogin() {
    return copyWith(lastLoginAt: DateTime.now());
  }

  /// Updates the player data
  /// 
  /// [player] - The updated player data
  /// Returns a new Account instance with updated player data
  Account updatePlayer(Player player) {
    return copyWith(player: player);
  }

  /// Gets the display name for this account
  /// 
  /// Returns the avatar if set, otherwise the username
  String get displayName => avatar ?? username;

  /// Gets the account age in days
  /// 
  /// Returns the number of days since account creation
  int get accountAgeInDays => DateTime.now().difference(createdAt ?? DateTime.now()).inDays;

  /// Gets the days since last login
  /// 
  /// Returns the number of days since last login
  int get daysSinceLastLogin => DateTime.now().difference(lastLoginAt ?? DateTime.now()).inDays;

  @override
  String toString() {
    return 'Account(id: $id, username: $username, email: $email, gender: $gender, avatar: $avatar, level: ${player.level}, lastLogin: $lastLoginAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Account && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
