import 'package:flutter/material.dart';
import 'models/player.dart';
import 'models/item.dart';
import 'services/save_load_service.dart';

/// Test class to verify save/load functionality
/// 
/// This class provides methods to test the save/load system
/// and can be used for debugging and verification.
class SaveLoadTest {
  static final SaveLoadService _saveLoadService = SaveLoadService();

  /// Initializes the test environment
  static Future<void> initialize() async {
    await _saveLoadService.initialize();
  }

  /// Tests saving and loading a player
  static Future<bool> testSaveLoadPlayer() async {
    try {
      // Create a test player
      final testPlayer = Player(
        id: 'test_player_001',
        name: 'Test Player',
        maxHp: 150,
        maxChakra: 75,
        strength: 15,
        defense: 8,
        level: 3,
        xp: 150,
      );

      // Add some items to inventory
      testPlayer.addItem(Item.healingPotion(), quantity: 5);
      testPlayer.addItem(Item.chakraPotion(), quantity: 3);
      testPlayer.addItem(Item.attackBuff(), quantity: 2);

      // Save the player
      final saveResult = await _saveLoadService.savePlayer(testPlayer, slot: 0);
      if (!saveResult) {
        print('❌ Failed to save player');
        return false;
      }

      // Load the player
      final loadedPlayer = await _saveLoadService.loadPlayer(slot: 0);
      if (loadedPlayer == null) {
        print('❌ Failed to load player');
        return false;
      }

      // Verify the loaded player matches the saved player
      bool matches = true;
      
      if (loadedPlayer.id != testPlayer.id) {
        print('❌ Player ID mismatch: ${loadedPlayer.id} != ${testPlayer.id}');
        matches = false;
      }
      
      if (loadedPlayer.name != testPlayer.name) {
        print('❌ Player name mismatch: ${loadedPlayer.name} != ${testPlayer.name}');
        matches = false;
      }
      
      if (loadedPlayer.maxHp != testPlayer.maxHp) {
        print('❌ Player maxHp mismatch: ${loadedPlayer.maxHp} != ${testPlayer.maxHp}');
        matches = false;
      }
      
      if (loadedPlayer.currentHp != testPlayer.currentHp) {
        print('❌ Player currentHp mismatch: ${loadedPlayer.currentHp} != ${testPlayer.currentHp}');
        matches = false;
      }
      
      if (loadedPlayer.maxChakra != testPlayer.maxChakra) {
        print('❌ Player maxChakra mismatch: ${loadedPlayer.maxChakra} != ${testPlayer.maxChakra}');
        matches = false;
      }
      
      if (loadedPlayer.currentChakra != testPlayer.currentChakra) {
        print('❌ Player currentChakra mismatch: ${loadedPlayer.currentChakra} != ${testPlayer.currentChakra}');
        matches = false;
      }
      
      if (loadedPlayer.strength != testPlayer.strength) {
        print('❌ Player strength mismatch: ${loadedPlayer.strength} != ${testPlayer.strength}');
        matches = false;
      }
      
      if (loadedPlayer.defense != testPlayer.defense) {
        print('❌ Player defense mismatch: ${loadedPlayer.defense} != ${testPlayer.defense}');
        matches = false;
      }
      
      if (loadedPlayer.level != testPlayer.level) {
        print('❌ Player level mismatch: ${loadedPlayer.level} != ${testPlayer.level}');
        matches = false;
      }
      
      if (loadedPlayer.xp != testPlayer.xp) {
        print('❌ Player xp mismatch: ${loadedPlayer.xp} != ${testPlayer.xp}');
        matches = false;
      }

      // Verify inventory
      if (loadedPlayer.inventory.length != testPlayer.inventory.length) {
        print('❌ Inventory length mismatch: ${loadedPlayer.inventory.length} != ${testPlayer.inventory.length}');
        matches = false;
      }

      for (final entry in testPlayer.inventory.entries) {
        final loadedEntry = loadedPlayer.inventory[entry.key];
        if (loadedEntry == null) {
          print('❌ Missing inventory item: ${entry.key}');
          matches = false;
        } else if (loadedEntry.quantity != entry.value.quantity) {
          print('❌ Inventory quantity mismatch for ${entry.key}: ${loadedEntry.quantity} != ${entry.value.quantity}');
          matches = false;
        }
      }

      if (matches) {
        print('✅ Save/Load test passed! Player data matches perfectly.');
        print('   Player: ${loadedPlayer.name} (Level ${loadedPlayer.level})');
        print('   HP: ${loadedPlayer.currentHp}/${loadedPlayer.maxHp}');
        print('   Chakra: ${loadedPlayer.currentChakra}/${loadedPlayer.maxChakra}');
        print('   XP: ${loadedPlayer.xp}/${loadedPlayer.xpToNextLevel}');
        print('   Inventory: ${loadedPlayer.inventory.length} items');
      } else {
        print('❌ Save/Load test failed! Player data does not match.');
      }

      return matches;
    } catch (e) {
      print('❌ Save/Load test error: $e');
      return false;
    }
  }

