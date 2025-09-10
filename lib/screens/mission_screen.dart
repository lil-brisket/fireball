import 'package:flutter/material.dart';
import '../models/player.dart';
import '../services/player_data_manager.dart';
import '../services/mission_manager.dart';

/// A screen that displays available missions and allows players to accept them.
/// 
/// This screen shows different mission types with varying difficulty levels
/// and rewards. Players can accept missions and track their progress.
/// 
/// Example:
/// ```dart
/// Navigator.push(
///   context,
///   MaterialPageRoute(
///     builder: (context) => const MissionScreen(),
///   ),
/// );
/// ```
class MissionScreen extends StatefulWidget {
  const MissionScreen({super.key});

  @override
  State<MissionScreen> createState() => _MissionScreenState();
}

class _MissionScreenState extends State<MissionScreen> {
  Player? _player;
  List<Mission> _availableMissions = [];
  List<Mission> _activeMissions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlayer();
    _loadMissions();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh missions when returning to this screen
    _loadMissions();
  }

  /// Loads the current player from the data manager
  void _loadPlayer() {
    setState(() {
      _player = PlayerDataManager.instance.currentPlayer;
    });
  }

  /// Loads available missions
  void _loadMissions() {
    setState(() {
      if (_player != null) {
        _availableMissions = MissionManager.instance.generateAvailableMissions(_player!.level);
        _activeMissions = List.from(MissionManager.instance.activeMissions);
      } else {
        _availableMissions = [];
        _activeMissions = [];
      }
      _isLoading = false;
    });
  }


  /// Accepts a mission
  void _acceptMission(Mission mission) {
    if (_player == null) return;

    if (_player!.level < mission.requirements.minLevel) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Requires level ${mission.requirements.minLevel}'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Accept mission through mission manager
    MissionManager.instance.acceptMission(mission);
    
    setState(() {
      _availableMissions.remove(mission);
      _activeMissions.add(mission);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Accepted mission: ${mission.title}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  /// Completes a mission
  void _completeMission(Mission mission) {
    if (_player == null) return;

    // Complete mission through mission manager
    MissionManager.instance.completeMission(mission.id, _player!);

    setState(() {
      _activeMissions.remove(mission);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Completed mission: ${mission.title} (+${mission.reward.xp} XP)'),
        backgroundColor: Colors.green,
      ),
    );

    // Save progress
    PlayerDataManager.instance.saveLevelUpProgress();
  }

  /// Gets the color for mission difficulty
  Color _getDifficultyColor(MissionDifficulty difficulty) {
    switch (difficulty) {
      case MissionDifficulty.D:
        return Colors.green;
      case MissionDifficulty.C:
        return Colors.blue;
      case MissionDifficulty.B:
        return Colors.orange;
      case MissionDifficulty.A:
        return Colors.red;
      case MissionDifficulty.S:
        return Colors.purple;
    }
  }

  /// Gets the icon for mission type
  IconData _getMissionTypeIcon(MissionType type) {
    switch (type) {
      case MissionType.combat:
        return Icons.flash_on;
      case MissionType.collection:
        return Icons.inventory;
      case MissionType.escort:
        return Icons.people;
      case MissionType.investigation:
        return Icons.search;
      case MissionType.training:
        return Icons.fitness_center;
    }
  }

  /// Builds the player stats display
  Widget _buildPlayerStats() {
    if (_player == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Text('No player data available'),
          ),
        ),
      );
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person, color: Colors.blue, size: 24),
                const SizedBox(width: 8),
                Text(
                  _player!.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade300),
                  ),
                  child: Text(
                    'Level ${_player!.level}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatDisplay(
                    'XP',
                    '${_player!.xp}/${_player!.xpToNextLevel}',
                    Colors.amber,
                    Icons.star,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatDisplay(
                    'Active Missions',
                    '${_activeMissions.length}',
                    Colors.purple,
                    Icons.assignment,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a stat display widget
  Widget _buildStatDisplay(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
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
        ],
      ),
    );
  }

  /// Builds the active missions section
  Widget _buildActiveMissions() {
    if (_activeMissions.isEmpty) {
      return Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              Icon(
                Icons.assignment_outlined,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No Active Missions',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Accept missions from the available list to start your journey!',
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

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Active Missions (${_activeMissions.length})',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _activeMissions.length,
              itemBuilder: (context, index) {
                final mission = _activeMissions[index];
                return _buildMissionCard(mission, isActive: true);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the available missions section
  Widget _buildAvailableMissions() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Available Missions (${_availableMissions.length})',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _availableMissions.length,
              itemBuilder: (context, index) {
                final mission = _availableMissions[index];
                return _buildMissionCard(mission, isActive: false);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a mission card
  Widget _buildMissionCard(Mission mission, {required bool isActive}) {
    final difficultyColor = _getDifficultyColor(mission.difficulty);
    final canAccept = _player != null && _player!.level >= mission.requirements.minLevel;
    final isCompleted = isActive && mission.progress != null && mission.progress! >= mission.maxProgress!;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? Colors.blue.withOpacity(0.3) : Colors.grey[300]!,
          width: isActive ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getMissionTypeIcon(mission.type),
                color: difficultyColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  mission.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: difficultyColor.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: difficultyColor),
                ),
                child: Text(
                  mission.difficulty.name,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: difficultyColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            mission.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.star, color: Colors.amber, size: 16),
              const SizedBox(width: 4),
              Text(
                '${mission.reward.xp} XP',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.amber[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 16),
              Icon(Icons.monetization_on, color: Colors.green, size: 16),
              const SizedBox(width: 4),
              Text(
                '${mission.reward.gold} Gold',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.green[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (isActive && mission.progress != null) ...[
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: mission.progress! / mission.maxProgress!,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            const SizedBox(height: 4),
            Text(
              'Progress: ${mission.progress}/${mission.maxProgress}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Level ${mission.requirements.minLevel}+ required',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[500],
                ),
              ),
              if (isActive)
                ElevatedButton(
                  onPressed: isCompleted ? () => _completeMission(mission) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: Text(isCompleted ? 'Complete' : 'In Progress'),
                )
              else
                ElevatedButton(
                  onPressed: canAccept ? () => _acceptMission(mission) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: const Text('Accept'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('🥷 Missions'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMissions,
            tooltip: 'Refresh Missions',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildPlayerStats(),
            const SizedBox(height: 16),
            _buildActiveMissions(),
            const SizedBox(height: 16),
            _buildAvailableMissions(),
          ],
        ),
      ),
    );
  }
}

/// Represents a mission in the game
class Mission {
  final String id;
  final String title;
  final String description;
  final MissionDifficulty difficulty;
  final MissionReward reward;
  final MissionRequirements requirements;
  final MissionType type;
  final int? progress;
  final int? maxProgress;

  const Mission({
    required this.id,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.reward,
    required this.requirements,
    required this.type,
    this.progress,
    this.maxProgress,
  });
}

/// Mission difficulty levels
enum MissionDifficulty {
  D, C, B, A, S
}

/// Mission types
enum MissionType {
  combat,
  collection,
  escort,
  investigation,
  training,
}

/// Mission rewards
class MissionReward {
  final int xp;
  final int gold;

  const MissionReward({
    required this.xp,
    required this.gold,
  });
}

/// Mission requirements
class MissionRequirements {
  final int minLevel;

  const MissionRequirements({
    required this.minLevel,
  });
}
