import '../models/player.dart';
import '../core/jutsu_unlock_manager.dart';

/// Example demonstrating the Jutsu unlock system
/// 
/// This example shows how Jutsu are unlocked as the player levels up
/// and how the system integrates with the battle progression.
void main() {
  print('🥷 Shinobi RPG - Jutsu Unlock System Demo\n');
  
  // Create a new player at level 1
  final player = Player(
    id: 'demo_player',
    name: 'Naruto',
    level: 1,
    xp: 0,
  );
  
  print('Initial Player State:');
  print('Level: ${player.level}');
  print('Available Jutsu: ${player.availableJutsu.map((j) => j.name).join(', ')}');
  print('');
  
  // Simulate leveling up to demonstrate Jutsu unlocks
  for (int targetLevel = 2; targetLevel <= 10; targetLevel++) {
    // Simulate gaining enough XP to level up
    final xpNeeded = player.xpToNextLevel;
    final leveledUp = player.gainXp(xpNeeded);
    
    if (leveledUp) {
      print('🎉 Level Up! Player is now level ${player.level}');
      
      // Check for Jutsu unlock
      final unlockedJutsu = player.getJutsuUnlockedThisLevel();
      if (unlockedJutsu != null) {
        print('✨ Unlocked Jutsu: ${unlockedJutsu.name}');
        print('   Cost: ${unlockedJutsu.chakraCost} CP');
        print('   Damage: ${unlockedJutsu.minDamage}-${unlockedJutsu.maxDamage}');
        print('   Type: ${unlockedJutsu.type.name}');
        print('   Description: ${unlockedJutsu.description}');
      } else {
        print('   No new Jutsu unlocked at this level');
      }
      
      print('Available Jutsu: ${player.availableJutsu.map((j) => j.name).join(', ')}');
      print('');
    }
  }
  
  // Show all available Jutsu at level 10
  print('📋 Complete Jutsu List at Level 10:');
  for (final jutsu in player.availableJutsu) {
    print('• ${jutsu.name} (Level ${_getJutsuLevel(jutsu.name)})');
    print('  Cost: ${jutsu.chakraCost} CP | Damage: ${jutsu.minDamage}-${jutsu.maxDamage} | Type: ${jutsu.type.name}');
  }
  
  // Test Jutsu unlock manager directly
  print('\n🔍 Jutsu Unlock Manager Test:');
  final manager = JutsuUnlockManager();
  print('Total Jutsu available: ${manager.totalJutsuCount}');
  print('Highest unlock level: ${manager.maxJutsuLevel}');
  
  for (int level = 1; level <= 20; level++) {
    final jutsu = manager.getJutsuUnlockedAtLevel(level);
    if (jutsu != null) {
      print('Level $level: ${jutsu.name}');
    }
  }
}

/// Helper function to get the level at which a Jutsu is unlocked
int _getJutsuLevel(String jutsuName) {
  final manager = JutsuUnlockManager();
  for (int level = 1; level <= 20; level++) {
    final jutsu = manager.getJutsuUnlockedAtLevel(level);
    if (jutsu?.name == jutsuName) {
      return level;
    }
  }
  return 0;
}
