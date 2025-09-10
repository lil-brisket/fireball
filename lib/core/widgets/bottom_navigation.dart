import 'package:flutter/material.dart';
import 'package:shinobi_rpg/screens/main_menu_screen.dart';
import 'package:shinobi_rpg/screens/village_hub_screen.dart';
import 'package:shinobi_rpg/screens/map_screen.dart';
import 'package:shinobi_rpg/screens/inventory_screen.dart';
import 'package:shinobi_rpg/screens/profile_screen.dart';

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
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(
          top: BorderSide(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavButton(
                context: context,
                icon: Icons.home,
                label: 'Home',
                route: '/main_menu',
                isActive: currentRoute == '/main_menu',
                color: Colors.grey[600]!,
              ),
              _buildNavButton(
                context: context,
                icon: Icons.location_city,
                label: 'Village',
                route: '/village-hub',
                isActive: currentRoute == '/village-hub',
                color: Colors.blue[600]!,
              ),
              _buildNavButton(
                context: context,
                icon: Icons.map,
                label: 'Map',
                route: '/map',
                isActive: currentRoute == '/map',
                color: Colors.grey[600]!,
              ),
              _buildNavButton(
                context: context,
                icon: Icons.inventory,
                label: 'Items',
                route: '/inventory',
                isActive: currentRoute == '/inventory',
                color: Colors.grey[600]!,
              ),
              _buildNavButton(
                context: context,
                icon: Icons.person,
                label: 'Profile',
                route: '/profile',
                isActive: currentRoute == '/profile',
                color: Colors.grey[600]!,
              ),
            ],
          ),
        ),
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
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _handleNavigation(context, route),
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: isActive ? color.withValues(alpha: 0.1) : Colors.transparent,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _handleNavigation(context, route),
              borderRadius: BorderRadius.circular(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 24,
                    color: isActive ? color : Colors.grey[600],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isActive ? color : Colors.grey[600],
                      fontWeight: FontWeight.w500,
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
    );
  }

  /// Handles navigation to different screens
  void _handleNavigation(BuildContext context, String route) {
    switch (route) {
      case '/main_menu':
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const MainMenuScreen(),
          ),
          (route) => false,
        );
        break;
      case '/village-hub':
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const VillageHubScreen(),
          ),
          (route) => false,
        );
        break;
      case '/map':
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const MapScreen(),
          ),
          (route) => false,
        );
        break;
      case '/inventory':
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const InventoryScreen(),
          ),
          (route) => false,
        );
        break;
      case '/profile':
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const ProfileScreen(),
          ),
          (route) => false,
        );
        break;
    }
  }

}
