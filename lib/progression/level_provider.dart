import 'package:flutter/foundation.dart';
import 'package:dungeon_run/progression/level.dart';
import 'package:dungeon_run/settings/persistence.dart';

class LevelProvider extends ChangeNotifier {
  /// List of levels
  List<Level> _levels = [];

  /// Getter for levels
  List<Level> get levels => _levels;

  /// The container of the local saved data
  final Persistence _persistence = Persistence();

  /// Load levels from memory
  Future<void> loadFromMemory() async {
    _levels = await _persistence.getLevels();
    notifyListeners();
  }

  /// Save levels to memory
  Future<void> saveToMemory() async {
    final List<String> encodedList = _levels.map((Level level) => levelToString(level)).toList();
    await _persistence.saveLevels(encodedList);
  }

  /// Mark a level as completed
  void setLevelCompleted(String levelName) {
    final int index = _levels.indexWhere((level) => level.name == levelName);
    if (index != -1) {
      final Level level = _levels[index];
      _levels[index] = (
        id: level.id,
        name: level.name,
        completed: true, // Mark as completed
        dependency: level.dependency,
        enemies: level.enemies,
        enemyFrequency: level.enemyFrequency,
        boss: level.boss,
        bossTimer: level.bossTimer,
        traps: level.traps,
        trapMinPeriod: level.trapMinPeriod,
        trapMaxPeriod: level.trapMaxPeriod,
        collectableMinPeriod: level.collectableMinPeriod,
        collectableMaxPeriod: level.collectableMaxPeriod,
        map: level.map,
        rewards: level.rewards,
        message: level.message,
      );
      notifyListeners();
    }
  }
}
