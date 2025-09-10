import 'package:hive_flutter/hive_flutter.dart';
import '../models/player.dart';
import '../models/item.dart';
import '../models/jutsu.dart';

/// Service responsible for managing save and load operations for player progress.
/// 
/// This service handles:
/// - Saving player data to local storage
/// - Loading player data from local storage
/// - Managing save slots
/// - Handling data migration and versioning
/// 
/// Example:
/// ```dart
/// final saveService = SaveLoadService();
/// await saveService.savePlayer(player);
/// final loadedPlayer = await saveService.loadPlayer();
/// ```
class SaveLoadService {
  static const String _playerBoxName = 'player_data';
  static const String _saveSlotKey = 'current_save_slot';
  static const int _maxSaveSlots = 3;
  
  late Box<Player> _playerBox;
  late Box<int> _slotBox;
  bool _isInitialized = false;

  /// Initializes the save/load service and opens the Hive box
  /// 
  /// This method must be called before using any save/load operations
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    // Adapters are now registered centrally in main.dart
    
    // Open the player data box
    _playerBox = await Hive.openBox<Player>(_playerBoxName);
    _slotBox = await Hive.openBox<int>('save_slots');
    _isInitialized = true;
  }

  /// Saves the player data to the current save slot
  /// 
  /// [player] - The player object to save
  /// [slot] - The save slot to use (0-2, defaults to 0)
  /// Returns true if save was successful, false otherwise
  Future<bool> savePlayer(Player player, {int slot = 0}) async {
    if (!_isInitialized) {
      throw StateError('SaveLoadService not initialized. Call initialize() first.');
    }
    
    if (slot < 0 || slot >= _maxSaveSlots) {
      throw ArgumentError('Invalid save slot: $slot. Must be between 0 and ${_maxSaveSlots - 1}');
    }

    try {
      final slotKey = '${_saveSlotKey}_$slot';
      await _playerBox.put(slotKey, player);
      
      // Update current save slot if this is slot 0
      if (slot == 0) {
        await _slotBox.put(_saveSlotKey, slot);
      }
      
      return true;
    } catch (e) {
      print('Error saving player data: $e');
      return false;
    }
  }

  /// Loads the player data from the specified save slot
  /// 
  /// [slot] - The save slot to load from (0-2, defaults to 0)
  /// Returns the loaded player or null if no save data exists
  Future<Player?> loadPlayer({int slot = 0}) async {
    if (!_isInitialized) {
      throw StateError('SaveLoadService not initialized. Call initialize() first.');
    }
    
    if (slot < 0 || slot >= _maxSaveSlots) {
      throw ArgumentError('Invalid save slot: $slot. Must be between 0 and ${_maxSaveSlots - 1}');
    }

    try {
      final slotKey = '${_saveSlotKey}_$slot';
      final player = _playerBox.get(slotKey);
      return player;
    } catch (e) {
      print('Error loading player data: $e');
      return null;
    }
  }

  /// Loads the player data from the current save slot
  /// 
  /// Returns the loaded player or null if no save data exists
  Future<Player?> loadCurrentPlayer() async {
    if (!_isInitialized) {
      throw StateError('SaveLoadService not initialized. Call initialize() first.');
    }

    try {
      final currentSlot = _slotBox.get(_saveSlotKey, defaultValue: 0) ?? 0;
      return await loadPlayer(slot: currentSlot);
    } catch (e) {
      print('Error loading current player data: $e');
      return null;
    }
  }

  /// Checks if a save slot has data
  /// 
  /// [slot] - The save slot to check (0-2)
  /// Returns true if the slot has save data, false otherwise
  bool hasSaveData({int slot = 0}) {
    if (!_isInitialized) return false;
    
    if (slot < 0 || slot >= _maxSaveSlots) return false;
    
    final slotKey = '${_saveSlotKey}_$slot';
    return _playerBox.containsKey(slotKey);
  }

  /// Gets information about all save slots
  /// 
  /// Returns a list of save slot information including level, name, and timestamp
  List<SaveSlotInfo> getSaveSlotInfo() {
    if (!_isInitialized) return [];
    
    final List<SaveSlotInfo> slots = [];
    
    for (int i = 0; i < _maxSaveSlots; i++) {
      final slotKey = '${_saveSlotKey}_$i';
      final player = _playerBox.get(slotKey);
      
      if (player != null) {
        slots.add(SaveSlotInfo(
          slot: i,
          playerName: player.name,
          level: player.level,
          hasData: true,
        ));
      } else {
        slots.add(SaveSlotInfo(
          slot: i,
          playerName: 'Empty',
          level: 0,
          hasData: false,
        ));
      }
    }
    
    return slots;
  }

  /// Deletes a save slot
  /// 
  /// [slot] - The save slot to delete (0-2)
  /// Returns true if deletion was successful, false otherwise
  Future<bool> deleteSaveSlot(int slot) async {
    if (!_isInitialized) return false;
    
    if (slot < 0 || slot >= _maxSaveSlots) return false;
    
    try {
      final slotKey = '${_saveSlotKey}_$slot';
      await _playerBox.delete(slotKey);
      return true;
    } catch (e) {
      print('Error deleting save slot: $e');
      return false;
    }
  }

  /// Saves player progress after a battle
  /// 
  /// This method is called after battles to ensure progress is saved
  /// [player] - The player object to save
  Future<void> saveBattleProgress(Player player) async {
    await savePlayer(player);
  }

  /// Saves player progress after inventory changes
  /// 
  /// This method is called after inventory modifications
  /// [player] - The player object to save
  Future<void> saveInventoryProgress(Player player) async {
    await savePlayer(player);
  }

  /// Saves player progress after level up
  /// 
  /// This method is called after level up to save new stats and unlocked jutsu
  /// [player] - The player object to save
  Future<void> saveLevelUpProgress(Player player) async {
    await savePlayer(player);
  }

  /// Closes the Hive box and cleans up resources
  Future<void> dispose() async {
    if (_isInitialized) {
      await _playerBox.close();
      await _slotBox.close();
      _isInitialized = false;
    }
  }
}

/// Information about a save slot
class SaveSlotInfo {
  /// The slot number (0-2)
  final int slot;
  
  /// The player name in this slot
  final String playerName;
  
  /// The player level in this slot
  final int level;
  
  /// Whether this slot has save data
  final bool hasData;

  SaveSlotInfo({
    required this.slot,
    required this.playerName,
    required this.level,
    required this.hasData,
  });

  @override
  String toString() {
    return 'SaveSlotInfo(slot: $slot, player: $playerName, level: $level, hasData: $hasData)';
  }
}
