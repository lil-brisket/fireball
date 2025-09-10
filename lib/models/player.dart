import 'package:hive/hive.dart';
import 'jutsu.dart';
import 'item.dart';
import '../core/jutsu_unlock_manager.dart';

part 'player.g.dart';

/// Represents a player in the Shinobi RPG game.
/// 
/// This class contains all player-related data including stats,
/// HP, Chakra, battle information, and progression system.
/// 
/// Example:
/// ```dart
/// final player = Player(
///   id: 'player_123',
///   name: 'Naruto',
///   maxHp: 100,
///   maxChakra: 50,
/// );
/// ```
@HiveType(typeId: 5)
class Player {
  /// The unique identifier for this player
  @HiveField(0)
  final String id;
  
  /// The player's display name
  @HiveField(1)
  final String name;
  
  /// Maximum hit points
  @HiveField(2)
  int maxHp;
  
  /// Current hit points (0 to maxHp)
  @HiveField(3)
  int currentHp;
  
  /// Maximum chakra points
  @HiveField(4)
  int maxChakra;
  
  /// Current chakra points (0 to maxChakra)
  @HiveField(5)
  int currentChakra;
  
  /// Player's strength stat (affects attack damage)
  @HiveField(6)
  int strength;
  
  /// Player's defense stat (reduces incoming damage)
  @HiveField(7)
  int defense;
  
  /// Player's current experience points
  @HiveField(8)
  int xp;
  
  /// Player's current level
  @HiveField(9)
  int level;
  
  /// Experience points needed to reach the next level
  @HiveField(10)
  int xpToNextLevel;
  
  /// Whether the player is currently defending
  @HiveField(11)
  bool isDefending;
  
  /// List of available jutsu for this player
  @HiveField(12)
  List<Jutsu> availableJutsu;
  
  /// Player's inventory containing items and quantities
  @HiveField(13)
  Map<String, InventoryEntry> inventory;
  
  /// Temporary attack buff (resets after battle)
  @HiveField(14)
  int temporaryAttackBuff;
  
  /// Temporary defense buff (resets after battle)
  @HiveField(15)
  int temporaryDefenseBuff;

  /// Creates a new Player instance
  /// 
  /// [id] - Unique identifier for the player
  /// [name] - Display name for the player
  /// [maxHp] - Maximum hit points (default: 100)
  /// [maxChakra] - Maximum chakra points (default: 50)
  /// [strength] - Strength stat for attack damage (default: 10)
  /// [defense] - Defense stat for damage reduction (default: 5)
  /// [level] - Starting level (default: 1)
  /// [xp] - Starting experience points (default: 0)
  /// [availableJutsu] - List of available jutsu (default: empty list)
  /// [inventory] - Player's inventory (default: empty with starter items)
  Player({
    required this.id,
    required this.name,
    this.maxHp = 100,
    this.maxChakra = 50,
    this.strength = 10,
    this.defense = 5,
    this.level = 1,
    this.xp = 0,
    List<Jutsu>? availableJutsu,
    Map<String, InventoryEntry>? inventory,
  }) : currentHp = maxHp,
       currentChakra = maxChakra,
       isDefending = false,
       xpToNextLevel = _calculateXpToNextLevel(1),
       availableJutsu = availableJutsu ?? _initializeJutsuForLevel(1),
       inventory = inventory ?? _initializeStarterInventory(),
       temporaryAttackBuff = 0,
       temporaryDefenseBuff = 0;

  /// Calculates the XP required to reach the next level
  /// 
  /// Uses a quadratic formula: level * 100 + (level - 1) * 50
  /// This creates increasing XP requirements for higher levels
  static int _calculateXpToNextLevel(int currentLevel) {
    return (currentLevel * 100) + ((currentLevel - 1) * 50);
  }

  /// Initializes the available Jutsu list based on the player's level
  /// 
  /// [level] - The level to initialize Jutsu for
  /// Returns a list of Jutsu available at the specified level
  static List<Jutsu> _initializeJutsuForLevel(int level) {
    final manager = JutsuUnlockManager();
    return manager.getAllJutsuUpToLevel(level);
  }

