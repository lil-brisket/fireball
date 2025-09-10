import 'package:hive/hive.dart';

part 'jutsu.g.dart';

/// Represents a Jutsu ability in the Shinobi RPG game.
/// 
/// This class contains all jutsu-related data including name,
/// chakra cost, damage range, and type.
/// 
/// Example:
/// ```dart
/// final fireball = Jutsu(
///   name: 'Fireball',
///   chakraCost: 10,
///   minDamage: 15,
///   maxDamage: 25,
///   type: JutsuType.ninjutsu,
/// );
/// ```
@HiveType(typeId: 3)
class Jutsu {
  /// The name of the jutsu
  @HiveField(0)
  final String name;
  
  /// The chakra cost to use this jutsu
  @HiveField(1)
  final int chakraCost;
  
  /// The minimum damage this jutsu can deal
  @HiveField(2)
  final int minDamage;
  
  /// The maximum damage this jutsu can deal
  @HiveField(3)
  final int maxDamage;
  
  /// The type of jutsu (affects damage calculation)
  @HiveField(4)
  final JutsuType type;
  
  /// The description of the jutsu
  @HiveField(5)
  final String description;

  /// Creates a new Jutsu instance
  /// 
  /// [name] - The display name of the jutsu
  /// [chakraCost] - Chakra required to use this jutsu
  /// [minDamage] - Minimum damage dealt
  /// [maxDamage] - Maximum damage dealt
  /// [type] - The type of jutsu
  /// [description] - Description of the jutsu's effects
  const Jutsu({
    required this.name,
    required this.chakraCost,
    required this.minDamage,
    required this.maxDamage,
    required this.type,
    required this.description,
  });

  /// Calculates the damage this jutsu will deal
  /// 
  /// Returns a random damage value between minDamage and maxDamage
  int calculateDamage() {
    final damageRange = maxDamage - minDamage + 1;
    final random = DateTime.now().millisecondsSinceEpoch % damageRange;
    return minDamage + random;
  }

  /// Checks if the jutsu can be used with the given chakra amount
  /// 
  /// [availableChakra] - The current chakra available
  /// Returns true if there's enough chakra to use this jutsu
  bool canUse(int availableChakra) {
    return availableChakra >= chakraCost;
  }

  @override
  String toString() {
    return 'Jutsu(name: $name, cost: $chakraCost, damage: $minDamage-$maxDamage)';
  }
}

/// Represents the different types of jutsu
@HiveType(typeId: 4)
enum JutsuType {
  /// Ninjutsu - elemental techniques
  @HiveField(0)
  ninjutsu,
  /// Taijutsu - physical techniques
  @HiveField(1)
  taijutsu,
  /// Genjutsu - illusion techniques
  @HiveField(2)
  genjutsu,
}

/// Extension to provide display names for JutsuType
extension JutsuTypeExtension on JutsuType {
  String get displayName {
    switch (this) {
      case JutsuType.ninjutsu:
        return 'Ninjutsu';
      case JutsuType.taijutsu:
        return 'Taijutsu';
      case JutsuType.genjutsu:
        return 'Genjutsu';
    }
  }
}
