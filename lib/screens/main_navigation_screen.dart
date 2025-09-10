import 'package:flutter/material.dart';
import '../core/widgets/bottom_navigation.dart';
import 'main_menu_screen.dart';
import 'village_hub_screen.dart';
import 'map_screen.dart';
import 'inventory_screen.dart';
import 'profile_screen.dart';
import 'bank_screen.dart';
import 'shop_screen.dart';
import 'training_dojo_screen.dart';
import 'quest_screen.dart';
import 'mission_screen.dart';

/// Main navigation screen that handles tab-based navigation
/// 
/// This screen provides a consistent AppBar and BottomNavigation
/// while displaying different content based on the selected tab.
class MainNavigationScreen extends StatefulWidget {
  final int initialTabIndex;
  
  const MainNavigationScreen({
    super.key,
    this.initialTabIndex = 0,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _currentTabIndex;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _currentTabIndex = widget.initialTabIndex;
    _pageController = PageController(initialPage: _currentTabIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Gets the title for the current tab
  String _getTitle() {
    switch (_currentTabIndex) {
      case 0:
        return '🥷 Shinobi Village';
      case 1:
        return '🏘️ Village Hub';
      case 2:
        return '🗺️ Map';
      case 3:
        return '🎒 Inventory';
      case 4:
        return '👤 Profile';
      default:
        return '🥷 Shinobi Village';
    }
  }

  /// Gets the route for the current tab
  String _getCurrentRoute() {
    switch (_currentTabIndex) {
      case 0:
        return '/main_menu';
      case 1:
        return '/village-hub';
      case 2:
        return '/map';
      case 3:
        return '/inventory';
      case 4:
        return '/profile';
      default:
        return '/main_menu';
    }
  }

  /// Handles tab changes
  void _onTabChanged(int index) {
    setState(() {
      _currentTabIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle()),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentTabIndex = index;
          });
        },
        children: const [
          MainMenuContent(),
          VillageHubContent(),
          MapContent(),
          InventoryContent(),
          ProfileContent(),
        ],
      ),
      bottomNavigationBar: BottomNavigation(
        currentRoute: _getCurrentRoute(),
        onTabChanged: _onTabChanged,
      ),
    );
  }
}

/// Content widget for the main menu (without AppBar and BottomNavigation)
class MainMenuContent extends StatefulWidget {
  const MainMenuContent({super.key});

  @override
  State<MainMenuContent> createState() => _MainMenuContentState();
}

class _MainMenuContentState extends State<MainMenuContent>
    with TickerProviderStateMixin {
  // ... existing code from MainMenuScreen but without AppBar and BottomNavigation
  // This will be implemented in the next step
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.person,
            size: 80,
            color: Colors.red,
          ),
          const SizedBox(height: 24),
          Text(
            'Welcome, Shinobi',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
              letterSpacing: 0.5,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Content widget for the village hub (without AppBar and BottomNavigation)
class VillageHubContent extends StatefulWidget {
  const VillageHubContent({super.key});

  @override
  State<VillageHubContent> createState() => _VillageHubContentState();
}

class _VillageHubContentState extends State<VillageHubContent> with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
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

  /// Builds a village location card
  Widget _buildVillageLocation(String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: color,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Village locations grid
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.1,
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
            ),
          ],
        ),
      ),
    );
  }
}

/// Content widget for the map screen (without AppBar and BottomNavigation)
class MapContent extends StatelessWidget {
  const MapContent({super.key});

  @override
  Widget build(BuildContext context) {
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
              'The world map feature is under development.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Content widget for the inventory screen (without AppBar and BottomNavigation)
class InventoryContent extends StatelessWidget {
  const InventoryContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Inventory Content - Coming Soon'),
    );
  }
}

/// Content widget for the profile screen (without AppBar and BottomNavigation)
class ProfileContent extends StatelessWidget {
  const ProfileContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Profile Content - Coming Soon'),
    );
  }
}
