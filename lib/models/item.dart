import 'package:hive/hive.dart';

part 'item.g.dart';

/// Represents different types of items that can be used in battle.
@HiveType(typeId: 0)
enum ItemType {
  @HiveField(0)
  healing,
  @HiveField(1)
  chakra,
  @HiveField(2)
  buff,
}

/// Represents an item that can be used in the Shinobi RPG game.
/// 
/// This class contains item data including name, type, effects, and usage information.
/// Items can restore HP, Chakra, or provide temporary buffs.
/// 
/// Example:
/// ```dart
/// final healingPotion = Item(
///   name: 'Healing Potion',
///   type: ItemType.healing,
///   effectValue: 30,
///   description: 'Restores 30 HP',
/// );
/// ```
@HiveType(typeId: 1)
class Item {
  /// The name of the item
  @HiveField(0)
  final String name;
  
  /// The type of item (healing, chakra, buff)
  @HiveField(1)
  final ItemType type;
  
  /// The effect value (HP restored, Chakra restored, or buff strength)
  @HiveField(2)
  final int effectValue;
  
  /// Description of what the item does
  @HiveField(3)
  final String description;
  
  /// Whether this item can be used during battle
  @HiveField(4)
  final bool canUseInBattle;
  
  /// Whether this item can be used outside of battle
  @HiveField(5)
  final bool canUseOutsideBattle;

  /// Creates a new Item instance
  /// 
  /// [name] - Display name for the item
  /// [type] - Type of item (healing, chakra, buff)
  /// [effectValue] - Amount of effect the item provides
  /// [description] - Description of what the item does
  /// [canUseInBattle] - Whether item can be used during battle (default: true)
  /// [canUseOutsideBattle] - Whether item can be used outside battle (default: true)
  Item({
    required this.name,
    required this.type,
    required this.effectValue,
    required this.description,
    this.canUseInBattle = true,
    this.canUseOutsideBattle = true,
  });

  /// Creates a healing potion item
  static Item healingPotion() {
    return Item(
      name: 'Healing Potion',
      type: ItemType.healing,
      effectValue: 30,
      description: 'Restores 30 HP',
    );
  }

  /// Creates a chakra potion item
  static Item chakraPotion() {
    return Item(
      name: 'Chakra Potion',
      type: ItemType.chakra,
      effectValue: 20,
      description: 'Restores 20 Chakra',
    );
  }

  /// Creates an attack buff item
  static Item attackBuff() {
    return Item(
      name: 'Attack Boost',
      type: ItemType.buff,
      effectValue: 5,
      description: 'Increases attack power by 5 for one battle',
    );
  }

  /// Creates a defense buff item
  static Item defenseBuff() {
    return Item(
      name: 'Defense Boost',
      type: ItemType.buff,
      effectValue: 3,
      description: 'Increases defense by 3 for one battle',
    );
  }

  @override
  String toString() {
    return 'Item(name: $name, type: $type, effectValue: $effectValue)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Item && other.name == name;
  }

  @override
  int get hashCode => name.hashCode;
}

/// Represents an inventory entry containing an item and its quantity.
@HiveType(typeId: 2)
class InventoryEntry {
  /// The item in this inventory slot
  @HiveField(0)
  final Item item;
  
  /// The quantity of this item
  @HiveField(1)
  int quantity;

  /// Creates a new InventoryEntry instance
  /// 
  /// [item] - The item to store
  /// [quantity] - How many of this item (default: 1)
  InventoryEntry({
    required this.item,
    this.quantity = 1,
  });

  /// Adds items to this inventory entry
  /// 
  /// [amount] - Number of items to add
  void addQuantity(int amount) {
    quantity += amount;
  }

  /// Removes items from this inventory entry
  /// 
  /// [amount] - Number of items to remove
  /// Returns true if successful, false if not enough items
  bool removeQuantity(int amount) {
    if (quantity >= amount) {
      quantity -= amount;
      return true;
    }
    return false;
  }

  /// Checks if this inventory entry has any items
  bool get isEmpty => quantity <= 0;

  @override
  String toString() {
    return 'InventoryEntry(item: ${item.name}, quantity: $quantity)';
  }
}
