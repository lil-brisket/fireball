import 'package:flutter/material.dart';
import '../core/widgets/base_screen.dart';

/// Placeholder screen for the world map feature.
/// 
/// This screen will eventually show the game world map with different regions,
/// allowing players to navigate and encounter random enemies.
/// 
/// Example:
/// ```dart
/// Navigator.push(
///   context,
///   MaterialPageRoute(
///     builder: (context) => const MapScreen(),
///   ),
/// );
/// ```
class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScrollableScreen(
      title: '🗺️ World Map',
      body: Center(
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
                'World Map',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
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
}
