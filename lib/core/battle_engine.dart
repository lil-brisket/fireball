import 'dart:math';
import '../models/player.dart';
import '../models/enemy.dart';
import '../models/jutsu.dart';

/// Represents different actions that can be taken in battle
enum BattleAction {
  attack,
  defend,
  jutsu,
  specificJutsu,
  useItem,
}

/// Represents the result of a battle action
class BattleActionResult {
  /// The action that was performed
  final BattleAction action;
  
  /// The actor who performed the action (player or enemy name)
  final String actor;
  
  /// The target of the action (player or enemy name)
  final String target;
  
  /// Damage dealt (0 if no damage)
  final int damage;
  
  /// Whether the action was successful
  final bool success;
  
  /// Additional message about the action result
  final String message;
  
  /// The round number when this action occurred
  final int round;
  
  /// The jutsu used (if applicable)
  final Jutsu? jutsuUsed;
  
  /// The item used (if applicable)
  final String? itemUsed;

  BattleActionResult({
    required this.action,
    required this.actor,
    required this.target,
    this.damage = 0,
    this.success = true,
    this.message = '',
    required this.round,
    this.jutsuUsed,
    this.itemUsed,
  });

  @override
  String toString() {
    final roundPrefix = '[Round $round]';
    if (action == BattleAction.attack) {
      if (success) {
        return '$roundPrefix $actor attacks $target for $damage damage!';
      } else {
        return '$roundPrefix $actor attacks $target but it misses!';
      }
    } else if (action == BattleAction.jutsu) {
      if (success) {
        return '$roundPrefix $actor uses Jutsu on $target for $damage damage!';
      } else {
        return '$roundPrefix $actor attempts Jutsu but fails!';
      }
    } else if (action == BattleAction.specificJutsu) {
      if (success) {
        final jutsuName = jutsuUsed?.name ?? 'Unknown Jutsu';
        return '$roundPrefix $actor uses $jutsuName on $target for $damage damage!';
      } else {
        final jutsuName = jutsuUsed?.name ?? 'Unknown Jutsu';
        return '$roundPrefix $actor attempts $jutsuName but fails!';
      }
    } else if (action == BattleAction.useItem) {
      if (success) {
        final itemName = itemUsed ?? 'Unknown Item';
        return '$roundPrefix $actor uses $itemName! $message';
      } else {
        final itemName = itemUsed ?? 'Unknown Item';
        return '$roundPrefix $actor attempts to use $itemName but fails!';
      }
    } else {
      return '$roundPrefix $actor defends!';
    }
  }
  
  /// Gets the formatted message for display in the battle log
  String getFormattedMessage() {
    final roundPrefix = '[Round $round]';
    if (action == BattleAction.attack) {
      if (success) {
        return '$roundPrefix $actor attacks $target for $damage damage!';
      } else {
        return '$roundPrefix $actor attacks $target but it misses!';
      }
    } else if (action == BattleAction.jutsu) {
      if (success) {
        return '$roundPrefix $actor uses Jutsu on $target for $damage damage!';
      } else {
        return '$roundPrefix $actor attempts Jutsu but fails!';
      }
    } else if (action == BattleAction.specificJutsu) {
      if (success) {
        final jutsuName = jutsuUsed?.name ?? 'Unknown Jutsu';
        return '$roundPrefix $actor uses $jutsuName on $target for $damage damage!';
      } else {
        final jutsuName = jutsuUsed?.name ?? 'Unknown Jutsu';
        return '$roundPrefix $actor attempts $jutsuName but fails!';
      }
    } else if (action == BattleAction.useItem) {
      if (success) {
        final itemName = itemUsed ?? 'Unknown Item';
        return '$roundPrefix $actor uses $itemName! $message';
      } else {
        final itemName = itemUsed ?? 'Unknown Item';
        return '$roundPrefix $actor attempts to use $itemName but fails!';
      }
    } else {
      return '$roundPrefix $actor defends!';
    }
  }
  
