# 🥷 Shinobi RPG - Project Rules & Guidelines

> **A Naruto-inspired text-based MMORPG built with Flutter**

## 📋 Table of Contents

- [🌐 Networking & Services](#-networking--services)
- [🧾 Naming Conventions](#-naming-conventions)
- [📄 Documentation & Testing](#-documentation--testing)
- [🔍 Code Quality & Best Practices](#-code-quality--best-practices)
- [🏗️ Project Structure](#️-project-structure)
- [🎮 Game Mechanics Rules](#-game-mechanics-rules)
- [🤖 AI & Coding Behavior Rules](#-ai--coding-behavior-rules)
- [🚀 Future Expansion Rules](#-future-expansion-rules)
- [🚫 Anti-Patterns to Avoid](#-anti-patterns-to-avoid)
- [✅ Quality Checklist](#-quality-checklist)

---

## 🌐 Networking & Services

### API Architecture
- **Location**: Place all API-related code under `/lib/services/`
- **HTTP Client**: Use `dio` package for robust HTTP handling with interceptors
- **Error Handling**: Implement comprehensive error handling for all network requests
- **Status Codes**: Handle all HTTP status codes appropriately (200, 400, 401, 403, 404, 500, etc.)
- **Interceptors**: Use interceptors for:
  - Authentication token management
  - Request/response logging
  - Error handling and retry logic
  - Request timeout management

### Service Design
- **Stateless Services**: Keep all services stateless and inject them via providers
- **Error Handling**: Implement proper error handling with custom exception types
- **Retry Logic**: Implement exponential backoff for failed requests
- **HTTP Methods**: Use appropriate HTTP methods (GET, POST, PUT, DELETE, PATCH)
- **Logging**: Implement comprehensive request/response logging for debugging
- **Caching**: Implement proper caching strategies for frequently accessed data

### Example Service Structure
```dart
// lib/services/api_service.dart
class ApiService {
  static const String baseUrl = 'https://api.shinobi-rpg.com';
  
  Future<Result<PlayerData, ApiError>> getPlayerData(String playerId) async {
    // Implementation with proper error handling
  }
}
```

---

## 🧾 Naming Conventions

### File Naming
- **Format**: Use `snake_case.dart` for all file names
- **Grouping**: Group related files with consistent prefixes
- **Descriptive**: Use descriptive names that clearly indicate file purpose
- **Examples**:
  - `player_model.dart`
  - `battle_engine.dart`
  - `jutsu_service.dart`
  - `hp_bar_widget.dart`

### Code Naming
- **Classes**: Use `PascalCase` for class names
  ```dart
  class PlayerModel { }
  class BattleEngine { }
  class JutsuService { }
  ```
- **Variables**: Use `camelCase` for variable names
  ```dart
  String playerName = 'Naruto';
  int currentHp = 100;
  bool isInBattle = false;
  ```
- **Constants**: Define constants in `UPPER_CASE`
  ```dart
  static const int MAX_HP = 1000;
  static const String API_BASE_URL = 'https://api.shinobi-rpg.com';
  ```
- **Enums**: Name enums using `PascalCase`
  ```dart
  enum JutsuType { Ninjutsu, Taijutsu, Genjutsu }
  enum BattleStatus { Active, Defeated, Escaped }
  ```
- **Private Members**: Use underscore prefix for private members
  ```dart
  String _playerId;
  int _currentChakra;
  ```

### Function Naming
- **Descriptive**: Use descriptive, action-oriented names
- **Pattern**: Follow verb-noun pattern for functions
- **Boolean**: Use "is", "has", "can" prefixes for boolean functions
- **Examples**:
  ```dart
  void attackEnemy(Enemy enemy) { }
  bool canUseJutsu(Jutsu jutsu) { }
  bool hasEnoughChakra(int cost) { }
  PlayerData getPlayerData(String id) { }
  ```

---

## 📄 Documentation & Testing

### Code Documentation
- **Models**: Include comprehensive docstrings for all model classes
- **Functions**: Document all public functions with clear descriptions
- **Complex Logic**: Use clear, concise comments for complex business logic
- **TODOs**: Add TODO comments for stubbed or incomplete features
- **Examples**: Provide usage examples for complex functions

### Documentation Format
```dart
/// Represents a player in the Shinobi RPG game.
/// 
/// This class contains all player-related data including stats,
/// inventory, and battle information.
/// 
/// Example:
/// ```dart
/// final player = PlayerModel(
///   id: 'player_123',
///   name: 'Naruto',
///   level: 1,
///   hp: 100,
/// );
/// ```
class PlayerModel {
  /// The unique identifier for this player
  final String id;
  
  /// The player's display name
  final String name;
  
  /// Current hit points (0-1000)
  final int hp;
}
```

### Testing Requirements
- **Unit Tests**: Generate comprehensive unit tests for all models and services
- **Widget Tests**: Implement widget tests for all UI components
- **Integration Tests**: Create integration tests for complete user flows
- **Mocking**: Use proper mocking strategies for external dependencies
- **Coverage**: Maintain minimum 80% test coverage for core business logic

### Test Structure
```dart
// test/models/player_model_test.dart
void main() {
  group('PlayerModel', () {
    test('should create player with valid data', () {
      // Test implementation
    });
    
    test('should throw exception for invalid HP', () {
      // Test implementation
    });
  });
}
```

---

## 🔍 Code Quality & Best Practices

### Code Review Standards
- **Readability**: Prioritize code readability and maintainability
- **Performance**: Consider performance implications of all changes
- **DRY Principle**: Follow Don't Repeat Yourself principle
- **SOLID Principles**: Apply SOLID principles for scalable architecture
- **Simplicity**: Prioritize simplicity over premature optimization

### Programming Patterns
- **Functional**: Prioritize functional and declarative programming patterns
- **Immutable**: Use immutable data structures when possible
- **Error Handling**: Implement proper error handling with Result types
- **Dependency Injection**: Use proper dependency injection patterns
- **State Management**: Implement clean state management with BLoC pattern

### Code Organization
- **Explicit Names**: Use explicit, descriptive variable names
- **Modularization**: Emphasize modularization to follow DRY principles
- **Abstraction**: Minimize code duplication through proper abstraction
- **Clean Code**: Leave no TODO comments or placeholders in production code

### Performance Considerations
- **Const Constructors**: Use `const` constructors where appropriate
- **ListView Optimization**: Implement proper list view optimization
- **State Management**: Use proper state management patterns
- **Rebuilds**: Avoid unnecessary rebuilds in widgets
- **Memory Management**: Implement proper memory management

---

## 🏗️ Project Structure

```
lib/
├── main.dart                    # Main entry point
├── core/                        # Core functionality
│   ├── constants/              # App constants
│   ├── theme/                  # App theming
│   ├── utils/                  # Utility functions
│   └── widgets/                # Reusable UI components
├── features/                    # Feature-based organization
│   ├── player/                 # Player-related features
│   │   ├── data/              # Data layer
│   │   ├── domain/            # Business logic
│   │   └── presentation/      # UI layer
│   ├── battle/                 # Battle system
│   ├── jutsu/                  # Jutsu system
│   └── inventory/              # Inventory management
├── models/                      # Data models
│   ├── player_model.dart
│   ├── enemy_model.dart
│   ├── jutsu_model.dart
│   └── item_model.dart
├── services/                    # Backend integration
│   ├── api_service.dart
│   ├── auth_service.dart
│   └── storage_service.dart
├── widgets/                     # Reusable UI components
│   ├── hp_bar_widget.dart
│   ├── chakra_bar_widget.dart
│   └── battle_log_widget.dart
└── screens/                     # UI screens
    ├── battle_screen.dart
    ├── menu_screen.dart
    └── shop_screen.dart
```

---

## 🎮 Game Mechanics Rules

### Core Combat System
- **Turn-Based**: Implement turn-based combat system
- **Player Turn**: Player chooses action (Attack, Defend, Jutsu, Item)
- **Enemy Turn**: AI selects action using weighted randomness
- **Stats Tracking**: Track HP, Chakra, StatusEffects for all entities
- **Battle Log**: Update battle log after each action

### AI Behavior
- **Predictable**: Enemy AI must be predictable but not boring
- **Randomness**: Include randomness in attack patterns
- **Conditional**: Implement conditional decisions (e.g., defend if HP < 30%)
- **Weighted**: Use weighted randomness for action selection

### Jutsu System
- **Chakra Cost**: Each Jutsu has specific Chakra cost
- **Effects**: Define clear effects for each Jutsu
- **Cooldowns**: Implement cooldown system for balance
- **Mastery**: Track Jutsu mastery levels (10 for normal, 15 for bloodline)

### Stat System
- **Core Stats**: 5 core stats (Strength, Intelligence, Speed, Defense, Willpower) with max 250k
- **Combat Stats**: 4 combat stats with max 500k
- **Elements**: Dual element system with hybrids
- **Progression**: Implement proper stat progression and caps

---

## 🤖 AI & Coding Behavior Rules

### Development Approach
- **Modular**: Write modular functions/classes for each mechanic
- **Examples**: Provide usage examples for every new class/function
- **Separation**: Keep game logic separate from UI updates
- **Reusability**: Refactor code to reusable components whenever possible
- **Documentation**: Explain fixes clearly if errors occur

### Flutter Best Practices
- **StatelessWidget**: Use for static UI components
- **StatefulWidget**: Use for dynamic UI components
- **Separation**: Keep UI and business logic separate
- **Naming**: Follow Flutter naming conventions
- **Structure**: Follow project folder structure

### Code Quality
- **Incremental**: Avoid complex features in one commit
- **Testing**: Write tests for all new functionality
- **Documentation**: Document all public APIs
- **Performance**: Consider performance implications
- **Accessibility**: Implement accessibility features

---

## 🚀 Future Expansion Rules

### Multiplayer Features
- **PvP**: Implement PvP multiplayer using Firebase Realtime Database
- **Backend**: Consider Node.js backend for complex game logic
- **Real-time**: Implement real-time battle synchronization
- **Matchmaking**: Create matchmaking system for PvP battles

### Content Generation
- **Missions**: Generate missions and quests using AI-assisted backend
- **Procedural**: Implement procedural content generation
- **Balancing**: Use AI for game balance optimization
- **Events**: Create dynamic events and challenges

### Progression Systems
- **Inventory**: Implement comprehensive inventory system
- **Leveling**: Create leveling and progression mechanics
- **Clans**: Implement clan system with benefits
- **Housing**: Add player housing and customization

### Visual Polish
- **Animations**: Add smooth animations for all interactions
- **Effects**: Implement particle effects for Jutsu
- **UI**: Create polished UI with proper theming
- **Responsive**: Ensure responsive design for all screen sizes

### Cloud Features
- **Save**: Implement cloud save support for player data
- **Sync**: Add cross-device synchronization
- **Backup**: Create automatic backup system
- **Recovery**: Implement data recovery mechanisms

---

## 🚫 Anti-Patterns to Avoid

### Code Anti-Patterns
- ❌ Don't hardcode values in widgets
- ❌ Don't mix business logic with UI code
- ❌ Don't create overly complex widgets
- ❌ Don't ignore error handling
- ❌ Don't use global state management
- ❌ Don't create circular dependencies
- ❌ Don't ignore accessibility requirements

### Game Design Anti-Patterns
- ❌ Don't make AI completely random
- ❌ Don't ignore game balance
- ❌ Don't create overly complex mechanics
- ❌ Don't ignore player feedback
- ❌ Don't skip testing new features
- ❌ Don't ignore performance implications

### Architecture Anti-Patterns
- ❌ Don't create god classes
- ❌ Don't ignore separation of concerns
- ❌ Don't create tight coupling
- ❌ Don't ignore dependency injection
- ❌ Don't skip proper error handling
- ❌ Don't ignore code reusability

---

## ✅ Quality Checklist

### Before Committing Code
- [ ] Code follows naming conventions
- [ ] No hardcoded data in widgets
- [ ] Proper error handling implemented
- [ ] Tests written for new functionality
- [ ] Documentation updated
- [ ] No TODO comments left
- [ ] Code is properly modularized
- [ ] Performance considerations addressed
- [ ] Accessibility requirements met
- [ ] Code review completed

### Before Releasing Features
- [ ] All tests passing
- [ ] Performance benchmarks met
- [ ] User experience tested
- [ ] Game balance verified
- [ ] Documentation complete
- [ ] Error handling comprehensive
- [ ] Accessibility features implemented
- [ ] Cross-platform compatibility verified

### Before Major Releases
- [ ] Full regression testing completed
- [ ] Performance optimization verified
- [ ] Security audit completed
- [ ] User acceptance testing passed
- [ ] Documentation updated
- [ ] Migration scripts tested
- [ ] Rollback plan prepared
- [ ] Monitoring and logging implemented

---

## 📚 Additional Resources

### Flutter Best Practices
- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- [Flutter Testing Guide](https://docs.flutter.dev/testing)

### Game Development
- [Game Design Patterns](https://gameprogrammingpatterns.com/)
- [Flutter Game Development](https://docs.flutter.dev/development/platform-integration/game-development)

### Project Management
- [Conventional Commits](https://www.conventionalcommits.org/)
- [Semantic Versioning](https://semver.org/)

---

**Last Updated**: December 2024  
**Version**: 1.0.0  
**Maintainer**: Development Team
