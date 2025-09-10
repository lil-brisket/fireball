import '../models/player.dart';
import 'save_load_service.dart';
import 'account_manager.dart';

/// Manages the global player state and integrates with the save/load system.
/// 
/// This singleton service provides:
/// - Global access to the current player
/// - Automatic saving of player progress
/// - Integration with the save/load system
/// - Player state management across the app
/// 
/// Example:
/// ```dart
/// final playerManager = PlayerDataManager.instance;
/// await playerManager.initialize();
/// final player = playerManager.currentPlayer;
/// ```
class PlayerDataManager {
  static final PlayerDataManager _instance = PlayerDataManager._internal();
  factory PlayerDataManager() => _instance;
  PlayerDataManager._internal();

  static PlayerDataManager get instance => _instance;

  Player? _currentPlayer;
  SaveLoadService? _saveLoadService;
  AccountManager? _accountManager;
  bool _isInitialized = false;

  /// Gets the current player instance
  Player? get currentPlayer => _currentPlayer;

  /// Checks if the manager is initialized
  bool get isInitialized => _isInitialized;

  /// Initializes the player data manager and loads saved data
  /// 
  /// This method should be called at app startup
  Future<void> initialize() async {
    if (_isInitialized) {
      print('DEBUG: PlayerDataManager - Already initialized');
      return;
    }

    print('DEBUG: PlayerDataManager - Initializing...');
    _saveLoadService = SaveLoadService();
    _accountManager = AccountManager.instance;
    
    await _saveLoadService!.initialize();
    // Don't initialize AccountManager here - it's already initialized in main.dart

    // Try to load existing player data from current account
    final currentAccount = _accountManager!.currentAccount;
    print('DEBUG: PlayerDataManager - Current account: ${currentAccount?.id ?? "null"}');
    
    if (currentAccount != null) {
      _currentPlayer = currentAccount.player;
      print('DEBUG: PlayerDataManager - Loaded player from account: ${_currentPlayer?.name ?? "null"}');
    } else {
      // Fallback to old save system for backward compatibility
      _currentPlayer = await _saveLoadService!.loadCurrentPlayer();
      print('DEBUG: PlayerDataManager - Loaded player from legacy system: ${_currentPlayer?.name ?? "null"}');
    }
    
    _isInitialized = true;
    print('DEBUG: PlayerDataManager - Initialization complete');
  }

  /// Creates a new player and saves it
  /// 
  /// [id] - Unique identifier for the player
  /// [name] - Display name for the player
  /// [maxHp] - Maximum hit points (default: 100)
  /// [maxChakra] - Maximum chakra points (default: 50)
  /// [strength] - Strength stat (default: 10)
  /// [defense] - Defense stat (default: 5)
  /// [level] - Starting level (default: 1)
  /// [xp] - Starting experience points (default: 0)
  /// Returns the created player
  Future<Player> createNewPlayer({
    required String id,
    required String name,
    int maxHp = 100,
    int maxChakra = 50,
    int strength = 10,
    int defense = 5,
    int level = 1,
    int xp = 0,
  }) async {
    if (!_isInitialized) {
      throw StateError('PlayerDataManager not initialized. Call initialize() first.');
    }

    final player = Player(
      id: id,
      name: name,
      maxHp: maxHp,
      maxChakra: maxChakra,
      strength: strength,
      defense: defense,
      level: level,
      xp: xp,
    );

    _currentPlayer = player;
    await _saveLoadService!.savePlayer(player);
    
    return player;
  }

  /// Loads a player from a specific save slot
  /// 
  /// [slot] - The save slot to load from (0-2)
  /// Returns true if player was loaded successfully, false otherwise
  Future<bool> loadPlayerFromSlot(int slot) async {
    if (!_isInitialized) {
      throw StateError('PlayerDataManager not initialized. Call initialize() first.');
    }

    final player = await _saveLoadService!.loadPlayer(slot: slot);
    if (player != null) {
      _currentPlayer = player;
      return true;
    }
    return false;
  }

  /// Saves the current player data
  /// 
  /// [slot] - The save slot to use (0-2, defaults to 0)
  /// Returns true if save was successful, false otherwise
  Future<bool> saveCurrentPlayer({int slot = 0}) async {
    if (!_isInitialized) {
      throw StateError('PlayerDataManager not initialized. Call initialize() first.');
    }

    if (_currentPlayer == null) {
      print('No current player to save');
      return false;
    }

    return await _saveLoadService!.savePlayer(_currentPlayer!, slot: slot);
  }