  /// Determines if this action was performed by the player
  /// This method should be called with the player name for accurate results
  bool isPlayerAction(String playerName) => actor == playerName;
}

/// Handles turn-based battle logic between a player and enemy.
/// 
/// This class manages the battle state, turn order, and action resolution.
/// It keeps the game logic separate from the UI components.
/// 
/// Example:
/// ```dart
/// final engine = BattleEngine(player: player, enemy: enemy);
/// final result = await engine.playerAction(BattleAction.attack);
/// ```
class BattleEngine {
  /// The player participating in the battle
  final Player player;
  
  /// The enemy participating in the battle
  final Enemy enemy;
  
  /// List of battle action results for logging
  final List<BattleActionResult> battleLog;
  
  /// Whether it's currently the player's turn
  bool isPlayerTurn;
  
  /// Whether the battle has ended
  bool isBattleOver;
  
  /// The winner of the battle (null if battle is ongoing)
  String? winner;
  
  /// Current round number (increments after each player+enemy turn)
  int currentRound;
  
  /// Maximum number of log entries to keep
  static const int maxLogEntries = 50;

  /// Creates a new BattleEngine instance
  /// 
  /// [player] - The player participating in the battle
  /// [enemy] - The enemy participating in the battle
  BattleEngine({
    required this.player,
    required this.enemy,
  }) : battleLog = [],
       isPlayerTurn = true,
       isBattleOver = false,
       winner = null,
       currentRound = 1;

  /// Executes a player action and handles the enemy's response
  /// 
  /// [action] - The action the player wants to perform
  /// [jutsu] - The specific jutsu to use (only for specificJutsu action)
  /// [itemName] - The name of the item to use (only for useItem action)
  /// Returns the result of the player's action
  BattleActionResult playerAction(BattleAction action, {Jutsu? jutsu, String? itemName}) {
    if (isBattleOver || !isPlayerTurn) {
      return BattleActionResult(
        action: action,
        actor: player.name,
        target: enemy.name,
        success: false,
        message: 'Not your turn or battle is over',
        round: currentRound,
      );
    }

    // Reset player's defending state
    player.isDefending = false;

    BattleActionResult result;
    
    switch (action) {
      case BattleAction.attack:
        result = _executePlayerAttack();
        break;
      case BattleAction.defend:
        result = _executePlayerDefend();
        break;
      case BattleAction.jutsu:
        result = _executePlayerJutsu();
        break;
      case BattleAction.specificJutsu:
        if (jutsu == null) {
          result = BattleActionResult(
            action: action,
            actor: player.name,
            target: enemy.name,
            success: false,
            message: 'No jutsu specified',
            round: currentRound,
          );
        } else {
          result = _executePlayerSpecificJutsu(jutsu);
        }
        break;
      case BattleAction.useItem:
        if (itemName == null) {
          result = BattleActionResult(
            action: action,
            actor: player.name,
            target: 'self',
            success: false,
            message: 'No item specified',
            round: currentRound,
          );
        } else {
          result = _executePlayerUseItem(itemName);
        }
        break;
    }

    _addToBattleLog(result);
    isPlayerTurn = false;

    // Check if battle is over after player action
    _checkBattleEnd();

    // If battle is not over, execute enemy turn
    if (!isBattleOver) {
      _executeEnemyTurn();
    }

    return result;
  }

  /// Executes the player's attack action
  BattleActionResult _executePlayerAttack() {
    final damage = player.calculateAttackDamage();
    final actualDamage = enemy.takeDamage(damage);
    
    return BattleActionResult(
      action: BattleAction.attack,
      actor: player.name,
      target: enemy.name,
      damage: actualDamage,
      success: true,
      message: actualDamage > 0 ? 'Hit for $actualDamage damage!' : 'Attack blocked!',
      round: currentRound,
    );
  }