  /// Initializes the starter inventory with basic items
  /// 
  /// Returns a map containing starter items for new players
  static Map<String, InventoryEntry> _initializeStarterInventory() {
    return {
      'Healing Potion': InventoryEntry(item: Item.healingPotion(), quantity: 3),
      'Chakra Potion': InventoryEntry(item: Item.chakraPotion(), quantity: 2),
    };
  }

  /// Gains experience points and checks for level up
  /// 
  /// [amount] - Amount of XP to gain
  /// Returns true if the player leveled up, false otherwise
  bool gainXp(int amount) {
    xp += amount;
    bool leveledUp = false;
    
    // Check for level up
    while (xp >= xpToNextLevel) {
      xp -= xpToNextLevel;
      levelUp();
      leveledUp = true;
    }
    
    return leveledUp;
  }

  /// Levels up the player, increasing stats and resetting XP progress
  /// 
  /// Increases HP by 20, Chakra by 10, Strength by 2, Defense by 1
  /// Heals player to full HP and Chakra
  /// Unlocks new Jutsu if available at the new level
  void levelUp() {
    level++;
    
    // Increase stats
    maxHp += 20;
    maxChakra += 10;
    strength += 2;
    defense += 1;
    
    // Heal to full
    currentHp = maxHp;
    currentChakra = maxChakra;
    
    // Calculate XP needed for next level
    xpToNextLevel = _calculateXpToNextLevel(level);
    
    // Check for new Jutsu unlocks
    _checkForJutsuUnlocks();
  }

  /// Checks if any new Jutsu should be unlocked at the current level
  /// 
  /// Updates the availableJutsu list with any newly unlocked Jutsu
  void _checkForJutsuUnlocks() {
    final manager = JutsuUnlockManager();
    final newJutsu = manager.getJutsuUnlockedAtLevel(level);
    
    if (newJutsu != null) {
      // Check if this Jutsu is already unlocked
      final alreadyUnlocked = availableJutsu.any((jutsu) => jutsu.name == newJutsu.name);
      
      if (!alreadyUnlocked) {
        availableJutsu.add(newJutsu);
      }
    }
  }

  /// Gets the Jutsu that was unlocked at the current level
  /// 
  /// Returns the Jutsu unlocked at this level, or null if none
  Jutsu? getJutsuUnlockedThisLevel() {
    final manager = JutsuUnlockManager();
    return manager.getJutsuUnlockedAtLevel(level);
  }

  /// Gets the XP progress percentage towards the next level (0.0 to 1.0)
  double get xpPercentage => xp / xpToNextLevel;

  /// Adds an item to the player's inventory
  /// 
  /// [item] - The item to add
  /// [quantity] - How many of the item to add (default: 1)
  void addItem(Item item, {int quantity = 1}) {
    if (inventory.containsKey(item.name)) {
      inventory[item.name]!.addQuantity(quantity);
    } else {
      inventory[item.name] = InventoryEntry(item: item, quantity: quantity);
    }
  }

  /// Removes an item from the player's inventory
  /// 
  /// [itemName] - The name of the item to remove
  /// [quantity] - How many of the item to remove (default: 1)
  /// Returns true if successful, false if not enough items
  bool removeItem(String itemName, {int quantity = 1}) {
    if (inventory.containsKey(itemName)) {
      final success = inventory[itemName]!.removeQuantity(quantity);
      if (inventory[itemName]!.isEmpty) {
        inventory.remove(itemName);
      }
      return success;
    }
    return false;
  }

