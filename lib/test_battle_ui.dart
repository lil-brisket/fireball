import 'package:flutter/material.dart';
import 'models/player.dart';
import 'models/enemy.dart';
import 'models/jutsu.dart';
import 'screens/battle_screen.dart';

/// Test file to verify the enhanced battle UI works correctly.
/// 
/// This file creates a simple test app to demonstrate the improved
/// battle interface with visual feedback, animations, and enhanced styling.
void main() {
  runApp(const BattleUITestApp());
}

class BattleUITestApp extends StatelessWidget {
  const BattleUITestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shinobi RPG - Battle UI Test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const BattleUITestHome(),
    );
  }
}

class BattleUITestHome extends StatelessWidget {
  const BattleUITestHome({super.key});

  @override
  Widget build(BuildContext context) {
    // Create test player with some jutsu
    final player = Player(
      id: 'test_player',
      name: 'Naruto Uzumaki',
      maxHp: 120,
      maxChakra: 80,
      strength: 15,
      defense: 8,
      availableJutsu: [
        Jutsu(
          name: 'Rasengan',
          chakraCost: 20,
          minDamage: 25,
          maxDamage: 35,
          type: JutsuType.ninjutsu,
          description: 'A spinning chakra sphere',
        ),
        Jutsu(
          name: 'Shadow Clone',
          chakraCost: 15,
          minDamage: 10,
          maxDamage: 15,
          type: JutsuType.ninjutsu,
          description: 'Creates shadow clones',
        ),
        Jutsu(
          name: 'Wind Style: Rasenshuriken',
          chakraCost: 40,
          minDamage: 45,
          maxDamage: 60,
          type: JutsuType.ninjutsu,
          description: 'Ultimate wind technique',
        ),
      ],
    );

    // Create test enemy
    final enemy = EnemyFactory.createStrongEnemy(
      id: 'test_enemy',
      name: 'Sasuke Uchiha',
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('🥷 Battle UI Test'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.sports_mma,
              size: 64,
              color: Colors.blue,
            ),
            const SizedBox(height: 16),
            Text(
              'Shinobi RPG - Enhanced Battle UI',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Test the improved battle interface with:',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            const Text('✅ Animated HP/Chakra bars'),
            const Text('✅ Visual action icons and emojis'),
            const Text('✅ Enhanced battle log styling'),
            const Text('✅ Smooth animations and transitions'),
            const Text('✅ Improved visual feedback'),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BattleScreen(
                      player: player,
                      enemy: enemy,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start Battle Test'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                elevation: 4,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Player: ${player.name} (${player.maxHp} HP, ${player.maxChakra} Chakra)',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              'Enemy: ${enemy.name} (${enemy.maxHp} HP)',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