  /// Executes the player's defend action
  BattleActionResult _executePlayerDefend() {
    player.isDefending = true;
    
    return BattleActionResult(
      action: BattleAction.defend,
      actor: player.name,
      target: 'self',
      damage: 0,
      success: true,
      message: 'Defending stance taken!',
      round: currentRound,
    );
  }

  /// Executes the player's jutsu action
  BattleActionResult _executePlayerJutsu() {
    const int jutsuChakraCost = 10;
    
    // Check if player has enough chakra
    if (!player.consumeChakra(jutsuChakraCost)) {
      return BattleActionResult(
        action: BattleAction.jutsu,
        actor: player.name,
        target: enemy.name,
        damage: 0,
        success: false,
        message: 'Not enough chakra!',
        round: currentRound,
      );
    }
    
    // Calculate jutsu damage (15-25 damage range)
    final jutsuDamage = 15 + (DateTime.now().millisecondsSinceEpoch % 11);
    final actualDamage = enemy.takeDamage(jutsuDamage);
    
    return BattleActionResult(
      action: BattleAction.jutsu,
      actor: player.name,
      target: enemy.name,
      damage: actualDamage,
      success: true,
      message: 'Jutsu deals $actualDamage damage!',
      round: currentRound,
    );
  }

  /// Executes the player's specific jutsu action
  BattleActionResult _executePlayerSpecificJutsu(Jutsu jutsu) {
    // Check if player has enough chakra for this jutsu
    if (!player.consumeChakra(jutsu.chakraCost)) {
      return BattleActionResult(
        action: BattleAction.specificJutsu,
        actor: player.name,
        target: enemy.name,
        damage: 0,
        success: false,
        message: 'Not enough chakra for ${jutsu.name}!',
        round: currentRound,
        jutsuUsed: jutsu,
      );
    }
    
    // Calculate jutsu damage using the jutsu's damage range
    final jutsuDamage = jutsu.calculateDamage();
    final actualDamage = enemy.takeDamage(jutsuDamage);
    
    return BattleActionResult(
      action: BattleAction.specificJutsu,
      actor: player.name,
      target: enemy.name,
      damage: actualDamage,
      success: true,
      message: '${jutsu.name} deals $actualDamage damage!',
      round: currentRound,
      jutsuUsed: jutsu,
    );
  }

  /// Executes the player's item usage action
  BattleActionResult _executePlayerUseItem(String itemName) {
    // Check if player has the item
    if (player.getItemQuantity(itemName) <= 0) {
      return BattleActionResult(
        action: BattleAction.useItem,
        actor: player.name,
        target: 'self',
        damage: 0,
        success: false,
        message: 'No $itemName available!',
        round: currentRound,
        itemUsed: itemName,
      );
    }

    // Store HP and Chakra before using item for comparison
    final hpBefore = player.currentHp;
    final chakraBefore = player.currentChakra;
    final attackBefore = player.temporaryAttackBuff;
    final defenseBefore = player.temporaryDefenseBuff;

    // Use the item
    final success = player.useItem(itemName);
    
    if (!success) {
      return BattleActionResult(
        action: BattleAction.useItem,
        actor: player.name,
        target: 'self',
        damage: 0,
        success: false,
        message: 'Failed to use $itemName!',
        round: currentRound,
        itemUsed: itemName,
      );
    }

    // Calculate the effects for the message
    final hpRestored = player.currentHp - hpBefore;
    final chakraRestored = player.currentChakra - chakraBefore;
    final attackGained = player.temporaryAttackBuff - attackBefore;
    final defenseGained = player.temporaryDefenseBuff - defenseBefore;

    String message = '';
    if (hpRestored > 0) {
      message += 'Restored $hpRestored HP! ';
    }
    if (chakraRestored > 0) {
      message += 'Restored $chakraRestored Chakra! ';
    }
    if (attackGained > 0) {
      message += 'Attack increased by $attackGained! ';
    }
    if (defenseGained > 0) {
      message += 'Defense increased by $defenseGained! ';
    }

    return BattleActionResult(
      action: BattleAction.useItem,
      actor: player.name,
      target: 'self',
      damage: 0,
      success: true,
      message: message.trim(),
      round: currentRound,
      itemUsed: itemName,
    );
  }

