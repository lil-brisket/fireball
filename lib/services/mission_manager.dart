import '../models/player.dart';
import '../screens/mission_screen.dart';

/// Service for managing mission progress and tracking.
/// 
/// This service handles mission state, progress updates, and completion logic.
/// It integrates with the player data to track mission progress across game sessions.
class MissionManager {
  static final MissionManager _instance = MissionManager._internal();
  factory MissionManager() => _instance;
  MissionManager._internal();

  static MissionManager get instance => _instance;

  List<Mission> _activeMissions = [];
  List<Mission> _completedMissions = [];

  /// Gets all active missions
  List<Mission> get activeMissions => List.unmodifiable(_activeMissions);

  /// Gets all completed missions
  List<Mission> get completedMissions => List.unmodifiable(_completedMissions);

  /// Adds a mission to active missions
  void acceptMission(Mission mission) {
    if (!_activeMissions.any((m) => m.id == mission.id)) {
      _activeMissions.add(mission);
    }
  }

  /// Updates mission progress based on game events
  void updateMissionProgress(String eventType, {Map<String, dynamic>? eventData}) {
    for (int i = 0; i < _activeMissions.length; i++) {
      final mission = _activeMissions[i];
      bool progressUpdated = false;

      switch (mission.type) {
        case MissionType.combat:
          if (eventType == 'enemy_defeated') {
            final updatedMission = _updateCombatMission(mission, eventData);
            if (updatedMission != null) {
              _activeMissions[i] = updatedMission;
              progressUpdated = true;
            }
          }
          break;
        case MissionType.collection:
          if (eventType == 'item_collected') {
            progressUpdated = _updateCollectionMission(mission, eventData);
          }
          break;
        case MissionType.training:
          if (eventType == 'battle_completed') {
            final updatedMission = _updateTrainingMission(mission, eventData);
            if (updatedMission != null) {
              _activeMissions[i] = updatedMission;
              progressUpdated = true;
            }
          }
          break;
        case MissionType.escort:
          if (eventType == 'escort_completed') {
            progressUpdated = _updateEscortMission(mission, eventData);
          }
          break;
        case MissionType.investigation:
          if (eventType == 'investigation_step') {
            final updatedMission = _updateInvestigationMission(mission, eventData);
            if (updatedMission != null) {
              _activeMissions[i] = updatedMission;
              progressUpdated = true;
            }
          }
          break;
      }

      if (progressUpdated) {
        // Check if mission is completed
        if (_activeMissions[i].progress != null && _activeMissions[i].maxProgress != null && 
            _activeMissions[i].progress! >= _activeMissions[i].maxProgress!) {
          _completeMission(_activeMissions[i]);
        }
      }
    }
  }

  /// Updates combat mission progress
  Mission? _updateCombatMission(Mission mission, Map<String, dynamic>? eventData) {
    if (mission.progress == null) {
      return Mission(
        id: mission.id,
        title: mission.title,
        description: mission.description,
        difficulty: mission.difficulty,
        reward: mission.reward,
        requirements: mission.requirements,
        type: mission.type,
        progress: 1,
        maxProgress: mission.maxProgress ?? 1,
      );
    } else {
      return Mission(
        id: mission.id,
        title: mission.title,
        description: mission.description,
        difficulty: mission.difficulty,
        reward: mission.reward,
        requirements: mission.requirements,
        type: mission.type,
        progress: mission.progress! + 1,
        maxProgress: mission.maxProgress,
      );
    }
  }

  /// Updates collection mission progress
  bool _updateCollectionMission(Mission mission, Map<String, dynamic>? eventData) {
    final itemName = eventData?['item_name'] as String?;
    if (itemName == null) return false;

    // Check if the collected item matches the mission requirement
    if (mission.description.toLowerCase().contains(itemName.toLowerCase()) ||
        mission.title.toLowerCase().contains(itemName.toLowerCase())) {
      if (mission.progress == null) {
        mission = Mission(
          id: mission.id,
          title: mission.title,
          description: mission.description,
          difficulty: mission.difficulty,
          reward: mission.reward,
          requirements: mission.requirements,
          type: mission.type,
          progress: 1,
          maxProgress: mission.maxProgress ?? 1,
        );
        return true;
      } else {
        mission = Mission(
          id: mission.id,
          title: mission.title,
          description: mission.description,
          difficulty: mission.difficulty,
          reward: mission.reward,
          requirements: mission.requirements,
          type: mission.type,
          progress: mission.progress! + 1,
          maxProgress: mission.maxProgress,
        );
        return true;
      }
    }
    return false;
  }

  /// Updates training mission progress
  Mission? _updateTrainingMission(Mission mission, Map<String, dynamic>? eventData) {
    if (mission.progress == null) {
      return Mission(
        id: mission.id,
        title: mission.title,
        description: mission.description,
        difficulty: mission.difficulty,
        reward: mission.reward,
        requirements: mission.requirements,
        type: mission.type,
        progress: 1,
        maxProgress: mission.maxProgress ?? 5,
      );
    } else {
      return Mission(
        id: mission.id,
        title: mission.title,
        description: mission.description,
        difficulty: mission.difficulty,
        reward: mission.reward,
        requirements: mission.requirements,
        type: mission.type,
        progress: mission.progress! + 1,
        maxProgress: mission.maxProgress,
      );
    }
  }

