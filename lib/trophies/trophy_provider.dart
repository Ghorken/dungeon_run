import 'package:dungeon_run/settings/persistence.dart';
import 'package:dungeon_run/trophies/trophy.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class TrophyProvider extends ChangeNotifier {
  /// List of trophies
  List<Trophy> _trophies = [];

  /// Getter for trophies
  List<Trophy> get trophies => _trophies;

  /// Amount of enemies killed
  int _enemiesKilled = 0;

  /// Getter for enemies killed
  int get enemiesKilled => _enemiesKilled;

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

  /// Increment the amount of enemies killed
  void incrementsEnemiesKilled() {
    _enemiesKilled += 1;

    if (_enemiesKilled == 1) {
      unlockTrophy("Primo nemico");
    }
    if (_enemiesKilled == 100) {
      unlockTrophy("100 nemici");
    }
    notifyListeners();
  }

  /// Unlock an upgrade
  void unlockTrophy(String trophyName) {
    final int index = _trophies.indexWhere((Trophy trophy) => trophy.name == trophyName);
    if (index != -1) {
      final Trophy trophy = _trophies[index];
      _trophies[index] = (
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
