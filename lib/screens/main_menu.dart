import 'package:flutter/material.dart';
import '../models/player.dart';
import '../services/player_data_manager.dart';
import 'battle_screen.dart';
import 'inventory_screen.dart';
import 'mission_screen.dart';
import 'settings_screen.dart';
import 'profile_screen.dart';
import 'enemy_selection_screen.dart';
import '../models/enemy.dart';

/// Main menu screen for the Shinobi RPG game.
/// 
/// This screen provides navigation to different game features including
/// battle system, inventory management, missions, and settings.
/// It displays the current player's stats and provides quick access
/// to all major game areas.
/// 
/// Example:
/// ```dart
/// Navigator.push(
///   context,
///   MaterialPageRoute(
///     builder: (context) => const MainMenuScreen(),
///   ),
/// );
/// ```
class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  Player? _player;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlayer();
  }

  /// Loads the current player from the data manager
  Future<void> _loadPlayer() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Ensure PlayerDataManager is initialized
      if (!PlayerDataManager.instance.isInitialized) {
        await PlayerDataManager.instance.initialize();
      }

      // Get the current player
      final player = PlayerDataManager.instance.currentPlayer;
      
      setState(() {
        _player = player;
        _isLoading = false;
      });

      // Debug logging
      print('DEBUG: MainMenu - Player loaded: ${player?.name ?? "null"}');
      print('DEBUG: MainMenu - Player ID: ${player?.id ?? "null"}');
    } catch (e) {
      print('ERROR: Failed to load player in MainMenu: $e');
      setState(() {
        _player = null;
        _isLoading = false;
      });
    }
  }

  /// Navigates to the enemy selection screen
  void _startBattle() {
    print('DEBUG: Start Battle button pressed');
    if (_player == null) {
      print('ERROR: Cannot start battle - no player data');
      return;
    }

    print('DEBUG: Navigating to EnemySelectionScreen');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EnemySelectionScreen(player: _player!),
      ),
    );
  }

  /// Navigates to the inventory screen
  void _openInventory() {
    print('DEBUG: Inventory button pressed');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const InventoryScreen(),
      ),
    );
  }

  /// Navigates to the missions screen
  void _openMissions() {
    print('DEBUG: Missions button pressed');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MissionScreen(),
      ),
    );
  }

  /// Navigates to the profile screen
  void _openProfile() {
    print('DEBUG: Profile button pressed');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProfileScreen(),
      ),
    );
  }

  /// Navigates to the settings screen
  void _openSettings() {
    print('DEBUG: Settings button pressed');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    );
  }

  /// Builds the player stats display card
  Widget _buildPlayerStatsCard() {
    if (_player == null) {
      return Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Icon(
                Icons.person_outline,
                size: 48,
                color: Colors.grey,
              ),
              const SizedBox(height: 8),
              Text(
                'No Player Data',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
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
                const Icon(Icons.person, color: Colors.blue, size: 24),
                const SizedBox(width: 8),
                Text(
                  _player!.name,
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
                    'Level ${_player!.level}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatDisplay(
                    'HP',
                    '${_player!.currentHp}/${_player!.maxHp}',
                    Colors.green,
                    Icons.favorite,
                    _player!.hpPercentage,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatDisplay(
                    'Chakra',
                    '${_player!.currentChakra}/${_player!.maxChakra}',
                    Colors.blue,
                    Icons.bolt,
                    _player!.chakraPercentage,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatDisplay(
                    'XP',
                    '${_player!.xp}/${_player!.xpToNextLevel}',
                    Colors.amber,
                    Icons.star,
                    _player!.xpPercentage,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatDisplay(
                    'Items',
                    '${_player!.inventory.length}',
                    Colors.purple,
                    Icons.inventory,
                    1.0, // Always full for item count
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a stat display widget with progress bar
  Widget _buildStatDisplay(String label, String value, Color color, IconData icon, double percentage) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: percentage,
            backgroundColor: color.withOpacity(0.4),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 4,
          ),
        ],
      ),
    );
  }

  /// Builds the main action buttons
  Widget _buildActionButtons() {
    return Column(
      children: [
        // Primary action row
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'Start Battle',
                Icons.flash_on,
                Colors.red,
                _startBattle,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionButton(
                'Inventory',
                Icons.inventory,
                Colors.blue,
                _openInventory,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Secondary action row
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'Missions',
                Icons.assignment,
                Colors.green,
                _openMissions,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionButton(
                'Profile',
                Icons.person,
                Colors.purple,
                _openProfile,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Tertiary action row
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'Settings',
                Icons.settings,
                Colors.grey,
                _openSettings,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Container(), // Empty space for symmetry
            ),
          ],
        ),
      ],
    );
  }

  /// Builds an individual action button
  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  /// Builds a debug card to help troubleshoot player loading issues
  Widget _buildDebugCard() {
    return Card(
      elevation: 4,
      color: Colors.orange[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.bug_report, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  'Debug Information',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.orange[800],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Player Data Status: ${_player == null ? "Not Loaded" : "Loaded"}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              'PlayerDataManager Initialized: ${PlayerDataManager.instance.isInitialized}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loadPlayer,
              child: const Text('Reload Player Data'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('🥷 Shinobi RPG'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPlayer,
            tooltip: 'Refresh Player Data',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Welcome message
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const Icon(
                      Icons.sports_martial_arts,
                      size: 64,
                      color: Colors.deepPurple,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Welcome to Shinobi RPG',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'A Naruto-inspired text-based MMORPG',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Player stats
            _buildPlayerStatsCard(),
            
            const SizedBox(height: 20),
            
            // Action buttons
            _buildActionButtons(),
            
            const SizedBox(height: 20),
            
            // Debug info card (only show if player is null)
            if (_player == null) _buildDebugCard(),
            
            // Quick info card
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text(
                          'Quick Info',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Use the buttons above to navigate between different game areas. '
                      'Start with a battle to test your skills, manage your inventory, '
                      'or take on missions to earn rewards!',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