  /// Uses an item from the inventory
  /// 
  /// [itemName] - The name of the item to use
  /// Returns true if the item was used successfully, false otherwise
  bool useItem(String itemName) {
    if (!inventory.containsKey(itemName)) {
      return false;
    }

    final entry = inventory[itemName]!;
    if (entry.isEmpty) {
      return false;
    }

    final item = entry.item;
    bool success = false;

    switch (item.type) {
      case ItemType.healing:
        heal(item.effectValue);
        success = true;
        break;
      case ItemType.chakra:
        restoreChakra(item.effectValue);
        success = true;
        break;
      case ItemType.buff:
        if (item.name == 'Attack Boost') {
          temporaryAttackBuff += item.effectValue;
          success = true;
        } else if (item.name == 'Defense Boost') {
          temporaryDefenseBuff += item.effectValue;
          success = true;
        }
        break;
    }

    if (success) {
      removeItem(itemName);
    }

    return success;
  }

  /// Gets the quantity of a specific item in inventory
  /// 
  /// [itemName] - The name of the item to check
  /// Returns the quantity of the item (0 if not found)
  int getItemQuantity(String itemName) {
    return inventory[itemName]?.quantity ?? 0;
  }

  /// Gets all items that can be used in battle
  /// 
  /// Returns a list of inventory entries for items usable in battle
  List<InventoryEntry> getBattleUsableItems() {
    return inventory.values
        .where((entry) => entry.item.canUseInBattle && !entry.isEmpty)
        .toList();
  }

  /// Resets temporary buffs (called at the end of battle)
  void resetTemporaryBuffs() {
    temporaryAttackBuff = 0;
    temporaryDefenseBuff = 0;
  }

  /// Calculates attack damage based on strength and temporary buffs
  /// 
  /// Returns a random damage value between (strength + buff)/2 and (strength + buff)
  int calculateAttackDamage() {
    final totalStrength = strength + temporaryAttackBuff;
    final baseDamage = totalStrength ~/ 2;
    final random = DateTime.now().millisecondsSinceEpoch % (totalStrength - baseDamage + 1);
    return baseDamage + random;
  }

  /// Takes damage and reduces current HP
  /// 
  /// [damage] - Amount of damage to take
  /// Returns the actual damage taken after defense reduction
  int takeDamage(int damage) {
    // Defense reduces damage by 1 point per 2 defense (including temporary buffs)
    final totalDefense = defense + temporaryDefenseBuff;
    final defenseReduction = totalDefense ~/ 2;
    final actualDamage = (damage - defenseReduction).clamp(0, damage);
    
    currentHp = (currentHp - actualDamage).clamp(0, maxHp);
    return actualDamage;
  }

  /// Heals the player by the specified amount
  /// 
  /// [amount] - Amount of HP to restore
  void heal(int amount) {
    currentHp = (currentHp + amount).clamp(0, maxHp);
  }

  /// Restores chakra by the specified amount
  /// 
  /// [amount] - Amount of chakra to restore
  void restoreChakra(int amount) {
    currentChakra = (currentChakra + amount).clamp(0, maxChakra);
  }

  /// Consumes chakra for jutsu or abilities
  /// 
  /// [amount] - Amount of chakra to consume
  /// Returns true if chakra was successfully consumed, false if insufficient
  bool consumeChakra(int amount) {
    if (currentChakra >= amount) {
      currentChakra -= amount;
      return true;
    }
    return false;
  }

  /// Checks if the player is alive
  bool get isAlive => currentHp > 0;

  /// Gets the HP percentage (0.0 to 1.0)
  double get hpPercentage => currentHp / maxHp;

  /// Gets the chakra percentage (0.0 to 1.0)
  double get chakraPercentage => currentChakra / maxChakra;

  /// Gets jutsu that can be used with current chakra
  /// 
  /// Returns a list of jutsu that the player can afford to use
  List<Jutsu> getUsableJutsu() {
    return availableJutsu.where((jutsu) => jutsu.canUse(currentChakra)).toList();
  }

  /// Resets the player to full health and chakra
  void reset() {
    currentHp = maxHp;
    currentChakra = maxChakra;
    isDefending = false;
    resetTemporaryBuffs();
  }

  @override
  String toString() {
    return 'Player(id: $id, name: $name, level: $level, hp: $currentHp/$maxHp, chakra: $currentChakra/$maxChakra, xp: $xp/$xpToNextLevel)';
  }
}
