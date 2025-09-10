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
import 'main_navigation_screen.dart';
import 'bank_screen.dart';
import 'shop_screen.dart';
import 'training_dojo_screen.dart';
import 'quest_screen.dart';
import 'mission_screen.dart';

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
      final accountManager = AccountManager.instance;
      
      // Ensure AccountManager is initialized
      if (!accountManager.isInitialized) {
        await accountManager.initialize();
      }
      
      await accountManager.clearCurrentAccount();
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
    return _buildVillageHubContent();
  }

  /// Builds the village hub content without AppBar and BottomNavigation
  Widget _buildVillageHubContent() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Village locations grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 0,
            mainAxisSpacing: 0,
            childAspectRatio: 0.15,
            children: [
              _buildVillageLocation(
                'Bank',
                Icons.account_balance,
                Colors.blue,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BankScreen(),
                  ),
                ),
              ),
              _buildVillageLocation(
                'Shop',
                Icons.store,
                Colors.green,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ShopScreen(),
                  ),
                ),
              ),
              _buildVillageLocation(
                'Training Dojo',
                Icons.fitness_center,
                Colors.purple,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TrainingDojoScreen(),
                  ),
                ),
              ),
              _buildVillageLocation(
                'Battle',
                Icons.flash_on,
                Colors.red,
                () {
                  // TODO: Implement battle navigation
                },
              ),
              _buildVillageLocation(
                'Quests',
                Icons.assignment,
                Colors.orange,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const QuestScreen(),
                  ),
                ),
              ),
              _buildVillageLocation(
                'Missions',
                Icons.flag,
                Colors.teal,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MissionScreen(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds a village location card
  Widget _buildVillageLocation(String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(1),
        child: Padding(
          padding: const EdgeInsets.all(0.5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: color,
                size: 6,
              ),
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 5,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }


  /// Builds the map tab content
  Widget _buildMapTab() {
    return _buildMapContent();
  }

  /// Builds the map content without AppBar and BottomNavigation
  Widget _buildMapContent() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.map,
              size: 120,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 32),
            Text(
              'Coming Soon',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Explore different regions and encounter enemies',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.explore,
                      size: 48,
                      color: Colors.blue[600],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Future Features',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildFeatureItem('Region Navigation', Icons.location_on),
                    _buildFeatureItem('Random Encounters', Icons.flash_on),
                    _buildFeatureItem('Hidden Locations', Icons.explore),
                    _buildFeatureItem('Boss Battles', Icons.sports_mma),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a feature item for the future features list
  Widget _buildFeatureItem(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: Colors.blue[600],
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the inventory content without AppBar and BottomNavigation
  Widget _buildInventoryContent() {
    return const Center(
      child: Text('Inventory Content - Coming Soon'),
    );
  }

  /// Builds the profile content without AppBar and BottomNavigation
  Widget _buildProfileContent() {
    return const Center(
      child: Text('Profile Content - Coming Soon'),
    );
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
        return _buildInventoryContent();
      case 4:
        return _buildProfileContent();
      default:
        return _buildHomeTab();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle()),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
        centerTitle: true,
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
