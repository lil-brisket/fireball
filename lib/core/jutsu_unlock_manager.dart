import '../models/jutsu.dart';

/// Manages the unlocking of Jutsu based on player level.
/// 
/// This class contains all available Jutsu and their level requirements,
/// providing methods to check what Jutsu should be unlocked at each level.
/// 
/// Example:
/// ```dart
/// final manager = JutsuUnlockManager();
/// final newJutsu = manager.getJutsuUnlockedAtLevel(5);
/// if (newJutsu != null) {
///   print('Unlocked: ${newJutsu.name}');
/// }
/// ```
class JutsuUnlockManager {
  /// All available Jutsu with their level requirements
  static const Map<int, Jutsu> _jutsuByLevel = {
    1: Jutsu(
      name: 'Basic Punch',
      chakraCost: 5,
      minDamage: 8,
      maxDamage: 12,
      type: JutsuType.taijutsu,
      description: 'A basic physical attack',
    ),
    3: Jutsu(
      name: 'Fireball',
      chakraCost: 10,
      minDamage: 15,
      maxDamage: 25,
      type: JutsuType.ninjutsu,
      description: 'A basic fire technique',
    ),
    5: Jutsu(
      name: 'Water Bullet',
      chakraCost: 12,
      minDamage: 18,
      maxDamage: 28,
      type: JutsuType.ninjutsu,
      description: 'A water-based projectile attack',
    ),
    7: Jutsu(
      name: 'Lightning Strike',
      chakraCost: 15,
      minDamage: 22,
      maxDamage: 32,
      type: JutsuType.ninjutsu,
      description: 'A powerful lightning technique',
    ),
    10: Jutsu(
      name: 'Earth Wall',
      chakraCost: 8,
      minDamage: 0,
      maxDamage: 0,
      type: JutsuType.ninjutsu,
      description: 'Creates a defensive barrier (reduces incoming damage)',
    ),
    12: Jutsu(
      name: 'Wind Cutter',
      chakraCost: 18,
      minDamage: 25,
      maxDamage: 35,
      type: JutsuType.ninjutsu,
      description: 'A sharp wind-based attack',
    ),
    15: Jutsu(
      name: 'Shadow Clone',
      chakraCost: 20,
      minDamage: 30,
      maxDamage: 40,
      type: JutsuType.ninjutsu,
      description: 'Creates shadow clones for a powerful attack',
    ),
    18: Jutsu(
      name: 'Chidori',
      chakraCost: 25,
      minDamage: 35,
      maxDamage: 45,
      type: JutsuType.ninjutsu,
      description: 'A concentrated lightning technique',
    ),
    20: Jutsu(
      name: 'Rasengan',
      chakraCost: 30,
      minDamage: 40,
      maxDamage: 50,
      type: JutsuType.ninjutsu,
      description: 'A spinning chakra sphere attack',
    ),
  };

  /// Gets the Jutsu that should be unlocked at the specified level
  /// 
  /// [level] - The player level to check
  /// Returns the Jutsu to unlock, or null if no Jutsu unlocks at this level
  Jutsu? getJutsuUnlockedAtLevel(int level) {
    return _jutsuByLevel[level];
  }

  /// Gets all Jutsu that should be unlocked up to and including the specified level
  /// 
  /// [level] - The maximum level to check
  /// Returns a list of all Jutsu that should be available at this level
  List<Jutsu> getAllJutsuUpToLevel(int level) {
    final availableJutsu = <Jutsu>[];
    
    for (int i = 1; i <= level; i++) {
      final jutsu = _jutsuByLevel[i];
      if (jutsu != null) {
        availableJutsu.add(jutsu);
      }
    }
    
    return availableJutsu;
  }

  /// Gets all available Jutsu levels
  /// 
  /// Returns a list of all levels that have Jutsu unlocks
  List<int> getAllJutsuLevels() {
    return _jutsuByLevel.keys.toList()..sort();
  }

  /// Checks if a specific Jutsu is available at the given level
  /// 
  /// [jutsuName] - The name of the Jutsu to check
  /// [level] - The player level to check against
  /// Returns true if the Jutsu is available at this level
  bool isJutsuAvailableAtLevel(String jutsuName, int level) {
    final jutsu = getAllJutsuUpToLevel(level);
    return jutsu.any((j) => j.name == jutsuName);
  }

  /// Gets the total number of Jutsu available
  int get totalJutsuCount => _jutsuByLevel.length;

  /// Gets the highest level that unlocks a Jutsu
  int get maxJutsuLevel => _jutsuByLevel.keys.reduce((a, b) => a > b ? a : b);
}
