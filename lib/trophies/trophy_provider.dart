import 'package:dungeon_run/flame_game/components/collectables/collectable_type.dart';
import 'package:dungeon_run/flame_game/components/enemies/enemy_type.dart';
import 'package:dungeon_run/flame_game/components/traps/trap_type.dart';
import 'package:dungeon_run/progression/level.dart';
import 'package:dungeon_run/settings/persistence.dart';
import 'package:dungeon_run/store/default_upgrades.dart';
import 'package:dungeon_run/store/upgrade.dart';
import 'package:dungeon_run/trophies/trophy.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class TrophyProvider extends ChangeNotifier {
  /// List of trophies
  List<Trophy> _trophies = [];

  /// Getter for trophies
  List<Trophy> get trophies => _trophies;

  /// Amount of enemies killed
  int _totalEnemiesKilled = 0;

  /// List of enemies killed
  final Set<EnemyType> _typeOfEnemiesKilled = {};

  /// Amount of bosses killed
  int _totalBossesKilled = 0;

  /// Number of deaths
  int _totalDeaths = 0;

  /// Number of resurrection
  int _totalResurrections = 0;

  /// Number of collectables
  int _totalCollectables = 0;

  /// List of collectables
  final Set<CollectableType> _typeOfCollectablesRetrieved = {};

  /// Number of traps
  int _totalTraps = 0;

  /// List of traps
  final Set<TrapType> _typeOfTrapsDisabled = {};

  /// Number of upgrades
  int _totalUpgrades = 0;

  /// The container of the local saved data
  final Persistence _persistence = Persistence();

  /// Recover the unlocked trophies
  Future<void> loadFromMemory() async {
    _trophies = await _persistence.getTrophies();
    notifyListeners();
  }

  /// Save the trophies to memory
  Future<void> saveToMemory() async {
    final List<String> encodedList = _trophies.map((Trophy trophy) => trophiesToString(trophy)).toList();
    await _persistence.saveTrophies(encodedList);
  }

  /// Increment the amount of enemies killed and add the enemy to the set of enemies killed
  void incrementEnemiesKilled(EnemyType enemyType) {
    _totalEnemiesKilled += 1;

    if (_totalEnemiesKilled == 1) {
      unlockTrophy("enemy-1");
    }
    if (_totalEnemiesKilled == 100) {
      unlockTrophy("enemy-2");
    }
    if (_totalEnemiesKilled == 1000) {
      unlockTrophy("enemy-3");
    }

    _typeOfEnemiesKilled.add(enemyType);
    if (_typeOfEnemiesKilled.length == EnemyType.values.length) {
      unlockTrophy("enemy-4");
    }

    notifyListeners();
  }

  /// Increment the amount of bosses killed
  void incrementBossesKilled() {
    _totalBossesKilled += 1;

    if (_totalBossesKilled == 1) {
      unlockTrophy("boss-1");
    }
    if (_totalBossesKilled == 100) {
      unlockTrophy("boss-2");
    }
    if (_totalBossesKilled == 1000) {
      unlockTrophy("boss-3");
    }

    notifyListeners();
  }

  /// Increment the number of deaths
  void incrementDeaths() {
    _totalDeaths += 1;

    if (_totalDeaths == 1) {
      unlockTrophy("die-1");
    }
    if (_totalDeaths == 100) {
      unlockTrophy("die-2");
    }

    notifyListeners();
  }

  /// Increment the number of resurrections
  void incrementResurrections() {
    _totalResurrections += 1;

    if (_totalResurrections == 1) {
      unlockTrophy("resurrection-1");
    }
    if (_totalResurrections == 100) {
      unlockTrophy("resurrection-2");
    }

    notifyListeners();
  }

  /// Increment the number of collectables and add the collectable to the set of collectables
  void incrementCollectables(CollectableType collectable) {
    _totalCollectables += 1;

    if (_totalCollectables == 1) {
      unlockTrophy("collectable-1");
    }
    if (_totalCollectables == 100) {
      unlockTrophy("collectable-2");
    }
    if (_totalCollectables == 1000) {
      unlockTrophy("collectable-3");
    }

    _typeOfCollectablesRetrieved.add(collectable);
    if (_typeOfCollectablesRetrieved.length == CollectableType.values.length) {
      unlockTrophy("collectable-4");
    }

    notifyListeners();
  }

  /// Increment the number of traps and add the trap to the set of traps
  void incrementTraps(TrapType trap) {
    _totalTraps += 1;

    if (_totalTraps == 1) {
      unlockTrophy("traps-1");
    }
    if (_totalTraps == 100) {
      unlockTrophy("traps-2");
    }
    if (_totalTraps == 1000) {
      unlockTrophy("traps-3");
    }

    _typeOfTrapsDisabled.add(trap);
    if (_typeOfTrapsDisabled.length == TrapType.values.length) {
      unlockTrophy("traps-4");
    }

    notifyListeners();
  }

  /// Increment the number of upgrades
  void incrementUpgrades() {
    _totalUpgrades += 1;

    if (_totalUpgrades == 1) {
      unlockTrophy("upgrade-1");
    }

    int totalUnlockableUpgrades = defaultUpgrades.fold(0, (int sum, Upgrade upgrade) => sum + upgrade.maxLevel);
    if (_totalUpgrades == totalUnlockableUpgrades) {
      unlockTrophy("upgrade-2");
    }

    notifyListeners();
  }

  /// Unlock the Overpowered trophy
  /// This trophy is unlocked when the player completes the level "external-1" and has already unlocked the "upgrade-2" trophy
  void unlockLevelsTrophy(Level level) {
    if (level.id == "external-1" && _trophies.any((Trophy trophy) => trophy.id == "upgrade-2" && trophy.unlocked)) {
      unlockTrophy("level-1");
    }

    if (level.id == "throne-1") {
      unlockTrophy("level-2");
    }
  }

  /// Unlock an upgrade
  void unlockTrophy(String trophyId) {
    final int index = _trophies.indexWhere((Trophy trophy) => trophy.id == trophyId);
    if (index != -1) {
      final Trophy trophy = _trophies[index];
      _trophies[index] = (
        id: trophy.id,
        name: trophy.name,
        description: trophy.description,
        iconPath: trophy.iconPath,
        unlocked: true, // Set unlocked to true
      );

      // Show the trophy unlocked toast
      toastification.showCustom(
        autoCloseDuration: const Duration(seconds: 3),
        builder: (BuildContext context, ToastificationItem holder) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.blue,
            ),
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(8),
            child: Row(
              children: [
                Image.asset(
                  "assets/images/${trophy.iconPath}",
                  width: 30,
                  height: 30,
                ),
                Flexible(
                  child: Text(
                    "Trophy unlocked: ${trophy.name}",
                    style: const TextStyle(color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3,
                  ),
                ),
              ],
            ),
          );
        },
      );

      notifyListeners();
    }
  }
}
