import '../models/player.dart';
import '../models/enemy.dart';
import '../core/battle_engine.dart';

/// Example demonstrating how to use the BattleEngine class.
/// 
/// This example shows how to create a player and enemy,
/// initialize a battle, and execute turn-based combat.
/// 
/// Usage:
/// ```dart
/// void main() {
///   runBattleExample();
/// }
/// ```
void runBattleExample() {
  print('🥷 Shinobi RPG - Battle Example\n');

  // Create a player
  final player = Player(
    id: 'player_001',
    name: 'Naruto',
    maxHp: 100,
    maxChakra: 50,
    strength: 12,
    defense: 6,
  );

  // Create an enemy using the factory
  final enemy = EnemyFactory.createWeakEnemy(
    id: 'enemy_001',
    name: 'Bandit',
  );

  // Initialize the battle engine
  final battleEngine = BattleEngine(player: player, enemy: enemy);

  print('Battle started: ${player.name} vs ${enemy.name}');
  print('${player.name}: ${player.currentHp}/${player.maxHp} HP, ${player.currentChakra}/${player.maxChakra} Chakra');
  print('${enemy.name}: ${enemy.currentHp}/${enemy.maxHp} HP\n');

  // Simulate a few turns
  int turnCount = 0;
  while (!battleEngine.isBattleOver && turnCount < 10) {
    turnCount++;
    print('--- Turn $turnCount ---');
    
    if (battleEngine.isPlayerTurn) {
      // Player's turn - alternate between attack and defend
      final action = turnCount % 2 == 1 ? BattleAction.attack : BattleAction.defend;
      final result = battleEngine.playerAction(action);
      print('Player action: ${result.toString()}');
    }
    
    // Print current status
    print('${player.name}: ${player.currentHp}/${player.maxHp} HP');
    print('${enemy.name}: ${enemy.currentHp}/${enemy.maxHp} HP');
    print('Status: ${battleEngine.getBattleStatus()}\n');
  }

  // Print final results
  if (battleEngine.isBattleOver) {
    print('🎉 Battle Over! Winner: ${battleEngine.winner}');
  } else {
    print('⏰ Battle timed out after $turnCount turns');
  }

  // Print battle log
  print('\n📜 Battle Log:');
  for (final logEntry in battleEngine.getBattleLogAsStrings()) {
    print('  $logEntry');
  }
}

/// Example of creating different types of players and enemies
void createCharacterExamples() {
  print('\n👥 Character Creation Examples:\n');

  // Create different player types
  final ninja = Player(
    id: 'ninja_001',
    name: 'Sasuke',
    maxHp: 90,
    maxChakra: 60,
    strength: 14,
    defense: 5,
  );

  final taijutsu = Player(
    id: 'taijutsu_001',
    name: 'Rock Lee',
    maxHp: 120,
    maxChakra: 30,
    strength: 18,
    defense: 8,
  );

  // Create different enemy types using the factory
  final weakEnemy = EnemyFactory.createWeakEnemy(
    id: 'weak_001',
    name: 'Bandit',
  );

  final strongEnemy = EnemyFactory.createStrongEnemy(
    id: 'strong_001',
    name: 'Rogue Ninja',
  );

  final bossEnemy = EnemyFactory.createBossEnemy(
    id: 'boss_001',
    name: 'Dark Lord',
  );

  final randomEnemy = EnemyFactory.createRandomEnemy(
    id: 'random_001',
    name: 'Mysterious Foe',
  );

  print('Created characters:');
  print('  $ninja');
  print('  $taijutsu');
  print('  $weakEnemy');
  print('  $strongEnemy');
  print('  $bossEnemy');
  print('  $randomEnemy');
}

/// Example demonstrating battles with different enemy types
void demonstrateEnemyTypes() {
  print('\n⚔️ Enemy Type Battle Examples:\n');

  // Create a player
  final player = Player(
    id: 'player_001',
    name: 'Naruto',
    maxHp: 100,
    maxChakra: 50,
    strength: 12,
    defense: 6,
  );

  // Test each enemy type
  final enemyTypes = [
    {'type': 'Weak Enemy', 'enemy': EnemyFactory.createWeakEnemy(id: 'weak_001', name: 'Bandit')},
    {'type': 'Strong Enemy', 'enemy': EnemyFactory.createStrongEnemy(id: 'strong_001', name: 'Rogue Ninja')},
    {'type': 'Boss Enemy', 'enemy': EnemyFactory.createBossEnemy(id: 'boss_001', name: 'Dark Lord')},
  ];

  for (final enemyData in enemyTypes) {
    final enemyType = enemyData['type'] as String;
    final enemy = enemyData['enemy'] as Enemy;
    
    print('--- $enemyType Battle ---');
    print('Enemy: ${enemy.name} (${enemy.type})');
    print('Stats: ${enemy.currentHp}/${enemy.maxHp} HP, ${enemy.attackPower} ATK, ${enemy.defense} DEF');
    
    // Simulate a few turns to show AI behavior
    final battleEngine = BattleEngine(player: player, enemy: enemy);
    
    for (int i = 0; i < 3 && !battleEngine.isBattleOver; i++) {
      if (battleEngine.isPlayerTurn) {
        final result = battleEngine.playerAction(BattleAction.attack);
        print('  Player: ${result.toString()}');
      }
      print('  Status: ${player.currentHp}/${player.maxHp} HP vs ${enemy.currentHp}/${enemy.maxHp} HP');
    }
    
    print('  AI Behavior: ${_getEnemyBehaviorDescription(enemy.type)}\n');
    
    // Reset for next battle
    player.reset();
  }
}

/// Returns a description of the enemy's AI behavior
String _getEnemyBehaviorDescription(EnemyType type) {
  switch (type) {
    case EnemyType.weak:
      return 'Simple AI: 80% attack, 20% defend';
    case EnemyType.strong:
      return 'Defensive AI: 60% attack, 40% defend (60% defend when HP < 40%)';
    case EnemyType.boss:
      return 'Complex AI: 70% attack, 20% defend, 10% special attack (20% special when HP < 30%)';
  }
}
