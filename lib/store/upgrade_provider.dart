import 'dart:math';
import 'package:dungeon_run/settings/persistence.dart';
import 'package:dungeon_run/store/upgrade.dart';
import 'package:flutter/foundation.dart';

class UpgradeProvider extends ChangeNotifier {
  /// List of upgrades
  List<Upgrade> _upgrades = [];

  /// Getter for upgrades
  List<Upgrade> get upgrades => _upgrades;

  /// Amount of gold
  int _gold = 0;

  /// Getter for gold
  int get gold => _gold;

  /// Setter for gold
  set setGold(int value) {
    _gold = value;
    notifyListeners();
  }

  /// The container of the local saved data
  final Persistence _persistence = Persistence();

  /// Recover the buyed upgrades
  Future<void> loadFromMemory() async {
    _upgrades = await _persistence.getUpgrades();
    _gold = await _persistence.getGold();
    notifyListeners();
  }

  /// Save the upgrades to memory
  Future<void> saveToMemory() async {
    final List<String> encodedList = _upgrades.map((Upgrade upgrade) => upgradeToString(upgrade)).toList();
    await _persistence.saveUpgrades(encodedList);

    await _persistence.saveGold(_gold);
  }

  /// Unlock an upgrade
  void unlockUpgrade(String upgradeName) {
    final int index = _upgrades.indexWhere((Upgrade upgrade) => upgrade.name == upgradeName);
    if (index != -1) {
      final Upgrade upgrade = _upgrades[index];
      _upgrades[index] = (
        name: upgrade.name,
        description: upgrade.description,
        subMenu: upgrade.subMenu,
        unlocked: true, // Set unlocked to true
        dependency: upgrade.dependency,
        characterType: upgrade.characterType,
        collectableType: upgrade.collectableType,
        cost: upgrade.cost,
        costFactor: upgrade.costFactor,
        currentLevel: 0, // Set current level to 0
        maxLevel: upgrade.maxLevel,
        baseCooldown: upgrade.baseCooldown,
        step: upgrade.step,
      );
      notifyListeners();
    }
  }

  /// Update an upgrade
  void buyUpgrade(String upgradeName) {
    final int index = _upgrades.indexWhere((Upgrade upgrade) => upgrade.name == upgradeName);

    if (index != -1) {
      final Upgrade upgrade = _upgrades[index];

      final int cost = (pow(upgrade.costFactor, upgrade.currentLevel + 1) * upgrade.cost / 10).round() * 10;

      _upgrades[index] = (
        name: upgrade.name,
        description: upgrade.description,
        subMenu: upgrade.subMenu,
        unlocked: upgrade.unlocked,
        dependency: upgrade.dependency,
        characterType: upgrade.characterType,
        collectableType: upgrade.collectableType,
        cost: cost, // Update the cost based on the formula
        costFactor: upgrade.costFactor,
        currentLevel: upgrade.currentLevel + 1, // Increase the level by 1
        maxLevel: upgrade.maxLevel,
        baseCooldown: upgrade.baseCooldown,
        step: upgrade.step,
      );
      notifyListeners();
    }
  }
}
