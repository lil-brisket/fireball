import 'package:flutter/material.dart';
import 'package:shinobi_rpg/screens/enemy_selection_screen.dart';
import 'package:shinobi_rpg/screens/shop_screen.dart';
import 'package:shinobi_rpg/screens/settings_screen.dart';
import 'package:shinobi_rpg/screens/profile_screen.dart';
import 'package:shinobi_rpg/services/account_manager.dart';
import 'package:shinobi_rpg/services/player_data_manager.dart';
import 'package:shinobi_rpg/screens/landing_screen.dart';

/// Persistent bottom navigation bar for the Shinobi RPG app
/// 
/// This widget provides consistent navigation across all main screens
/// with a horizontal layout of menu buttons at the bottom.
class BottomNavigation extends StatelessWidget {
  final String currentRoute;
  
  const BottomNavigation({
    super.key,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 32.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.0),
            Colors.black.withOpacity(0.3),
            Colors.black.withOpacity(0.6),
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavButton(
            context: context,
            icon: Icons.person,
            label: 'Profile',
            route: '/profile',
            isActive: currentRoute == '/profile',
            color: Colors.indigo,
          ),
          const SizedBox(width: 8),
          _buildNavButton(
            context: context,
            icon: Icons.flash_on,
            label: 'Battle',
            route: '/battle',
            isActive: currentRoute == '/battle',
            color: Colors.deepOrange,
          ),
          const SizedBox(width: 8),
          _buildNavButton(
            context: context,
            icon: Icons.store,
            label: 'Shop',
            route: '/shop',
            isActive: currentRoute == '/shop',
            color: Colors.teal,
          ),
          const SizedBox(width: 8),
          _buildNavButton(
            context: context,
            icon: Icons.settings,
            label: 'Settings',
            route: '/settings',
            isActive: currentRoute == '/settings',
            color: Colors.purple,
          ),
          const SizedBox(width: 8),
          _buildNavButton(
            context: context,
            icon: Icons.logout,
            label: 'Logout',
            route: '/logout',
            isActive: false,
            color: Colors.grey,
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  /// Builds an individual navigation button
  Widget _buildNavButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String route,
    required bool isActive,
    required Color color,
    bool isDestructive = false,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _handleNavigation(context, route),
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isActive ? color.withOpacity(0.8) : color,
            border: isActive 
                ? Border.all(color: Colors.white.withOpacity(0.5), width: 2)
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 6,
                spreadRadius: 1,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _handleNavigation(context, route),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      size: 20,
                      color: isDestructive ? Colors.red[600] : Colors.white,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDestructive ? Colors.red[700] : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Handles navigation to different screens
  void _handleNavigation(BuildContext context, String route) {
    switch (route) {
      case '/profile':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ProfileScreen(),
          ),
        );
        break;
      case '/battle':
        // Get current player for battle
        final player = PlayerDataManager.instance.currentPlayer;
        if (player != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EnemySelectionScreen(player: player),
            ),
          );
        } else {
          _showErrorDialog(context, 'No player data available for battle');
        }
        break;
      case '/shop':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ShopScreen(),
          ),
        );
        break;
      case '/settings':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SettingsScreen(),
          ),
        );
        break;
      case '/logout':
        _showLogoutDialog(context);
        break;
    }
  }

  /// Shows logout confirmation dialog
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text(
            'Logout',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await AccountManager.instance.clearCurrentAccount();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LandingScreen(),
                    ),
                    (route) => false,
                  );
                }
              },
              child: Text(
                'Logout',
                style: TextStyle(
                  color: Colors.red[600],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Shows error dialog
  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text(
            'Error',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          content: Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'OK',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