  /// Executes the enemy's turn with AI decision making based on enemy type
  void _executeEnemyTurn() {
    if (isBattleOver) return;

    BattleActionResult result;
    
    // Different AI behavior based on enemy type
    switch (enemy.type) {
      case EnemyType.weak:
        result = _executeWeakEnemyTurn();
        break;
      case EnemyType.strong:
        result = _executeStrongEnemyTurn();
        break;
      case EnemyType.boss:
        result = _executeBossEnemyTurn();
        break;
    }

    _addToBattleLog(result);
    isPlayerTurn = true;
    
    // Increment round after both player and enemy have acted
    currentRound++;

    // Check if battle is over after enemy action
    _checkBattleEnd();
  }

  /// Executes turn for weak enemies - simple random attacks
  /// Weak enemies have 80% chance to attack, 20% chance to defend
  BattleActionResult _executeWeakEnemyTurn() {
    final shouldDefend = Random().nextDouble() < 0.2;
    
    if (shouldDefend) {
      return _executeEnemyDefend();
    } else {
      return _executeEnemyAttack();
    }
  }

  /// Executes turn for strong enemies - higher damage, occasionally defends
  /// Strong enemies have 60% chance to attack, 40% chance to defend
  /// If HP is below 40%, defend chance increases to 60%
  BattleActionResult _executeStrongEnemyTurn() {
    final defendChance = enemy.hpPercentage < 0.4 ? 0.6 : 0.4;
    final shouldDefend = Random().nextDouble() < defendChance;
    
    if (shouldDefend) {
      return _executeEnemyDefend();
    } else {
      return _executeEnemyAttack();
    }
  }

  /// Executes turn for boss enemies - strong attacks with special effects
  /// Boss enemies have 70% chance to attack, 20% chance to defend, 10% chance for special attack
  /// If HP is below 30%, special attack chance increases to 20%
  BattleActionResult _executeBossEnemyTurn() {
    final specialChance = enemy.hpPercentage < 0.3 ? 0.2 : 0.1;
    final defendChance = 0.2;
    
    final random = Random().nextDouble();
    
    if (random < specialChance) {
      return _executeBossSpecialAttack();
    } else if (random < specialChance + defendChance) {
      return _executeEnemyDefend();
    } else {
      return _executeEnemyAttack();
    }
  }

  /// Executes a special attack for boss enemies
  /// Boss special attacks deal 1.5x normal damage and have special effects
  BattleActionResult _executeBossSpecialAttack() {
    final baseDamage = enemy.calculateAttackDamage();
    final specialDamage = (baseDamage * 1.5).round();
    int actualDamage = specialDamage;
    
    // If player is defending, reduce damage by 25% (less than normal attacks)
    if (player.isDefending) {
      actualDamage = (specialDamage * 0.75).round();
    }
    
    final damageTaken = player.takeDamage(actualDamage);
    
    return BattleActionResult(
      action: BattleAction.attack,
      actor: enemy.name,
      target: player.name,
      damage: damageTaken,
      success: true,
      message: player.isDefending 
          ? 'Boss special attack partially blocked! $damageTaken damage taken.'
          : 'Boss unleashes a devastating special attack for $damageTaken damage!',
      round: currentRound,
    );
  }

