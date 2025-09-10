# 🎮 Save/Load System Documentation

## Overview

The Shinobi RPG save/load system provides persistent storage for player progress using Hive, a lightweight and fast NoSQL database for Flutter. This system ensures that player data, inventory, and progress are maintained between app sessions.

## 🏗️ Architecture

### Core Components

1. **SaveLoadService** (`lib/services/save_load_service.dart`)
   - Manages Hive database operations
   - Handles save/load operations for player data
   - Supports multiple save slots (0-2)
   - Provides save slot management and information

2. **PlayerDataManager** (`lib/services/player_data_manager.dart`)
   - Singleton service for global player state management
   - Integrates with SaveLoadService
   - Provides automatic saving after game events
   - Manages player creation and loading

3. **Hive Adapters** (Generated files)
   - `lib/models/item.g.dart`
   - `lib/models/jutsu.g.dart`
   - `lib/models/player.g.dart`
   - Serialize/deserialize model objects for storage

## 📊 Data Persistence

### Saved Data

The system saves the following player data:

- **Core Stats**: HP, Chakra, Level, XP, Strength, Defense
- **Progress**: Current XP, XP to next level, unlocked Jutsu
- **Inventory**: Items and quantities
- **Battle State**: Current HP/Chakra, temporary buffs
- **Player Info**: ID, name, level progression

### Save Slots

- **Slot 0**: Primary save slot (auto-saved)
- **Slot 1**: Secondary save slot
- **Slot 2**: Tertiary save slot
- Each slot can store a complete player profile

## 🔧 Implementation Details

### Model Serialization

All models are annotated with Hive annotations:

```dart
@HiveType(typeId: 5)
class Player {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  // ... other fields
}
```

### Save Operations

```dart
// Save player to slot 0 (primary)
await PlayerDataManager.instance.saveCurrentPlayer();

// Save player to specific slot
await PlayerDataManager.instance.saveCurrentPlayer(slot: 1);

// Save after specific events
await PlayerDataManager.instance.saveBattleProgress();
await PlayerDataManager.instance.saveInventoryProgress();
await PlayerDataManager.instance.saveLevelUpProgress();
```

### Load Operations

```dart
// Load from primary slot
final player = await PlayerDataManager.instance.loadCurrentPlayer();

// Load from specific slot
final player = await PlayerDataManager.instance.loadPlayerFromSlot(1);

// Check if save data exists
final hasData = PlayerDataManager.instance.hasSaveData(slot: 0);
```

## 🎯 Usage Examples

### Basic Save/Load

```dart
// Initialize the system
await PlayerDataManager.instance.initialize();

// Create a new player
final player = await PlayerDataManager.instance.createNewPlayer(
  id: 'player_001',
  name: 'Naruto',
  level: 1,
);

// Player data is automatically saved
// Access current player
final currentPlayer = PlayerDataManager.instance.currentPlayer;
```

### Battle Integration

```dart
// In BattleScreen, after each action
await PlayerDataManager.instance.updatePlayer(player);
await PlayerDataManager.instance.saveBattleProgress();
```

### Inventory Management

```dart
// In InventoryScreen, after item changes
await PlayerDataManager.instance.saveInventoryProgress();
```

## 🧪 Testing

### Test Suite

The system includes comprehensive tests in `lib/test_save_load.dart`:

1. **Basic Save/Load Test**: Verifies player data integrity
2. **Multiple Save Slots Test**: Tests slot management
3. **Save Slot Info Test**: Verifies slot information retrieval

### Running Tests

```dart
// Run all tests
await SaveLoadTest.runAllTests();

// Run individual tests
await SaveLoadTest.testSaveLoadPlayer();
await SaveLoadTest.testMultipleSaveSlots();
await SaveLoadTest.testSaveSlotInfo();
```

### Test Screen

Access the test screen from the main menu to run tests interactively and verify the save/load system functionality.

## 🔄 Automatic Saving

The system automatically saves progress in the following scenarios:

1. **After Battle Actions**: Every player action in battle
2. **After Level Up**: When player gains a level or unlocks new Jutsu
3. **After Inventory Changes**: When items are used or added
4. **After Player Updates**: When player data is modified

## 🛠️ Configuration

### Dependencies

```yaml
dependencies:
  hive: ^2.2.3
  hive_flutter: ^1.1.0

dev_dependencies:
  hive_generator: ^2.0.1
  build_runner: ^2.4.7
```

### Code Generation

After adding Hive annotations, run:

```bash
flutter packages pub run build_runner build
```

## 📱 UI Integration

### Main Menu

- Displays current player information
- Shows save/load status
- Provides access to inventory and battle screens

### Battle Screen

- Automatically saves after each action
- Preserves battle progress
- Handles level up saves

### Inventory Screen

- Manages item usage
- Saves inventory changes
- Displays player stats

### Test Screen

- Runs save/load tests
- Displays test results
- Verifies system functionality

## 🚀 Future Enhancements

### Planned Features

1. **Cloud Save**: Integration with cloud storage services
2. **Save Slot Management**: UI for managing multiple save slots
3. **Data Migration**: Version management for save data
4. **Backup/Restore**: Export/import save data
5. **Auto-Save Settings**: Configurable auto-save intervals

### Performance Optimizations

1. **Lazy Loading**: Load save data only when needed
2. **Compression**: Compress save data for storage efficiency
3. **Incremental Saves**: Save only changed data
4. **Background Saving**: Save data in background threads

## 🐛 Troubleshooting

### Common Issues

1. **Save Data Not Loading**: Check Hive initialization
2. **Data Corruption**: Verify model annotations
3. **Performance Issues**: Check save frequency
4. **Memory Leaks**: Ensure proper disposal of services

### Debug Tools

- Use the test screen to verify functionality
- Check console output for error messages
- Verify Hive adapters are generated correctly

## 📋 Best Practices

1. **Always Initialize**: Call `PlayerDataManager.instance.initialize()` at app start
2. **Handle Errors**: Wrap save/load operations in try-catch blocks
3. **Save Frequently**: Save after important game events
4. **Test Thoroughly**: Use the test suite to verify functionality
5. **Clean Up**: Dispose of services when no longer needed

## 🔒 Data Security

- Save data is stored locally on device
- No sensitive data is transmitted
- Data is encrypted by Hive by default
- Backup data can be exported/imported securely

---

**Last Updated**: December 2024  
**Version**: 1.0.0  
**Maintainer**: Development Team