  /// Updates escort mission progress
  bool _updateEscortMission(Mission mission, Map<String, dynamic>? eventData) {
    // Escort missions are typically completed in one go
    if (mission.progress == null) {
      mission = Mission(
        id: mission.id,
        title: mission.title,
        description: mission.description,
        difficulty: mission.difficulty,
        reward: mission.reward,
        requirements: mission.requirements,
        type: mission.type,
        progress: 1,
        maxProgress: 1,
      );
      return true;
    }
    return false;
  }

  /// Updates investigation mission progress
  Mission? _updateInvestigationMission(Mission mission, Map<String, dynamic>? eventData) {
    if (mission.progress == null) {
      return Mission(
        id: mission.id,
        title: mission.title,
        description: mission.description,
        difficulty: mission.difficulty,
        reward: mission.reward,
        requirements: mission.requirements,
        type: mission.type,
        progress: 1,
        maxProgress: mission.maxProgress ?? 3,
      );
    } else {
      return Mission(
        id: mission.id,
        title: mission.title,
        description: mission.description,
        difficulty: mission.difficulty,
        reward: mission.reward,
        requirements: mission.requirements,
        type: mission.type,
        progress: mission.progress! + 1,
        maxProgress: mission.maxProgress,
      );
    }
  }

  /// Completes a mission and awards rewards
  void _completeMission(Mission mission) {
    _activeMissions.removeWhere((m) => m.id == mission.id);
    _completedMissions.add(mission);
  }

  /// Manually completes a mission (for UI completion button)
  void completeMission(String missionId, Player player) {
    final missionIndex = _activeMissions.indexWhere((m) => m.id == missionId);
    if (missionIndex != -1) {
      final mission = _activeMissions[missionIndex];
      
      // Award rewards
      player.gainXp(mission.reward.xp);
      // Note: Gold system not implemented yet
      
      // Move to completed missions
      _activeMissions.removeAt(missionIndex);
      _completedMissions.add(mission);
    }
  }

  /// Removes a mission from active missions
  void removeMission(String missionId) {
    _activeMissions.removeWhere((m) => m.id == missionId);
  }

  /// Gets a mission by ID
  Mission? getMission(String missionId) {
    return _activeMissions.firstWhere(
      (m) => m.id == missionId,
      orElse: () => _completedMissions.firstWhere(
        (m) => m.id == missionId,
        orElse: () => throw StateError('Mission not found'),
      ),
    );
  }

  /// Checks if a mission is completed
  bool isMissionCompleted(String missionId) {
    return _completedMissions.any((m) => m.id == missionId);
  }

  /// Resets all mission data (for testing)
  void resetMissions() {
    _activeMissions.clear();
    _completedMissions.clear();
  }

  /// Generates available missions based on player level
  List<Mission> generateAvailableMissions(int playerLevel) {
    final missions = <Mission>[];
    
    // D-rank missions (Level 1+)
    if (playerLevel >= 1) {
      missions.addAll([
        Mission(
          id: 'mission_1',
          title: 'Defeat Bandits',
          description: 'Eliminate 3 bandits to protect the village',
          difficulty: MissionDifficulty.D,
          reward: MissionReward(xp: 50, gold: 100),
          requirements: MissionRequirements(minLevel: 1),
          type: MissionType.combat,
          maxProgress: 3,
        ),
        Mission(
          id: 'mission_2',
          title: 'Gather Herbs',
          description: 'Collect 5 healing herbs from the forest',
          difficulty: MissionDifficulty.D,
          reward: MissionReward(xp: 30, gold: 75),
          requirements: MissionRequirements(minLevel: 1),
          type: MissionType.collection,
          maxProgress: 5,
        ),
        Mission(
          id: 'mission_3',
          title: 'Training Exercise',
          description: 'Complete 5 training battles',
          difficulty: MissionDifficulty.D,
          reward: MissionReward(xp: 40, gold: 60),
          requirements: MissionRequirements(minLevel: 1),
          type: MissionType.training,
          maxProgress: 5,
        ),
      ]);
    }

    // C-rank missions (Level 2+)
    if (playerLevel >= 2) {
      missions.addAll([
        Mission(
          id: 'mission_4',
          title: 'Escort Merchant',
          description: 'Safely escort a merchant through dangerous territory',
          difficulty: MissionDifficulty.C,
          reward: MissionReward(xp: 75, gold: 150),
          requirements: MissionRequirements(minLevel: 2),
          type: MissionType.escort,
          maxProgress: 1,
        ),
        Mission(
          id: 'mission_5',
          title: 'Defeat Rogue Ninja',
          description: 'Face off against a skilled rogue ninja',
          difficulty: MissionDifficulty.C,
          reward: MissionReward(xp: 100, gold: 200),
          requirements: MissionRequirements(minLevel: 2),
          type: MissionType.combat,
          maxProgress: 1,
        ),
      ]);
    }

    // B-rank missions (Level 3+)
    if (playerLevel >= 3) {
      missions.addAll([
        Mission(
          id: 'mission_6',
          title: 'Investigate Mystery',
          description: 'Solve the mystery of the disappearing villagers',
          difficulty: MissionDifficulty.B,
          reward: MissionReward(xp: 150, gold: 300),
          requirements: MissionRequirements(minLevel: 3),
          type: MissionType.investigation,
          maxProgress: 3,
        ),
      ]);
    }

    return missions;
  }
}
