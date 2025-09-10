import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/player.dart';
import '../models/account.dart';
import '../services/player_data_manager.dart';
import '../services/account_manager.dart';
import 'landing_screen.dart';
import 'inventory_screen.dart';
import 'profile_screen.dart';
import 'map_screen.dart';
import 'village_hub_screen.dart';

/// Main starter page with bottom navigation tabs for the Shinobi RPG game.
/// 
/// This screen serves as the central hub after login, providing navigation
/// to all major game features through a tabbed interface.
/// 
/// Tabs:
/// - Home: Player summary and recent activity
/// - Village Hub: Access to all game locations
/// - Map: World map (placeholder)
/// - Inventory: Player's items
/// - Profile: Player information (with Settings integrated)
class StarterPage extends StatefulWidget {
  const StarterPage({super.key});

  @override
  State<StarterPage> createState() => _StarterPageState();
}

class _StarterPageState extends State<StarterPage> with TickerProviderStateMixin {
  int _currentIndex = 0;
  Player? _player;
  Account? _account;
  bool _isLoading = true;

  // Animation controllers
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // Reactive state listeners
  late ValueNotifier<int> _walletRyoNotifier;
  late ValueNotifier<int> _bankRyoNotifier;
  late ValueNotifier<int> _xpNotifier;
  late ValueNotifier<int> _levelNotifier;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeReactiveState();
    _loadPlayerData();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _removeReactiveListeners();
    super.dispose();
  }

  /// Initializes reactive state listeners
  void _initializeReactiveState() {
    final playerManager = PlayerDataManager.instance;
    _walletRyoNotifier = playerManager.walletRyoNotifier;
    _bankRyoNotifier = playerManager.bankRyoNotifier;
    _xpNotifier = playerManager.xpNotifier;
    _levelNotifier = playerManager.levelNotifier;

    // Add listeners for reactive updates
    _walletRyoNotifier.addListener(_onPlayerDataChanged);
    _bankRyoNotifier.addListener(_onPlayerDataChanged);
    _xpNotifier.addListener(_onPlayerDataChanged);
    _levelNotifier.addListener(_onPlayerDataChanged);
  }

  /// Removes reactive state listeners
  void _removeReactiveListeners() {
    _walletRyoNotifier.removeListener(_onPlayerDataChanged);
    _bankRyoNotifier.removeListener(_onPlayerDataChanged);
    _xpNotifier.removeListener(_onPlayerDataChanged);
    _levelNotifier.removeListener(_onPlayerDataChanged);
  }

  /// Called when player data changes reactively
  void _onPlayerDataChanged() {
    if (mounted) {
      setState(() {
        // Update local player reference
        _player = PlayerDataManager.instance.currentPlayer;
      });
    }
  }

  /// Initializes animation controllers
  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    _fadeController.forward();
  }

  /// Loads player and account data
  Future<void> _loadPlayerData() async {
    try {
      final player = PlayerDataManager.instance.currentPlayer;
      final account = AccountManager.instance.currentAccount;
      
      setState(() {
        _player = player;
        _account = account;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading player data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Handles logout
  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await AccountManager.instance.clearCurrentAccount();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const LandingScreen(),
          ),
          (route) => false,
        );
      }
    }
  }

  /// Builds the home tab content
  Widget _buildHomeTab() {
    if (_player == null || _account == null) {
      return const Center(
        child: Text('No player data available'),
      );
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Player Summary Card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.blue.shade100,
                          child: Text(
                            _account!.displayName.isNotEmpty 
                                ? _account!.displayName[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _account!.displayName,
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '@${_account!.username}',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              ValueListenableBuilder<int>(
                                valueListenable: _levelNotifier,
                                builder: (context, level, child) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade100,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.blue.shade300),
                                    ),
                                    child: Text(
                                      'Level $level',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Colors.blue.shade700,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Stats Grid
                    Row(
                      children: [
                        Expanded(
                          child: ValueListenableBuilder<int>(
                            valueListenable: _xpNotifier,
                            builder: (context, xp, child) {
                              final xpToNext = _player?.xpToNextLevel ?? 100;
                              final percentage = xp / xpToNext;
                              return _buildStatCard(
                                'XP',
                                '$xp/$xpToNext',
                                Colors.amber,
                                Icons.star,
                                percentage,
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ValueListenableBuilder<int>(
                            valueListenable: _walletRyoNotifier,
                            builder: (context, walletRyo, child) {
                              return _buildStatCard(
                                'Wallet',
                                '$walletRyo Ryo',
                                Colors.orange,
                                Icons.account_balance_wallet,
                                1.0,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ValueListenableBuilder<int>(
                            valueListenable: _bankRyoNotifier,
                            builder: (context, bankRyo, child) {
                              return _buildStatCard(
                                'Bank',
                                '$bankRyo Ryo',
                                Colors.blue,
                                Icons.account_balance,
                                1.0,
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ValueListenableBuilder<int>(
                            valueListenable: _walletRyoNotifier,
                            builder: (context, walletRyo, child) {
                              return ValueListenableBuilder<int>(
                                valueListenable: _bankRyoNotifier,
                                builder: (context, bankRyo, child) {
                                  final totalRyo = walletRyo + bankRyo;
                                  return _buildStatCard(
                                    'Total',
                                    '$totalRyo Ryo',
                                    Colors.green,
                                    Icons.account_balance,
                                    1.0,
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Recent Activity Card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recent Activity',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildActivityItem(
                      Icons.flash_on,
                      'Last Battle',
                      'No recent battles',
                      Colors.red,
                    ),
                    const SizedBox(height: 8),
                    _buildActivityItem(
                      Icons.assignment,
                      'Active Quests',
                      'No active quests',
                      Colors.purple,
                    ),
                    const SizedBox(height: 8),
                    _buildActivityItem(
                      Icons.inventory,
                      'Items',
                      '${_player!.inventory.length} items',
                      Colors.teal,
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

  /// Builds a stat card
  Widget _buildStatCard(String label, String value, Color color, IconData icon, double percentage) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
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
          if (percentage < 1.0) ...[
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: percentage,
              backgroundColor: color.withOpacity(0.4),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 4,
            ),
          ],
        ],
      ),
    );
  }

  /// Builds an activity item
  Widget _buildActivityItem(IconData icon, String title, String subtitle, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds the village hub tab content
  Widget _buildVillageHubTab() {
    return const VillageHubScreen();
  }


  /// Builds the map tab content
  Widget _buildMapTab() {
    return const MapScreen();
  }


  /// Builds the bottom navigation bar
  Widget _buildBottomNavigation() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home, 'Home'),
              _buildNavItem(1, Icons.location_city, 'Village'),
              _buildNavItem(2, Icons.map, 'Map'),
              _buildNavItem(3, Icons.inventory, 'Items'),
              _buildNavItem(4, Icons.person, 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a navigation item
  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          _currentIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey[600],
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Gets the current tab content
  Widget _getCurrentTabContent() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return _buildVillageHubTab();
      case 2:
        return _buildMapTab();
      case 3:
        return const InventoryScreen();
      case 4:
        return const ProfileScreen();
      default:
        return _buildHomeTab();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle()),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
        elevation: 4,
        leading: IconButton(
          icon: const Icon(Icons.logout),
          onPressed: _handleLogout,
          tooltip: 'Logout',
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _getCurrentTabContent(),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  /// Gets the app bar title based on current tab
  String _getAppBarTitle() {
    switch (_currentIndex) {
      case 0:
        return '🥷 Home';
      case 1:
        return '🏘️ Village Hub';
      case 2:
        return '🗺️ Map';
      case 3:
        return '🎒 Inventory';
      case 4:
        return '👤 Profile';
      default:
        return '🥷 Shinobi RPG';
    }
  }
}
