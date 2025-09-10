import 'package:flutter/material.dart';
import '../models/player.dart';
import '../models/enemy.dart';
import '../models/jutsu.dart';
import '../models/item.dart';
import '../core/battle_engine.dart';
import '../core/widgets/base_screen.dart';
import '../services/player_data_manager.dart';
import '../services/mission_manager.dart';

/// A screen that displays the turn-based battle interface.
/// 
/// This screen shows player and enemy stats, action buttons,
/// and a battle log. It integrates with BattleEngine to handle
/// the game logic.
/// 
/// Example:
/// ```dart
/// Navigator.push(
///   context,
///   MaterialPageRoute(
///     builder: (context) => BattleScreen(
///       player: player,
///       enemy: enemy,
///     ),
///   ),
/// );
/// ```
class BattleScreen extends StatefulWidget {
  /// The player participating in the battle
  final Player player;
  
  /// The enemy participating in the battle
  final Enemy enemy;

  const BattleScreen({
    super.key,
    required this.player,
    required this.enemy,
  });

  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen> with TickerProviderStateMixin {
  late BattleEngine _battleEngine;
  late Player _player;
  late Enemy _enemy;
  final ScrollController _scrollController = ScrollController();
  
  // Animation controllers for smooth bar transitions
  late AnimationController _playerHpController;
  late AnimationController _playerChakraController;
  late AnimationController _enemyHpController;
  
  // Animation values for smooth bar updates
  late Animation<double> _playerHpAnimation;
  late Animation<double> _playerChakraAnimation;
  late Animation<double> _enemyHpAnimation;

  @override
  void initState() {
    super.initState();
    // Create copies of the player and enemy to avoid modifying originals
    _player = Player(
      id: widget.player.id,
      name: widget.player.name,
      maxHp: widget.player.maxHp,
      maxChakra: widget.player.maxChakra,
      strength: widget.player.strength,
      defense: widget.player.defense,
      level: widget.player.level,
      xp: widget.player.xp,
      availableJutsu: List.from(widget.player.availableJutsu),
    );
    _enemy = Enemy(
      id: widget.enemy.id,
      name: widget.enemy.name,
      type: widget.enemy.type,
      maxHp: widget.enemy.maxHp,
      attackPower: widget.enemy.attackPower,
      defense: widget.enemy.defense,
    );
    _battleEngine = BattleEngine(player: _player, enemy: _enemy);
    
    // Initialize animation controllers
    _playerHpController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _playerChakraController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _enemyHpController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    // Initialize animations
    _playerHpAnimation = Tween<double>(
      begin: 1.0,
      end: _player.hpPercentage,
    ).animate(CurvedAnimation(
      parent: _playerHpController,
      curve: Curves.easeInOut,
    ));
    
    _playerChakraAnimation = Tween<double>(
      begin: 1.0,
      end: _player.chakraPercentage,
    ).animate(CurvedAnimation(
      parent: _playerChakraController,
      curve: Curves.easeInOut,
    ));
    
    _enemyHpAnimation = Tween<double>(
      begin: 1.0,
      end: _enemy.hpPercentage,
    ).animate(CurvedAnimation(
      parent: _enemyHpController,
      curve: Curves.easeInOut,
    ));
    
    // Start animations at full values
    _playerHpController.forward();
    _playerChakraController.forward();
    _enemyHpController.forward();
  }

  /// Handles player action button presses
  void _onPlayerAction(BattleAction action, {Jutsu? jutsu, String? itemName}) async {
    setState(() {
      _battleEngine.playerAction(action, jutsu: jutsu, itemName: itemName);
      // Update animations to reflect new HP/Chakra values
      _updateAnimations();
      // Auto-scroll to the latest log entry (now at the top)
      _scrollToTop();
    });
    
    // Update mission progress if battle is over
    _updateMissionProgress();
    
    // Save progress after each action
    await _saveProgress();
  }
  
  /// Updates mission progress when battle is over
  void _updateMissionProgress() {
    if (_battleEngine.isBattleOver && _battleEngine.winner == _player.name) {
      // Player won - update combat and training missions
      MissionManager.instance.updateMissionProgress('enemy_defeated', eventData: {
        'enemy_name': _enemy.name,
        'enemy_type': _enemy.type,
      });
      MissionManager.instance.updateMissionProgress('battle_completed', eventData: {
        'battle_result': 'victory',
      });
    }
  }

  /// Updates animation values to reflect current HP/Chakra percentages
  void _updateAnimations() {
    _playerHpAnimation = Tween<double>(
      begin: _playerHpAnimation.value,
      end: _player.hpPercentage,
    ).animate(CurvedAnimation(
      parent: _playerHpController,
      curve: Curves.easeInOut,
    ));
    
    _playerChakraAnimation = Tween<double>(
      begin: _playerChakraAnimation.value,
      end: _player.chakraPercentage,
    ).animate(CurvedAnimation(
      parent: _playerChakraController,
      curve: Curves.easeInOut,
    ));
    
    _enemyHpAnimation = Tween<double>(
      begin: _enemyHpAnimation.value,
      end: _enemy.hpPercentage,
    ).animate(CurvedAnimation(
      parent: _enemyHpController,
      curve: Curves.easeInOut,
    ));
    
    // Restart animations
    _playerHpController.reset();
    _playerHpController.forward();
    _playerChakraController.reset();
    _playerChakraController.forward();
    _enemyHpController.reset();
    _enemyHpController.forward();
  }
  
  /// Scrolls the battle log to the top to show the latest entry
  void _scrollToTop() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0.0, // Scroll to top where newest entries are
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// Resets the battle to initial state
  void _resetBattle() {
    setState(() {
      _battleEngine.resetBattle();
      _updateAnimations();
      _scrollToTop();
    });
  }

  /// Saves the current player progress
  /// 
  /// This method is called after each battle action to ensure progress is saved
  Future<void> _saveProgress() async {
    try {
      // Update the player data manager with the current player state
      await PlayerDataManager.instance.updatePlayer(_player);
      
      // Check if the player leveled up and save level up progress
      if (_battleEngine.battleLog.any((entry) => 
          entry.message.contains('Level up') || 
          entry.message.contains('Unlocked Jutsu'))) {
        await PlayerDataManager.instance.saveLevelUpProgress();
      } else {
        // Save battle progress for regular actions
        await PlayerDataManager.instance.saveBattleProgress();
      }
    } catch (e) {
      print('Error saving progress: $e');
      // Show error to user if needed
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save progress: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    _playerHpController.dispose();
    _playerChakraController.dispose();
    _enemyHpController.dispose();
    super.dispose();
  }

  /// Builds the player stats display with enhanced visual feedback
  Widget _buildPlayerStats() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person, color: Colors.blue, size: 24),
                const SizedBox(width: 8),
                Text(
                  _player.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
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
                    'Level ${_player.level}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildEnhancedStatBar(
              'HP', 
              _player.currentHp, 
              _player.maxHp, 
              Colors.green,
              _playerHpAnimation,
              Icons.favorite,
            ),
            const SizedBox(height: 8),
            _buildEnhancedStatBar(
              'Chakra', 
              _player.currentChakra, 
              _player.maxChakra, 
              Colors.blue,
              _playerChakraAnimation,
              Icons.bolt,
            ),
            const SizedBox(height: 8),
            _buildXpBar(),
            const SizedBox(height: 12),
            Text(
              'Strength: ${_player.strength} | Defense: ${_player.defense}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (_player.isDefending)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.shield, color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'DEFENDING',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Builds the enemy stats display with enhanced visual feedback
  Widget _buildEnemyStats() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.dangerous, color: Colors.red, size: 24),
                const SizedBox(width: 8),
                Text(
                  _enemy.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildEnhancedStatBar(
              'HP', 
              _enemy.currentHp, 
              _enemy.maxHp, 
              Colors.red,
              _enemyHpAnimation,
              Icons.favorite,
            ),
            const SizedBox(height: 12),
            Text(
              'Attack: ${_enemy.attackPower} | Defense: ${_enemy.defense}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (_enemy.isDefending)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.shield, color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'DEFENDING',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Builds an enhanced stat bar widget with smooth animations and visual effects
  Widget _buildEnhancedStatBar(
    String label, 
    int current, 
    int max, 
    Color color,
    Animation<double> animation,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 16),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            Text(
              '$current/$max',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 12,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                return LinearProgressIndicator(
                  value: animation.value,
                  backgroundColor: color.withOpacity(0.4),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 12,
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the XP progress bar
  Widget _buildXpBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 16),
                const SizedBox(width: 4),
                Text(
                  'XP',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade700,
                  ),
                ),
              ],
            ),
            Text(
              '${_player.xp}/${_player.xpToNextLevel}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.amber.shade700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 12,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(
                color: Colors.amber.withOpacity(0.4),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: _player.xpPercentage,
              backgroundColor: Colors.amber.withOpacity(0.4),
              valueColor: AlwaysStoppedAnimation<Color>(Colors.amber.shade600),
              minHeight: 12,
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the action buttons for player actions
  Widget _buildActionButtons() {
    final usableJutsu = _player.getUsableJutsu();
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Choose Your Action',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            // Basic action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _battleEngine.isBattleOver || !_battleEngine.isPlayerTurn
                        ? null
                        : () => _onPlayerAction(BattleAction.attack),
                    icon: const Icon(Icons.flash_on),
                    label: const Text('Attack'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 3,
                      shadowColor: Colors.deepOrange.withOpacity(0.3),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _battleEngine.isBattleOver || !_battleEngine.isPlayerTurn
                        ? null
                        : () => _onPlayerAction(BattleAction.defend),
                    icon: const Icon(Icons.shield),
                    label: const Text('Defend'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 3,
                      shadowColor: Colors.indigo.withOpacity(0.3),
                    ),
                  ),
                ),
              ],
            ),
            // Jutsu buttons
            if (usableJutsu.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Jutsu Abilities',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: usableJutsu.map((jutsu) => _buildJutsuButton(jutsu)).toList(),
              ),
            ],
            // Inventory section
            if (_player.getBattleUsableItems().isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Inventory',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _player.getBattleUsableItems().map((entry) => _buildItemButton(entry)).toList(),
              ),
            ],
            if (_battleEngine.isBattleOver) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _resetBattle,
                icon: const Icon(Icons.refresh),
                label: const Text('New Battle'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  elevation: 3,
                  shadowColor: Colors.green.withOpacity(0.3),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Builds a jutsu button
  Widget _buildJutsuButton(Jutsu jutsu) {
    final canUse = jutsu.canUse(_player.currentChakra);
    
    return SizedBox(
      width: 120,
      child: ElevatedButton(
        onPressed: _battleEngine.isBattleOver || !_battleEngine.isPlayerTurn || !canUse
            ? null
            : () => _onPlayerAction(BattleAction.specificJutsu, jutsu: jutsu),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.purple[600],
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          elevation: 3,
          shadowColor: Colors.purple.withOpacity(0.3),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              jutsu.name,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            Text(
              '${jutsu.chakraCost} CP',
              style: const TextStyle(fontSize: 10),
              textAlign: TextAlign.center,
            ),
            Text(
              '${jutsu.minDamage}-${jutsu.maxDamage} DMG',
              style: const TextStyle(fontSize: 9),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Builds an item button
  Widget _buildItemButton(InventoryEntry entry) {
    final item = entry.item;
    final quantity = entry.quantity;
    final canUse = quantity > 0;
    
    return SizedBox(
      width: 120,
      child: ElevatedButton(
        onPressed: _battleEngine.isBattleOver || !_battleEngine.isPlayerTurn || !canUse
            ? null
            : () => _onPlayerAction(BattleAction.useItem, itemName: item.name),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal[600],
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          elevation: 3,
          shadowColor: Colors.teal.withOpacity(0.3),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              item.name,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            Text(
              'x$quantity',
              style: const TextStyle(fontSize: 10),
              textAlign: TextAlign.center,
            ),
            Text(
              item.description,
              style: const TextStyle(fontSize: 9),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the battle log display with enhanced visual feedback and icons
  Widget _buildBattleLog() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.history, color: Colors.grey, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Battle Log',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Round ${_battleEngine.currentRound}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.shade50,
              ),
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(8),
                // Reverse the list to show newest entries at the top
                itemCount: _battleEngine.battleLog.length,
                itemBuilder: (context, index) {
                  // Reverse index to get newest entries first
                  final reversedIndex = _battleEngine.battleLog.length - 1 - index;
                  final logEntry = _battleEngine.battleLog[reversedIndex];
                  return _buildLogEntry(logEntry, reversedIndex);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Builds an individual log entry with enhanced visual feedback and action icons
  Widget _buildLogEntry(BattleActionResult logEntry, int originalIndex) {
    // Determine the color based on whether it's a player or enemy action
    Color textColor;
    IconData actionIcon;
    String actionEmoji;
    
    if (logEntry.isPlayerAction(_player.name)) {
      textColor = Colors.green.shade700; // All player actions in green
    } else {
      textColor = Colors.red.shade700; // All enemy actions in red
    }
    
    // Special handling for XP, level up, and Jutsu unlock messages
    if (logEntry.message.contains('XP') || 
        logEntry.message.contains('Level up') || 
        logEntry.message.contains('Unlocked Jutsu')) {
      textColor = Colors.green.shade700; // XP and unlock messages in green
    }
    
    // Determine icon and emoji based on action type and message content
    if (logEntry.message.contains('XP') || 
        logEntry.message.contains('Level up') || 
        logEntry.message.contains('Unlocked Jutsu')) {
      actionIcon = Icons.star;
      actionEmoji = '⭐';
    } else {
      switch (logEntry.action) {
        case BattleAction.attack:
          actionIcon = Icons.flash_on;
          actionEmoji = '💥';
          break;
        case BattleAction.defend:
          actionIcon = Icons.shield;
          actionEmoji = '🛡️';
          break;
        case BattleAction.jutsu:
        case BattleAction.specificJutsu:
          actionIcon = Icons.auto_awesome;
          actionEmoji = '🔥';
          break;
        case BattleAction.useItem:
          actionIcon = Icons.local_pharmacy;
          actionEmoji = '💊';
          break;
      }
    }
    
    // Check if this is the first entry of a new round (for visual division)
    final isFirstEntryOfRound = originalIndex == 0 || 
        _battleEngine.battleLog[originalIndex - 1].round != logEntry.round;
    
    return Column(
      children: [
        // Add visual division between rounds
        if (isFirstEntryOfRound && originalIndex > 0) ...[
          const SizedBox(height: 8),
          Divider(
            color: Colors.grey.shade400,
            thickness: 1,
            height: 1,
          ),
          const SizedBox(height: 4),
        ],
        Container(
          margin: const EdgeInsets.symmetric(vertical: 2),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: textColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: textColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Text(
                actionEmoji,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(width: 8),
              Icon(
                actionIcon,
                color: textColor,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  logEntry.getFormattedMessage(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds the battle status display
  Widget _buildBattleStatus() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _battleEngine.isBattleOver 
            ? (_battleEngine.winner == _player.name ? Colors.green : Colors.red)
            : (_battleEngine.isPlayerTurn ? Colors.blue : Colors.orange),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (_battleEngine.isBattleOver 
                ? (_battleEngine.winner == _player.name ? Colors.green : Colors.red)
                : (_battleEngine.isPlayerTurn ? Colors.blue : Colors.orange)).withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        _battleEngine.getBattleStatus(),
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: '🥷 Shinobi Battle',
      body: Column(
        children: [
          // Battle content at the top
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildBattleStatus(),
                  const SizedBox(height: 16),
                  _buildPlayerStats(),
                  const SizedBox(height: 16),
                  _buildEnemyStats(),
                  const SizedBox(height: 16),
                  _buildBattleLog(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          // Action buttons at the bottom
          _buildActionButtons(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