  /// Updates the current player and automatically saves
  /// 
  /// [player] - The updated player object
  /// [autoSave] - Whether to automatically save after update (default: true)
  Future<void> updatePlayer(Player player, {bool autoSave = true}) async {
    if (!_isInitialized) {
      throw StateError('PlayerDataManager not initialized. Call initialize() first.');
    }

    print('DEBUG: PlayerDataManager - Updating player: ${player.name} (ID: ${player.id})');
    _currentPlayer = player;
    print('DEBUG: PlayerDataManager - Current player set to: ${_currentPlayer?.name}');
    
    if (autoSave) {
      // Save to account system if available, otherwise fallback to old system
      if (_accountManager != null && _accountManager!.currentAccount != null) {
        print('DEBUG: PlayerDataManager - Saving to account system');
        await _accountManager!.updateCurrentAccountPlayer(player);
      } else {
        print('DEBUG: PlayerDataManager - Saving to legacy system');
        await _saveLoadService!.savePlayer(player);
      }
    } else {
      print('DEBUG: PlayerDataManager - Auto-save disabled, skipping save');
    }
  }

  /// Saves battle progress after a battle
  /// 
  /// This method should be called after battles to ensure progress is saved
  Future<void> saveBattleProgress() async {
    if (!_isInitialized || _currentPlayer == null) return;

    // Save to account system if available, otherwise fallback to old system
    if (_accountManager != null && _accountManager!.currentAccount != null) {
      await _accountManager!.updateCurrentAccountPlayer(_currentPlayer!);
    } else {
      await _saveLoadService!.saveBattleProgress(_currentPlayer!);
    }
  }

  /// Saves inventory progress after inventory changes
  /// 
  /// This method should be called after inventory modifications
  Future<void> saveInventoryProgress() async {
    if (!_isInitialized || _currentPlayer == null) return;

    // Save to account system if available, otherwise fallback to old system
    if (_accountManager != null && _accountManager!.currentAccount != null) {
      await _accountManager!.updateCurrentAccountPlayer(_currentPlayer!);
    } else {
      await _saveLoadService!.saveInventoryProgress(_currentPlayer!);
    }
  }

  /// Saves level up progress after level up
  /// 
  /// This method should be called after level up to save new stats and unlocked jutsu
  Future<void> saveLevelUpProgress() async {
    if (!_isInitialized || _currentPlayer == null) return;

    // Save to account system if available, otherwise fallback to old system
    if (_accountManager != null && _accountManager!.currentAccount != null) {
      await _accountManager!.updateCurrentAccountPlayer(_currentPlayer!);
    } else {
      await _saveLoadService!.saveLevelUpProgress(_currentPlayer!);
    }
  }

  /// Gets information about all save slots
  /// 
  /// Returns a list of save slot information
  List<SaveSlotInfo> getSaveSlotInfo() {
    if (!_isInitialized) return [];
    return _saveLoadService!.getSaveSlotInfo();
  }

  /// Checks if a save slot has data
  /// 
  /// [slot] - The save slot to check (0-2)
  /// Returns true if the slot has save data, false otherwise
  bool hasSaveData({int slot = 0}) {
    if (!_isInitialized) return false;
    return _saveLoadService!.hasSaveData(slot: slot);
  }

  /// Deletes a save slot
  /// 
  /// [slot] - The save slot to delete (0-2)
  /// Returns true if deletion was successful, false otherwise
  Future<bool> deleteSaveSlot(int slot) async {
    if (!_isInitialized) return false;
    return await _saveLoadService!.deleteSaveSlot(slot);
  }

  /// Resets the current player to a new game state
  /// 
  /// This will create a new player and clear any existing data
  Future<Player> resetToNewGame({
    required String id,
    required String name,
  }) async {
    if (!_isInitialized) {
      throw StateError('PlayerDataManager not initialized. Call initialize() first.');
    }

    return await createNewPlayer(
      id: id,
      name: name,
    );
  }

  /// Cleans up resources
  Future<void> dispose() async {
    if (_isInitialized) {
      await _saveLoadService!.dispose();
      await _accountManager!.dispose();
      _currentPlayer = null;
      _saveLoadService = null;
      _accountManager = null;
      _isInitialized = false;
    }
  }
}
