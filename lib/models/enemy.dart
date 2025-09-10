/// Represents different types of enemies in the Shinobi RPG game.
/// Each enemy type has unique stats and AI behavior patterns.
enum EnemyType {
  /// Weak enemies with low HP and attack power, simple AI
  weak,
  /// Strong enemies with high HP and attack power, occasionally defends
  strong,
  /// Boss enemies with very high HP, special attacks, and complex AI
  boss,
}

/// Represents an enemy in the Shinobi RPG game.
/// 
/// This class contains enemy data including stats, HP, and AI behavior.
/// Enemies have different types with unique characteristics and attack patterns.
/// 
/// Example:
/// ```dart
/// final enemy = Enemy(
///   id: 'enemy_001',
///   name: 'Bandit',
///   type: EnemyType.weak,
///   maxHp: 80,
/// );
/// ```
class Enemy {
  /// The unique identifier for this enemy
  final String id;
  
  /// The enemy's display name
  final String name;
  
  /// The type of enemy (affects stats and AI behavior)
  final EnemyType type;
  
  /// Maximum hit points
  final int maxHp;
  
  /// Current hit points (0 to maxHp)
  int currentHp;
  
  /// Enemy's attack power
  final int attackPower;
  
  /// Enemy's defense stat (reduces incoming damage)
  final int defense;
  
  /// Whether the enemy is currently defending
  bool isDefending;

  /// Creates a new Enemy instance
  /// 
  /// [id] - Unique identifier for the enemy
  /// [name] - Display name for the enemy
  /// [type] - Type of enemy (affects stats and behavior)
  /// [maxHp] - Maximum hit points
  /// [attackPower] - Attack power for damage calculation
  /// [defense] - Defense stat for damage reduction
  Enemy({
    required this.id,
    required this.name,
    required this.type,
    required this.maxHp,
    required this.attackPower,
    required this.defense,
  }) : currentHp = maxHp,
       isDefending = false;

  /// Calculates attack damage based on attack power
  /// 
  /// Returns a random damage value between attackPower/2 and attackPower
  int calculateAttackDamage() {
    final baseDamage = attackPower ~/ 2;
    final random = DateTime.now().millisecondsSinceEpoch % (attackPower - baseDamage + 1);
    return baseDamage + random;
  }

  /// Takes damage and reduces current HP
  /// 
  /// [damage] - Amount of damage to take
  /// Returns the actual damage taken after defense reduction
  int takeDamage(int damage) {
    // Defense reduces damage by 1 point per 2 defense
    final defenseReduction = defense ~/ 2;
    final actualDamage = (damage - defenseReduction).clamp(0, damage);
    
    currentHp = (currentHp - actualDamage).clamp(0, maxHp);
    return actualDamage;
  }

  /// Heals the enemy by the specified amount
  /// 
  /// [amount] - Amount of HP to restore
  void heal(int amount) {
    currentHp = (currentHp + amount).clamp(0, maxHp);
  }

  /// Checks if the enemy is alive
  bool get isAlive => currentHp > 0;

  /// Gets the HP percentage (0.0 to 1.0)
  double get hpPercentage => currentHp / maxHp;

  /// Resets the enemy to full health
  void reset() {
    currentHp = maxHp;
    isDefending = false;
  }

  @override
  String toString() {
    return 'Enemy(id: $id, name: $name, type: $type, hp: $currentHp/$maxHp)';
  }
}

/// Factory class for creating different types of enemies with predefined stats.
/// 
/// This class provides static methods to create enemies with balanced stats
/// based on their type and difficulty level.
class EnemyFactory {
  /// Creates a weak enemy with low stats and simple AI behavior.
  /// 
  /// Weak enemies are easy to defeat and use basic attack patterns.
  /// They have low HP, attack power, and defense stats.
  /// 
  /// [id] - Unique identifier for the enemy
  /// [name] - Display name for the enemy
  static Enemy createWeakEnemy({required String id, required String name}) {
    return Enemy(
      id: id,
      name: name,
      type: EnemyType.weak,
      maxHp: 60,
      attackPower: 6,
      defense: 2,
    );
  }

  /// Creates a strong enemy with high stats and defensive AI behavior.
  /// 
  /// Strong enemies are challenging opponents that occasionally defend
  /// and have higher HP, attack power, and defense stats.
  /// 
  /// [id] - Unique identifier for the enemy
  /// [name] - Display name for the enemy
  static Enemy createStrongEnemy({required String id, required String name}) {
    return Enemy(
      id: id,
      name: name,
      type: EnemyType.strong,
      maxHp: 120,
      attackPower: 12,
      defense: 6,
    );
  }

  /// Creates a boss enemy with very high stats and special AI behavior.
  /// 
  /// Boss enemies are the most challenging opponents with special attacks
  /// and complex AI patterns. They have very high HP and attack power.
  /// 
  /// [id] - Unique identifier for the enemy
  /// [name] - Display name for the enemy
  static Enemy createBossEnemy({required String id, required String name}) {
    return Enemy(
      id: id,
      name: name,
      type: EnemyType.boss,
      maxHp: 200,
      attackPower: 18,
      defense: 10,
    );
  }

  /// Creates a random enemy of any type for variety in battles.
  /// 
  /// This method randomly selects an enemy type and creates an enemy
  /// with appropriate stats for that type.
  /// 
  /// [id] - Unique identifier for the enemy
  /// [name] - Display name for the enemy
  static Enemy createRandomEnemy({required String id, required String name}) {
    final random = DateTime.now().millisecondsSinceEpoch % 3;
    switch (random) {
      case 0:
        return createWeakEnemy(id: id, name: name);
      case 1:
        return createStrongEnemy(id: id, name: name);
      case 2:
        return createBossEnemy(id: id, name: name);
      default:
        return createWeakEnemy(id: id, name: name);
    }
  }
}
