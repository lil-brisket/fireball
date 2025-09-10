import 'package:flutter/material.dart';
import '../services/account_manager.dart';
import '../services/player_data_manager.dart';
import '../models/player.dart';
import '../core/widgets/bottom_navigation.dart';

/// Main menu hub screen for the Shinobi RPG game.
/// 
/// This screen serves as the central hub after login, providing navigation
/// to all major game features with a clean, ninja-themed interface.
class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen>
    with TickerProviderStateMixin {
  Player? _player;
  bool _isLoading = true;

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;

  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadPlayerData();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  /// Initializes all animation controllers and animations
  void _initializeAnimations() {
    // Fade animation
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

    // Slide animation
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    // Pulse animation for the ninja icon
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Start animations
    _fadeController.forward();
    _slideController.forward();
    _pulseController.repeat(reverse: true);
  }

  /// Loads player data from the account manager
  Future<void> _loadPlayerData() async {
    try {
      print('DEBUG: MainMenuScreen - Loading player data...');
      
      // Ensure PlayerDataManager is initialized
      if (!PlayerDataManager.instance.isInitialized) {
        print('DEBUG: MainMenuScreen - Initializing PlayerDataManager...');
        await PlayerDataManager.instance.initialize();
      }
      
      final player = PlayerDataManager.instance.currentPlayer;
      print('DEBUG: MainMenuScreen - Current player: ${player?.name ?? "null"}');
      
      if (player != null) {
        setState(() {
          _player = player;
          _isLoading = false;
        });
        print('DEBUG: MainMenuScreen - Player loaded successfully');
      } else {
        print('DEBUG: MainMenuScreen - No player data, refreshing database...');
        // If no player data, try to load from account manager
        final accountManager = AccountManager.instance;
        
        // Ensure AccountManager is initialized
        if (!accountManager.isInitialized) {
          await accountManager.initialize();
        }
        
        await accountManager.refreshDatabase();
        final refreshedPlayer = PlayerDataManager.instance.currentPlayer;
        print('DEBUG: MainMenuScreen - Refreshed player: ${refreshedPlayer?.name ?? "null"}');
        setState(() {
          _player = refreshedPlayer;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('ERROR: MainMenuScreen - Failed to load player data: $e');
      debugPrint('Error loading player data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Builds the main title section
  Widget _buildTitle() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
              // Ninja icon with glow effect
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.red.withValues(alpha: 0.2),
                      Colors.red.withValues(alpha: 0.1),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.7, 1.0],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.person,
                  size: 80,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 24),
              // Welcome message
              Text(
                _player != null 
                    ? 'Welcome back, ${_player!.name}'
                    : 'Welcome, Shinobi',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                  letterSpacing: 0.5,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('🥷 Shinobi Village'),
          backgroundColor: Theme.of(context).colorScheme.surface,
          foregroundColor: Theme.of(context).colorScheme.onSurface,
          elevation: 0,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('🥷 Shinobi Village'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: _buildTitle(),
      ),
      bottomNavigationBar: const BottomNavigation(currentRoute: '/main_menu'),
    );
  }
}