import 'package:flutter/material.dart';
import '../models/enemy.dart';
import '../models/player.dart';
import '../core/widgets/base_screen.dart';
import '../core/widgets/bottom_navigation.dart';
import 'battle_screen.dart';

/// Screen for selecting an enemy before starting a battle.
/// 
/// This screen displays a list of available enemies with their stats,
/// allowing the player to choose their opponent before entering battle.
/// 
/// Example:
/// ```dart
/// Navigator.push(
///   context,
///   MaterialPageRoute(
///     builder: (context) => EnemySelectionScreen(player: player),
///   ),
/// );
/// ```
class EnemySelectionScreen extends StatefulWidget {
  /// The player who will be fighting
  final Player player;

  const EnemySelectionScreen({
    super.key,
    required this.player,
  });

  @override
  State<EnemySelectionScreen> createState() => _EnemySelectionScreenState();
}

class _EnemySelectionScreenState extends State<EnemySelectionScreen> {
  List<Enemy> _availableEnemies = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAvailableEnemies();
  }

  /// Loads the list of available enemies
  void _loadAvailableEnemies() {
    setState(() {
      _isLoading = true;
    });

    // Create a variety of enemies for selection
    _availableEnemies = [
      EnemyFactory.createWeakEnemy(id: 'enemy_1', name: 'Bandit'),
      EnemyFactory.createWeakEnemy(id: 'enemy_2', name: 'Thief'),
      EnemyFactory.createWeakEnemy(id: 'enemy_3', name: 'Rogue'),
      EnemyFactory.createStrongEnemy(id: 'enemy_4', name: 'Rogue Ninja'),
      EnemyFactory.createStrongEnemy(id: 'enemy_5', name: 'Mercenary'),
      EnemyFactory.createStrongEnemy(id: 'enemy_6', name: 'Assassin'),
      EnemyFactory.createBossEnemy(id: 'enemy_7', name: 'Dark Lord'),
      EnemyFactory.createBossEnemy(id: 'enemy_8', name: 'Shadow Master'),
      EnemyFactory.createBossEnemy(id: 'enemy_9', name: 'Demon King'),
    ];

    setState(() {
      _isLoading = false;
    });
  }

  /// Starts a battle with the selected enemy
  void _startBattle(Enemy enemy) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BattleScreen(
          player: widget.player,
          enemy: enemy,
        ),
      ),
    );
  }

  /// Gets the difficulty color based on enemy type
  Color _getDifficultyColor(EnemyType type) {
    switch (type) {
      case EnemyType.weak:
        return Colors.green;
      case EnemyType.strong:
        return Colors.orange;
      case EnemyType.boss:
        return Colors.red;
    }
  }

  /// Gets the difficulty text based on enemy type
  String _getDifficultyText(EnemyType type) {
    switch (type) {
      case EnemyType.weak:
        return 'Easy';
      case EnemyType.strong:
        return 'Medium';
      case EnemyType.boss:
        return 'Hard';
    }
  }

  /// Gets the enemy icon based on enemy type
  IconData _getEnemyIcon(EnemyType type) {
    switch (type) {
      case EnemyType.weak:
        return Icons.person;
      case EnemyType.strong:
        return Icons.person_pin;
      case EnemyType.boss:
        return Icons.dangerous;
    }
  }

  /// Builds the enemy selection header
  Widget _buildHeader() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Icon(
              Icons.sports_martial_arts,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Choose Your Opponent',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Select an enemy to battle and test your ninja skills!',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the player info card
  Widget _buildPlayerInfo() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.person, color: Colors.blue, size: 24),
            const SizedBox(width: 8),
            Text(
              widget.player.name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade300),
              ),
              child: Text(
                'Level ${widget.player.level}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Spacer(),
            Text(
              'HP: ${widget.player.currentHp}/${widget.player.maxHp}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds an enemy card
  Widget _buildEnemyCard(Enemy enemy) {
    final difficultyColor = _getDifficultyColor(enemy.type);
    final difficultyText = _getDifficultyText(enemy.type);
    final enemyIcon = _getEnemyIcon(enemy.type);

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: () => _startBattle(enemy),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Enemy icon and type
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: difficultyColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: difficultyColor, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: difficultyColor.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Icon(
                  enemyIcon,
                  color: difficultyColor,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              
              // Enemy info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          enemy.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: difficultyColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            difficultyText,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'HP: ${enemy.maxHp} | Attack: ${enemy.attackPower} | Defense: ${enemy.defense}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Battle button
              IconButton(
                onPressed: () => _startBattle(enemy),
                icon: const Icon(Icons.play_arrow, color: Colors.red),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.red.withOpacity(0.2),
                  padding: const EdgeInsets.all(12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the enemy list
  Widget _buildEnemyList() {
    if (_isLoading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.list, color: Colors.grey, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Available Enemies',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._availableEnemies.map((enemy) => _buildEnemyCard(enemy)),
          ],
        ),
      ),
    );
  }

  /// Builds the difficulty legend
  Widget _buildDifficultyLegend() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Difficulty Levels',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildLegendItem(Colors.green, 'Easy', 'Weak enemies'),
                const SizedBox(width: 16),
                _buildLegendItem(Colors.orange, 'Medium', 'Strong enemies'),
                const SizedBox(width: 16),
                _buildLegendItem(Colors.red, 'Hard', 'Boss enemies'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a legend item
  Widget _buildLegendItem(Color color, String label, String description) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: '🥷 Enemy Selection',
      body: Column(
        children: [
          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 16),
                  _buildPlayerInfo(),
                  const SizedBox(height: 16),
                  _buildEnemyList(),
                  const SizedBox(height: 16),
                  _buildDifficultyLegend(),
                ],
              ),
            ),
          ),
          // Bottom navigation
          BottomNavigation(currentRoute: '/battle'),
        ],
      ),
    );
  }
}
