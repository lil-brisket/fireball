import 'package:flutter/material.dart';
import '../core/widgets/base_screen.dart';

/// Placeholder quest screen for the Shinobi RPG game.
/// 
/// This screen will eventually contain quest functionality for
/// accepting and completing various quests and storylines.
class QuestScreen extends StatelessWidget {
  const QuestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScrollableScreen(
      title: '🥷 Quests',
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.assignment,
                size: 100,
                color: Colors.orange[400],
              ),
              const SizedBox(height: 24),
              Text(
                'Quest System',
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
                'Accept quests and follow epic storylines',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