  /// Executes the enemy's attack action
  BattleActionResult _executeEnemyAttack() {
    final damage = enemy.calculateAttackDamage();
    int actualDamage = damage;
    
    // If player is defending, reduce damage by 50%
    if (player.isDefending) {
      actualDamage = (damage * 0.5).round();
    }
    
    final damageTaken = player.takeDamage(actualDamage);
    
    return BattleActionResult(
      action: BattleAction.attack,
      actor: enemy.name,
      target: player.name,
      damage: damageTaken,
      success: true,
      message: player.isDefending 
          ? 'Attack partially blocked! $damageTaken damage taken.'
          : 'Hit for $damageTaken damage!',
      round: currentRound,
    );
  }

  /// Executes the enemy's defend action
  BattleActionResult _executeEnemyDefend() {
    enemy.isDefending = true;
    
    return BattleActionResult(
      action: BattleAction.defend,
      actor: enemy.name,
      target: 'self',
      damage: 0,
      success: true,
      message: 'Enemy takes defensive stance!',
      round: currentRound,
    );
  }

  /// Checks if the battle has ended and determines the winner
  void _checkBattleEnd() {
    if (!player.isAlive) {
      isBattleOver = true;
      winner = enemy.name;
      _addToBattleLog(BattleActionResult(
        action: BattleAction.attack,
        actor: enemy.name,
        target: player.name,
        damage: 0,
        success: true,
        message: '${player.name} has been defeated!',
        round: currentRound,
      ));
    } else if (!enemy.isAlive) {
      isBattleOver = true;
      winner = player.name;
      
      // Award XP to player based on enemy type
      final xpGained = _calculateXpReward();
      final leveledUp = player.gainXp(xpGained);
      
      String victoryMessage = '${enemy.name} has been defeated!';
      if (xpGained > 0) {
        victoryMessage += ' Gained $xpGained XP!';
        if (leveledUp) {
          victoryMessage += ' Level up! Now level ${player.level}!';
          
          // Check for Jutsu unlock
          final unlockedJutsu = player.getJutsuUnlockedThisLevel();
          if (unlockedJutsu != null) {
            victoryMessage += ' Unlocked Jutsu: ${unlockedJutsu.name}!';
          }
        }
      }
      
      _addToBattleLog(BattleActionResult(
        action: BattleAction.attack,
        actor: player.name,
        target: enemy.name,
        damage: 0,
        success: true,
        message: victoryMessage,
        round: currentRound,
      ));
    }
  }

  /// Calculates XP reward based on enemy type
  /// 
  /// Weak enemies: 25-35 XP
  /// Strong enemies: 50-70 XP  
  /// Boss enemies: 100-150 XP
  int _calculateXpReward() {
    final random = DateTime.now().millisecondsSinceEpoch % 11; // 0-10
    
    switch (enemy.type) {
      case EnemyType.weak:
        return 25 + random; // 25-35 XP
      case EnemyType.strong:
        return 50 + (random * 2); // 50-70 XP
      case EnemyType.boss:
        return 100 + (random * 5); // 100-150 XP
    }
  }

  /// Adds a battle result to the log and manages log size
  void _addToBattleLog(BattleActionResult result) {
    battleLog.add(result);
    
    // Remove oldest entries if we exceed the maximum
    if (battleLog.length > maxLogEntries) {
      battleLog.removeAt(0);
    }
  }

  /// Resets the battle to initial state
  void resetBattle() {
    player.reset();
    enemy.reset();
    battleLog.clear();
    isPlayerTurn = true;
    isBattleOver = false;
    winner = null;
    currentRound = 1;
  }

  /// Gets the current battle status as a string
  String getBattleStatus() {
    if (isBattleOver) {
      return 'Battle Over! Winner: $winner';
    }
    return isPlayerTurn ? 'Your Turn' : 'Enemy Turn';
  }

  /// Gets the latest battle log entry
  BattleActionResult? getLatestLogEntry() {
    return battleLog.isNotEmpty ? battleLog.last : null;
  }

  /// Gets all battle log entries as formatted strings
  List<String> getBattleLogAsStrings() {
    return battleLog.map((result) => result.toString()).toList();
  }
}
