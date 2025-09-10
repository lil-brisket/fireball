import 'package:flutter/material.dart';
import '../core/widgets/base_screen.dart';
import '../core/widgets/bottom_navigation.dart';

/// Placeholder shop screen for the Shinobi RPG game.
/// 
/// This screen will eventually contain the shop functionality for buying
/// items, equipment, and other game items. Currently shows a placeholder
/// message indicating the feature is coming soon.
/// 
/// Example:
/// ```dart
/// Navigator.push(
///   context,
///   MaterialPageRoute(
///     builder: (context) => const ShopScreen(),
///   ),
/// );
/// ```
class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: '🥷 Shop',
      body: Column(
        children: [
          // Scrollable content
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.store,
                      size: 100,
                      color: Colors.green[400],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Shop Coming Soon',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'The shop feature is currently under development.\n'
                      'You will be able to buy items, equipment, and more here!',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).brightness == Brightness.dark 
                            ? Colors.grey[400] 
                            : Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                      child: const Text('Go Back'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Bottom navigation
          BottomNavigation(currentRoute: '/shop'),
        ],
      ),
    );
  }
}
