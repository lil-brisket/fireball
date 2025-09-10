import 'package:flutter/material.dart';
import '../models/player.dart';
import '../services/player_data_manager.dart';
import '../core/widgets/bottom_navigation.dart';
import 'bank_screen.dart';
import 'shop_screen.dart';
import 'enemy_selection_screen.dart';
import 'training_dojo_screen.dart';
import 'quest_screen.dart';
import 'mission_screen.dart';

/// Village Hub screen providing access to all game locations.
/// 
/// This screen displays a grid of all available game locations including
/// Bank, Shop, Training Dojo, Battle, Quests, and Missions.
/// 
/// Example:
/// ```dart
/// Navigator.push(
///   context,
///   MaterialPageRoute(
///     builder: (context) => const VillageHubScreen(),
///   ),
/// );
/// ```
class VillageHubScreen extends StatefulWidget {
  final bool showAppBar;
  final bool showBottomNavigation;
  
  const VillageHubScreen({
    super.key,
    this.showAppBar = true,
    this.showBottomNavigation = true,
  });

  @override
  State<VillageHubScreen> createState() => _VillageHubScreenState();
}

class _VillageHubScreenState extends State<VillageHubScreen> with TickerProviderStateMixin {
  Player? _player;
  bool _isLoading = true;

  // Animation controllers
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadPlayerData();
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

  /// Loads player data
  Future<void> _loadPlayerData() async {
    try {
      final player = PlayerDataManager.instance.currentPlayer;
      
      setState(() {
        _player = player;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading player data: $e');
      setState(() {
        _isLoading = false;
      });
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showAppBar ? AppBar(
        title: const Text('🏘️ Village Hub'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
      ) : null,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
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
                            if (_player != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EnemySelectionScreen(player: _player!),
                                ),
                              );
                            }
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
              ),
            ),
      bottomNavigationBar: widget.showBottomNavigation ? const BottomNavigation(currentRoute: '/village-hub') : null,
    );
  }
}