  /// Tests multiple save slots
  static Future<bool> testMultipleSaveSlots() async {
    try {
      // Create test players for different slots
      final player1 = Player(
        id: 'test_player_001',
        name: 'Player 1',
        level: 1,
        xp: 0,
      );
      
      final player2 = Player(
        id: 'test_player_002',
        name: 'Player 2',
        level: 5,
        xp: 200,
      );
      
      final player3 = Player(
        id: 'test_player_003',
        name: 'Player 3',
        level: 10,
        xp: 500,
      );

      // Save players to different slots
      await _saveLoadService.savePlayer(player1, slot: 0);
      await _saveLoadService.savePlayer(player2, slot: 1);
      await _saveLoadService.savePlayer(player3, slot: 2);

      // Load and verify each slot
      final loaded1 = await _saveLoadService.loadPlayer(slot: 0);
      final loaded2 = await _saveLoadService.loadPlayer(slot: 1);
      final loaded3 = await _saveLoadService.loadPlayer(slot: 2);

      bool success = true;
      
      if (loaded1?.name != 'Player 1' || loaded1?.level != 1) {
        print('❌ Slot 0 verification failed');
        success = false;
      }
      
      if (loaded2?.name != 'Player 2' || loaded2?.level != 5) {
        print('❌ Slot 1 verification failed');
        success = false;
      }
      
      if (loaded3?.name != 'Player 3' || loaded3?.level != 10) {
        print('❌ Slot 2 verification failed');
        success = false;
      }

      if (success) {
        print('✅ Multiple save slots test passed!');
        print('   Slot 0: ${loaded1?.name} (Level ${loaded1?.level})');
        print('   Slot 1: ${loaded2?.name} (Level ${loaded2?.level})');
        print('   Slot 2: ${loaded3?.name} (Level ${loaded3?.level})');
      } else {
        print('❌ Multiple save slots test failed!');
      }

      return success;
    } catch (e) {
      print('❌ Multiple save slots test error: $e');
      return false;
    }
  }

  /// Tests save slot info functionality
  static Future<bool> testSaveSlotInfo() async {
    try {
      final slotInfo = _saveLoadService.getSaveSlotInfo();
      
      if (slotInfo.length != 3) {
        print('❌ Expected 3 save slots, got ${slotInfo.length}');
        return false;
      }

      print('✅ Save slot info test passed!');
      for (final info in slotInfo) {
        print('   Slot ${info.slot}: ${info.playerName} (Level ${info.level}) - ${info.hasData ? "Has Data" : "Empty"}');
      }

      return true;
    } catch (e) {
      print('❌ Save slot info test error: $e');
      return false;
    }
  }

  /// Runs all tests
  static Future<void> runAllTests() async {
    print('🧪 Starting Save/Load System Tests...\n');
    
    await initialize();
    
    print('Test 1: Basic Save/Load Player');
    final test1 = await testSaveLoadPlayer();
    print('');
    
    print('Test 2: Multiple Save Slots');
    final test2 = await testMultipleSaveSlots();
    print('');
    
    print('Test 3: Save Slot Info');
    final test3 = await testSaveSlotInfo();
    print('');
    
    final allPassed = test1 && test2 && test3;
    
    if (allPassed) {
      print('🎉 All tests passed! Save/Load system is working correctly.');
    } else {
      print('❌ Some tests failed. Please check the output above.');
    }
  }

  /// Cleans up test resources
  static Future<void> cleanup() async {
    await _saveLoadService.dispose();
  }
}
