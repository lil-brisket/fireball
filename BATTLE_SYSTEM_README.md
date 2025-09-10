# 🥷 Shinobi RPG - Battle System

## Overview

The Shinobi RPG battle system is a turn-based combat system inspired by Naruto. Players can attack and defend against enemies in strategic combat encounters.

## Features

- **Turn-based Combat**: Players and enemies take alternating turns
- **Action System**: Attack and Defend actions with different effects
- **Stat System**: HP, Chakra, Strength, and Defense stats
- **Battle Log**: Complete history of all actions taken
- **AI Enemy**: Enemies make intelligent decisions based on their HP

## How to Use

### 1. Start a Battle

```dart
// Create a player
final player = Player(
  id: 'player_001',
  name: 'Naruto',
  maxHp: 100,
  maxChakra: 50,
  strength: 12,
  defense: 6,
);

// Create an enemy
final enemy = Enemy(
  id: 'enemy_001',
  name: 'Bandit',
  maxHp: 80,
  attackPower: 10,
  defense: 4,
);

// Navigate to battle screen
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => BattleScreen(
      player: player,
      enemy: enemy,
    ),
  ),
);
```

### 2. Battle Actions

#### Attack
- Deals damage based on your Strength stat
- Damage is reduced by enemy's Defense
- Random damage variation for unpredictability

#### Defend
- Reduces incoming damage by 50%
- Shows "DEFENDING" status indicator
- Useful when low on HP

### 3. Battle Flow

1. **Player Turn**: Choose Attack or Defend
2. **Action Execution**: Your action is processed
3. **Enemy Turn**: Enemy AI chooses action
4. **Status Update**: HP/Chakra bars update
5. **Battle Log**: Action results are recorded
6. **Repeat**: Continue until someone is defeated

## Game Mechanics

### Stats

- **HP (Hit Points)**: Your health. When it reaches 0, you're defeated
- **Chakra**: Energy for jutsu (future feature)
- **Strength**: Determines attack damage
- **Defense**: Reduces incoming damage

### Damage Calculation

```
Attack Damage = Random(Strength/2, Strength)
Actual Damage = Attack Damage - (Defense/2)
Defending reduces damage by 50%
```

### AI Behavior

- **Normal**: 70% attack, 30% defend
- **Low HP (<30%)**: 50% attack, 50% defend
- **Random**: Adds unpredictability to combat

## File Structure

```
lib/
├── models/
│   ├── player.dart          # Player character model
│   └── enemy.dart           # Enemy character model
├── core/
│   └── battle_engine.dart   # Battle logic and AI
├── screens/
│   └── battle_screen.dart   # Battle UI and interface
└── examples/
    └── battle_example.dart  # Usage examples
```

## Testing

Run the app and tap "Start Battle" to test the battle system:

```bash
flutter run
```

## Future Enhancements

- **Jutsu System**: Use Chakra for special abilities
- **Status Effects**: Poison, paralysis, etc.
- **Multiple Enemies**: Battle multiple foes
- **Equipment**: Weapons and armor that affect stats
- **Animations**: Visual effects for actions
- **Sound Effects**: Audio feedback for combat

## Example Battle

```
🥷 Shinobi RPG - Battle Example

Battle started: Naruto vs Bandit
Naruto: 100/100 HP, 50/50 Chakra
Bandit: 80/80 HP

--- Turn 1 ---
Player action: Naruto attacks Bandit for 8 damage!
Naruto: 100/100 HP
Bandit: 72/80 HP
Status: Enemy Turn

--- Turn 2 ---
Player action: Naruto defends!
Naruto: 100/100 HP
Bandit: 72/80 HP
Status: Your Turn

🎉 Battle Over! Winner: Naruto
```

## Contributing

When adding new features to the battle system:

1. Follow the existing code structure
2. Add comprehensive documentation
3. Include usage examples
4. Test thoroughly
5. Update this README

---

**Happy Battling! 🥷⚔️**
