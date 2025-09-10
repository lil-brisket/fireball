import 'package:flutter/material.dart';
import '../core/widgets/base_screen.dart';

/// Placeholder training dojo screen for the Shinobi RPG game.
/// 
/// This screen will eventually contain training functionality for
/// improving player stats and learning new techniques.
class TrainingDojoScreen extends StatelessWidget {
  const TrainingDojoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScrollableScreen(
      title: '🥷 Training Dojo',
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.fitness_center,
                size: 100,
                color: Colors.purple[400],
              ),
              const SizedBox(height: 24),
              Text(
                'Training Dojo',
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
                'Train your ninja skills and improve your stats',
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
